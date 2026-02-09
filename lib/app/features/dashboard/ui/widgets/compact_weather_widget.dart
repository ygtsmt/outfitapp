import 'package:shared_preferences/shared_preferences.dart';
import 'package:comby/app/features/dashboard/data/models/weather_model.dart';
import 'package:comby/generated/l10n.dart';
import 'package:comby/core/services/location_service.dart';
import 'package:comby/core/services/weather_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';

/// Compact weather widget for dashboard - shows essential weather info
class CompactWeatherWidget extends StatefulWidget {
  const CompactWeatherWidget({super.key});

  @override
  State<CompactWeatherWidget> createState() => _CompactWeatherWidgetState();
}

class _CompactWeatherWidgetState extends State<CompactWeatherWidget> {
  final LocationService _locationService = LocationService();
  final WeatherService _weatherService = GetIt.I<WeatherService>();

  WeatherModel? _weather;
  bool _isLoading = true;
  bool _hasPermission = false;
  String? _errorMessage;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionAndLoadWeather();
  }

  Future<void> _checkPermissionAndLoadWeather() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    _hasPermission = await _locationService.hasPermission();

    if (!_hasPermission) {
      // Automatically request permission on first load
      final permission = await _locationService.requestPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        // Permission denied - show permission request UI
        setState(() {
          _isLoading = false;
          _hasPermission = false;
        });
        return;
      }

      // Permission granted
      _hasPermission = true;
    }

    final position = await _locationService.getCurrentPosition();
    if (position == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = AppLocalizations.of(context).locationNotReceived;
      });
      return;
    }

    final weather = await _weatherService.getWeatherByLocation(
      position.latitude,
      position.longitude,
    );

    setState(() {
      _weather = weather;
      _isLoading = false;
      if (weather == null) {
        _errorMessage = AppLocalizations.of(context).weatherInfoNotReceived;
      } else {
        _checkDailyOutfit();
      }
    });
  }

  Future<void> _requestPermission() async {
    final permission = await _locationService.requestPermission();

    if (permission == LocationPermission.deniedForever) {
      await _locationService.openAppSettings();
    }

    _checkPermissionAndLoadWeather();
  }

  Future<void> _checkDailyOutfit() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastCheck = prefs.getString('last_daily_outfit_check');

    if (lastCheck == today) {
      return;
    }

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      await prefs.setString('last_daily_outfit_check', today);
    }
  }

  List<Color> _getGradientColors() {
    if (_weather == null) {
      return [const Color(0xFF4A90E2), const Color(0xFF357ABD)];
    }

    final temp = _weather!.temperature;
    final condition = _weather!.description.toLowerCase();

    if (condition.contains('rain') || condition.contains('drizzle')) {
      return [const Color(0xFF667EEA), const Color(0xFF764BA2)];
    } else if (condition.contains('cloud')) {
      return [const Color(0xFF8E9EAB), const Color(0xFFEEF2F3)];
    } else if (condition.contains('snow')) {
      return [const Color(0xFFE0EAFC), const Color(0xFFCFDEF3)];
    } else if (temp > 25) {
      return [const Color(0xFFF093FB), const Color(0xFFF5576C)];
    } else if (temp < 10) {
      return [const Color(0xFF4A90E2), const Color(0xFF357ABD)];
    } else {
      return [const Color(0xFF56CCF2), const Color(0xFF2F80ED)];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingCard();
    }

    if (!_hasPermission) {
      return _buildPermissionCard();
    }

    if (_errorMessage != null) {
      return _buildErrorCard();
    }

    if (_weather == null) {
      return const SizedBox.shrink();
    }

    return _buildCompactWeatherCard();
  }

  Widget _buildCompactWeatherCard() {
    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _getGradientColors(),
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: _getGradientColors().first.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Main compact info
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  // Weather icon
                  Container(
                    width: 60.w,
                    height: 60.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: _weather!.iconUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // Weather info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              color: Colors.white70,
                              size: 14.sp,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              _weather!.cityName,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          _weather!.temperatureString,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32.sp,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),
                        Text(
                          _weather!.capitalizedDescription,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13.sp,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Action buttons
                  Column(
                    children: [
                      IconButton(
                        onPressed: _checkPermissionAndLoadWeather,
                        icon: Icon(
                          Icons.refresh_rounded,
                          color: Colors.white70,
                          size: 20.sp,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      SizedBox(height: 8.h),
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: Colors.white70,
                        size: 20.sp,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Expanded details
            if (_isExpanded)
              Container(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                child: Column(
                  children: [
                    Divider(color: Colors.white.withOpacity(0.3), height: 1),
                    SizedBox(height: 12.h),

                    // Weather details grid
                    Row(
                      children: [
                        _buildDetailItem(
                          Icons.thermostat_outlined,
                          AppLocalizations.of(context).felt,
                          '${_weather!.feelsLike.round()}°C',
                        ),
                        _buildDetailItem(
                          Icons.water_drop_outlined,
                          AppLocalizations.of(context).humidity,
                          '${_weather!.humidity}%',
                        ),
                        _buildDetailItem(
                          Icons.air_rounded,
                          AppLocalizations.of(context).wind,
                          '${_weather!.windSpeed.toStringAsFixed(1)} m/s',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 20.sp),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 12.h),
            Text(
              AppLocalizations.of(context).loadingWeather,
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_off_rounded, color: Colors.white, size: 40.sp),
          SizedBox(height: 12.h),
          Text(
            AppLocalizations.of(context).locationPermissionRequired,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12.h),
          ElevatedButton(
            onPressed: _requestPermission,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF667EEA),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              AppLocalizations.of(context).giveLocationPermission,
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.red.shade400,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded, color: Colors.white, size: 40.sp),
          SizedBox(height: 12.h),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 14.sp),
          ),
          SizedBox(height: 12.h),
          TextButton(
            onPressed: _checkPermissionAndLoadWeather,
            child: Text(
              AppLocalizations.of(context).retry,
              style: TextStyle(color: Colors.white, fontSize: 13.sp),
            ),
          ),
        ],
      ),
    );
  }
}
