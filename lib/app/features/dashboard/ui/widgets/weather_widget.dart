import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:ginly/app/features/closet/data/closet_usecase.dart';
import 'package:ginly/app/features/dashboard/data/models/weather_model.dart';
import 'package:ginly/app/features/fal_ai/data/fal_ai_usecase.dart';
import 'package:ginly/core/services/location_service.dart';
import 'package:ginly/core/services/weather_service.dart';
import 'package:ginly/core/services/outfit_suggestion_service.dart';

/// Weather widget that shows current weather based on user's location
/// Shows permission request if location access is not granted
class WeatherWidget extends StatefulWidget {
  const WeatherWidget({super.key});

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  final LocationService _locationService = LocationService();
  final WeatherService _weatherService = WeatherService();
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
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Get location
    final position = await _locationService.getCurrentPosition();
    if (position == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Konum alınamadı';
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
        _errorMessage = 'Hava durumu bilgisi alınamadı';
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
        _showErrorSnackbar('Model eklemeniz gerekiyor');
        return;
      }

      if (closetItems.isEmpty) {
        _showErrorSnackbar('Dolabınıza kıyafet eklemeniz gerekiyor');
        return;
      }

      // Get AI suggestion
      final suggestion = await _outfitService.suggestOutfit(
        weather: _weather!,
        models: models,
        closetItems: closetItems,
      );

      if (suggestion == null) {
        _showErrorSnackbar('Kombin önerisi oluşturulamadı');
        return;
      }

      // Show bottom sheet with suggestion
      if (mounted) {
        _showOutfitBottomSheet(suggestion);
      }
    } catch (e) {
      _showErrorSnackbar('Hata: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingOutfit = false;
        });
      }
    }
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

  void _showOutfitBottomSheet(OutfitSuggestion suggestion) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _OutfitSuggestionSheet(
        suggestion: suggestion,
        weather: _weather!,
      ),
    );
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
            'Hava durumu yükleniyor...',
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
            'Hava Durumu',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Konumunuza göre hava durumu görmek için\nkonum iznine ihtiyacımız var.',
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
            label: const Text('Konum İzni Ver'),
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
            _errorMessage ?? 'Bir hata oluştu',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 16.h),
          TextButton.icon(
            onPressed: _checkPermissionAndLoadWeather,
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            label: const Text(
              'Tekrar Dene',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
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
              Row(
                children: [
                  // Generate Outfit Button
                  GestureDetector(
                    onTap: _isGeneratingOutfit ? null : _generateOutfit,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isGeneratingOutfit)
                            SizedBox(
                              width: 14.w,
                              height: 14.w,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.w,
                              ),
                            )
                          else
                            Icon(
                              Icons.checkroom_rounded,
                              color: Colors.white,
                              size: 16.sp,
                            ),
                          SizedBox(width: 6.w),
                          Text(
                            _isGeneratingOutfit ? 'Oluşturuluyor...' : 'Kombin',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  // Refresh button
                  GestureDetector(
                    onTap: _checkPermissionAndLoadWeather,
                    child: Icon(
                      Icons.refresh_rounded,
                      color: Colors.white70,
                      size: 22.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
          SizedBox(height: 16.h),
          // Additional info
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
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
                  label: 'Hissedilen',
                  value: _weather!.feelsLikeString,
                ),
                _buildDivider(),
                _buildInfoItem(
                  icon: Icons.water_drop_rounded,
                  label: 'Nem',
                  value: '${_weather!.humidity}%',
                ),
                _buildDivider(),
                _buildInfoItem(
                  icon: Icons.air_rounded,
                  label: 'Rüzgar',
                  value: '${_weather!.windSpeed.round()} km/s',
                ),
              ],
            ),
          ),
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
}

/// Bottom sheet showing outfit suggestion
class _OutfitSuggestionSheet extends StatefulWidget {
  final OutfitSuggestion suggestion;
  final WeatherModel weather;

  const _OutfitSuggestionSheet({
    required this.suggestion,
    required this.weather,
  });

  @override
  State<_OutfitSuggestionSheet> createState() => _OutfitSuggestionSheetState();
}

class _OutfitSuggestionSheetState extends State<_OutfitSuggestionSheet> {
  bool _isGenerating = false;
  String? _requestId;

  Future<void> _generateOutfitImage() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      final falAiUsecase = GetIt.I<FalAiUsecase>();

      final result = await falAiUsecase.generateGeminiImageEdit(
        imageUrls: widget.suggestion.imageUrls,
        prompt:
            'Wear clothes for ${widget.weather.temperature.round()}°C ${widget.weather.description} weather',
        modelAiPrompt: widget.suggestion.model.aiPrompt,
      );

      if (result != null && result['status'] == 'processing') {
        setState(() {
          _requestId = result['id'] as String?;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Kombin oluşturuluyor! Kütüphaneden takip edebilirsiniz.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                // Title
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: colorScheme.primary,
                      size: 24.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'AI Kombin Önerisi',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),

                // Weather info
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    '${widget.weather.temperature.round()}°C • ${widget.weather.capitalizedDescription}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                // AI Reasoning
                if (widget.suggestion.reasoning.isNotEmpty) ...[
                  Text(
                    widget.suggestion.reasoning,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: colorScheme.onSurface.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],

                // Selected Model
                Text(
                  'Model',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                SizedBox(height: 8.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: CachedNetworkImage(
                    imageUrl: widget.suggestion.model.imageUrl,
                    height: 200.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 20.h),

                // Selected Clothes
                Text(
                  'Seçilen Kıyafetler',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                SizedBox(height: 8.h),
                SizedBox(
                  height: 100.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.suggestion.closetItems.length,
                    itemBuilder: (context, index) {
                      final item = widget.suggestion.closetItems[index];
                      return Container(
                        width: 100.w,
                        margin: EdgeInsets.only(right: 12.w),
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12.r),
                                child: CachedNetworkImage(
                                  imageUrl: item.imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              item.category ?? item.subcategory ?? '',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 24.h),

                // Generate Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isGenerating || _requestId != null
                        ? null
                        : _generateOutfitImage,
                    icon: _isGenerating
                        ? SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.w,
                              color: colorScheme.onPrimary,
                            ),
                          )
                        : Icon(_requestId != null
                            ? Icons.check_circle
                            : Icons.auto_fix_high),
                    label: Text(
                      _requestId != null
                          ? 'Oluşturuluyor...'
                          : (_isGenerating
                              ? 'Hazırlanıyor...'
                              : 'Kombini Görselleştir'),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          );
        },
      ),
    );
  }
}
