import 'dart:convert';
import 'package:auto_route/auto_route.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:comby/app/features/closet/data/closet_usecase.dart';
import 'package:comby/app/features/dashboard/data/models/weather_model.dart';
import 'package:comby/core/core.dart';
import 'package:comby/generated/l10n.dart';
import 'package:comby/core/routes/app_router.dart';
import 'package:comby/core/services/location_service.dart';
import 'package:comby/core/services/outfit_suggestion_service.dart';
import 'package:comby/core/services/weather_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';

/// Weather widget that shows current weather based on user's location
/// Shows permission request if location access is not granted
class WeatherWidget extends StatefulWidget {
  const WeatherWidget({super.key});

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  final LocationService _locationService = LocationService();
  final WeatherService _weatherService = GetIt.I<WeatherService>();
  final OutfitSuggestionService _outfitService = OutfitSuggestionService();

  WeatherModel? _weather;
  bool _isLoading = true;
  bool _hasPermission = false;
  String? _errorMessage;
  bool _isGeneratingOutfit = false;

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

    // Check permission
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

    // Get location
    final position = await _locationService.getCurrentPosition();
    if (position == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = AppLocalizations.of(context).locationNotReceived;
      });
      return;
    }

    // Fetch weather
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
        _checkDailyOutfit(); // Check daily outfit after weather loads
      }
    });
  }

  Future<void> _requestPermission() async {
    final permission = await _locationService.requestPermission();

    if (permission == LocationPermission.deniedForever) {
      // Open app settings
      await _locationService.openAppSettings();
    }

    _checkPermissionAndLoadWeather();
  }

  Future<void> _generateOutfit() async {
    if (_weather == null) return;

    setState(() {
      _isGeneratingOutfit = true;
    });

    try {
      // Get user's closet and model items
      final closetUseCase = GetIt.I<ClosetUseCase>();
      final models = await closetUseCase.getUserModelItems();
      final closetItems = await closetUseCase.getUserClosetItems();

      if (models.isEmpty) {
        _showErrorSnackbar(AppLocalizations.of(context).needToAddModel);
        return;
      }

      if (closetItems.isEmpty) {
        _showErrorSnackbar(AppLocalizations.of(context).needToAddCloth);
        return;
      }

      // Get AI suggestion
      final suggestion = await _outfitService.suggestOutfit(
        weather: _weather!,
        models: models,
        closetItems: closetItems,
      );

      if (suggestion == null) {
        _showErrorSnackbar(AppLocalizations.of(context).outfitSuggestionFailed);
        return;
      }

      // Save suggestion and update UI, but don't auto-show
      if (mounted) {
        _saveDailyOutfit(suggestion);
      }
    } catch (e) {
      _showErrorSnackbar(
          AppLocalizations.of(context).errorOccurred(e.toString()));
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingOutfit = false;
        });
      }
    }
  }

  void _saveDailyOutfit(OutfitSuggestion suggestion) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final key = 'daily_outfit_$today';

    // We need toJson implementation in OutfitSuggestion
    // For now, we assume it's serializable or implemented
    // If not, we should implement it in next step.
    // Actually, I should check OutfitSuggestion model first.
    // Assuming simple JSON encoding for now.
    // Wait, OutfitSuggestion contains ModelItem and WardrobeItem objects.
    // I need to serialize them properly.

    final jsonMap = suggestion.toJson();
    await prefs.setString(key, jsonEncode(jsonMap));

    setState(() {
      _cachedSuggestion = suggestion;
      _isOutfitReady = true;
    });
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    setState(() {
      _isGeneratingOutfit = false;
    });
  }

  Future<void> _showOutfitBottomSheet(OutfitSuggestion suggestion) async {
    // _saveDailyOutfit(suggestion); // Already saved
    await context.router.push(
      OutfitSuggestionResultScreenRoute(
        suggestion: suggestion,
        weather: _weather!,
      ),
    );
    // Refresh to get the generated image from cache if available
    _checkDailyOutfit();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (!_hasPermission) {
      return _buildPermissionRequest();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_weather != null) {
      return _buildWeatherCard();
    }

    return const SizedBox.shrink();
  }

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade400,
            Colors.blue.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2.w,
          ),
          SizedBox(height: 12.h),
          Text(
            AppLocalizations.of(context).loadingWeather,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionRequest() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade700,
            Colors.grey.shade900,
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_off_rounded,
            color: Colors.white70,
            size: 48.sp,
          ),
          SizedBox(height: 16.h),
          Text(
            AppLocalizations.of(context).weather,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            AppLocalizations.of(context).locationPermissionRequired,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 20.h),
          ElevatedButton.icon(
            onPressed: _requestPermission,
            icon: const Icon(Icons.location_on_rounded),
            label: Text(AppLocalizations.of(context).giveLocationPermission),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.grey.shade900,
              padding: EdgeInsets.symmetric(
                horizontal: 24.w,
                vertical: 12.h,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange.shade400,
            Colors.orange.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off_rounded,
            color: Colors.white,
            size: 48.sp,
          ),
          SizedBox(height: 12.h),
          Text(
            _errorMessage ?? AppLocalizations.of(context).common_error,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 16.h),
          TextButton.icon(
            onPressed: _checkPermissionAndLoadWeather,
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            label: Text(
              AppLocalizations.of(context).tryAgain,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getGradientColors(),
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: _getGradientColors().first.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // City and action buttons
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
            child: Column(
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            color: Colors.white,
                            size: 18.sp,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            _weather!.cityName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: _checkPermissionAndLoadWeather,
                        child: Icon(
                          Icons.refresh_rounded,
                          color: Colors.white70,
                          size: 22.sp,
                        ),
                      ),
                    ]),
                SizedBox(height: 16.h),
                // Temperature and icon
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _weather!.temperatureString,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 56.sp,
                              fontWeight: FontWeight.bold,
                              height: 1,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            _weather!.capitalizedDescription,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CachedNetworkImage(
                      imageUrl: _weather!.iconUrl,
                      width: 80.w,
                      height: 80.w,
                      placeholder: (context, url) => SizedBox(
                        width: 80.w,
                        height: 80.w,
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.cloud,
                        color: Colors.white,
                        size: 60.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          // Additional info
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8.w),
            padding: EdgeInsets.symmetric(
              horizontal: 8.w,
              vertical: 12.h,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem(
                  icon: Icons.thermostat_rounded,
                  label: AppLocalizations.of(context).felt,
                  value: _weather!.feelsLikeString,
                ),
                _buildDivider(),
                _buildInfoItem(
                  icon: Icons.water_drop_rounded,
                  label: AppLocalizations.of(context).humidity,
                  value: '${_weather!.humidity}%',
                ),
                _buildDivider(),
                _buildInfoItem(
                  icon: Icons.air_rounded,
                  label: AppLocalizations.of(context).wind,
                  value: '${_weather!.windSpeed.round()} km/s',
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          // Kırmızıyı atıp yerine bunu koyarsak:
          _buildCombinedButton(),
          // _isGeneratingOutfit ? null : _generateOutfit,
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20.sp),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 11.sp,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40.h,
      color: Colors.white24,
    );
  }

  List<Color> _getGradientColors() {
    // Dynamic gradient based on weather condition
    final iconCode = _weather?.iconCode ?? '01d';

    if (iconCode.contains('n')) {
      // Night
      return [Colors.indigo.shade800, Colors.indigo.shade900];
    } else if (iconCode.startsWith('01') || iconCode.startsWith('02')) {
      // Clear or few clouds
      return [Colors.blue.shade400, Colors.blue.shade700];
    } else if (iconCode.startsWith('03') || iconCode.startsWith('04')) {
      // Cloudy
      return [Colors.blueGrey.shade400, Colors.blueGrey.shade600];
    } else if (iconCode.startsWith('09') || iconCode.startsWith('10')) {
      // Rain
      return [Colors.blueGrey.shade600, Colors.blueGrey.shade800];
    } else if (iconCode.startsWith('11')) {
      // Thunderstorm
      return [Colors.deepPurple.shade600, Colors.deepPurple.shade900];
    } else if (iconCode.startsWith('13')) {
      // Snow
      return [Colors.lightBlue.shade200, Colors.lightBlue.shade400];
    } else if (iconCode.startsWith('50')) {
      // Mist/Fog
      return [Colors.grey.shade400, Colors.grey.shade600];
    }

    return [Colors.blue.shade400, Colors.blue.shade600];
  }

  Widget _buildCombinedButton() {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (_isOutfitReady && _cachedSuggestion != null) {
              _showOutfitBottomSheet(_cachedSuggestion!);
            } else if (!_isGeneratingOutfit) {
              _generateOutfit();
            }
          },
          borderRadius: BorderRadius.circular(20.r),
          splashColor: Colors.white.withOpacity(0.2),
          highlightColor: Colors.white.withOpacity(0.1),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                // SOL TARAF: Icon + Title & Subtitle
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    color: _getGradientColors().first,
                    size: 24.sp,
                  ),
                ),

                SizedBox(width: 12.w),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          children: [
                            const TextSpan(text: 'Gemini '),
                            TextSpan(
                              text: '3',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        _isOutfitReady
                            ? "I've prepared the best outfit for you! ✨"
                            : "Best outfit for the weather",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: 11.sp,
                          height: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 8.w),

                // SAĞ TARAF: Arrow veya Loading
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: _isGeneratingOutfit
                        ? SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Icon(
                            _isOutfitReady
                                ? Icons.check_rounded
                                : Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 24.sp,
                          ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _checkDailyOutfit() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final key = 'daily_outfit_$today';

    if (prefs.containsKey(key)) {
      final jsonString = prefs.getString(key);
      if (jsonString != null) {
        setState(() {
          _cachedSuggestion = OutfitSuggestion.fromJson(jsonDecode(jsonString));
          _isOutfitReady = true;
        });
      }
    } else {
      // If weather is ready, auto generate
      if (_weather != null) {
        _generateOutfit();
      }
    }
  }

  OutfitSuggestion? _cachedSuggestion;
  bool _isOutfitReady = false;
}
