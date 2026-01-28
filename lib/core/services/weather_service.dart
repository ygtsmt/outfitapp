import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comby/app/features/dashboard/data/models/weather_model.dart';

/// Detaylı hava durumu verisi (Agent için)
class WeatherData {
  final double temperature; // Celsius
  final String condition; // "Clear", "Rain", "Clouds", "Snow"
  final double precipitation; // Yağış olasılığı %
  final int humidity; // Nem %
  final String description; // "Parçalı bulutlu", "Hafif yağmur"
  final String icon; // OpenWeatherMap icon code
  final DateTime date;

  WeatherData({
    required this.temperature,
    required this.condition,
    required this.precipitation,
    required this.humidity,
    required this.description,
    required this.icon,
    required this.date,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>;
    final weather = (json['weather'] as List).first as Map<String, dynamic>;
    final rain = json['rain'] as Map<String, dynamic>?;

    return WeatherData(
      temperature: (main['temp'] as num).toDouble(),
      condition: weather['main'] as String,
      precipitation:
          rain != null ? ((rain['3h'] as num?)?.toDouble() ?? 0.0) : 0.0,
      humidity: main['humidity'] as int,
      description: weather['description'] as String,
      icon: weather['icon'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(
        (json['dt'] as int) * 1000,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'temperature': temperature,
        'condition': condition,
        'precipitation': precipitation,
        'humidity': humidity,
        'description': description,
        'icon': icon,
        'date': date.toIso8601String(),
      };

  /// Hava durumuna göre kıyafet kategorisi
  String get clothingCategory {
    if (temperature < 10) return 'winter';
    if (temperature < 20) return 'spring_fall';
    return 'summer';
  }

  bool get isRainy => condition.toLowerCase().contains('rain');
  bool get isSnowy => condition.toLowerCase().contains('snow');
  bool get isSunny => condition.toLowerCase() == 'clear';

  String get summary => '${temperature.toStringAsFixed(0)}°C, $description';
}

/// Enhanced Weather Service with Agent support
@injectable
class WeatherService {
  final FirebaseFirestore _firestore;

  // Cache mekanizması
  final Map<String, WeatherData> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const _cacheDuration = Duration(hours: 1);

  // API Key cache
  String? _cachedApiKey;
  DateTime? _apiKeyFetchTime;

  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String _fallbackApiKey = 'ad2e81eae6edab030974b401bd0e895a';

  WeatherService(this._firestore);

  /// 🔑 OpenWeatherMap API Key'i Firebase'den al (5 dakika cache)
  Future<String> _getApiKey() async {
    try {
      final now = DateTime.now();
      if (_cachedApiKey != null &&
          _apiKeyFetchTime != null &&
          now.difference(_apiKeyFetchTime!).inMinutes < 5) {
        return _cachedApiKey!;
      }

      log('🔥 Fetching OpenWeatherMap API key from Firebase...');
      final docSnapshot =
          await _firestore.collection('keys').doc('weather_api').get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        final apiKey = data?['apiKey'] as String?;

        if (apiKey != null && apiKey.isNotEmpty) {
          _cachedApiKey = apiKey;
          _apiKeyFetchTime = now;
          log('✅ OpenWeatherMap API key loaded from Firebase');
          return apiKey;
        }
      }

      log('⚠️ Firebase key not found, using fallback');
      return _fallbackApiKey;
    } catch (e) {
      log('❌ Error fetching API key: $e, using fallback');
      return _fallbackApiKey;
    }
  }

  /// 🌤️ Agent için hava durumu (cache-first, forecast destekli)
  Future<WeatherData> getWeatherForAgent({
    required String city,
    required DateTime date,
  }) async {
    final cacheKey = '${city}_${date.toIso8601String().split('T')[0]}';
    final cachedData = _cache[cacheKey];
    final cacheTime = _cacheTimestamps[cacheKey];

    if (cachedData != null &&
        cacheTime != null &&
        DateTime.now().difference(cacheTime) < _cacheDuration) {
      log('📦 Using cached weather for $city');
      return cachedData;
    }

    try {
      final apiKey = await _getApiKey();
      final now = DateTime.now();
      final isToday = date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;

      WeatherData weatherData;

      if (isToday) {
        weatherData = await _getCurrentWeather(city, apiKey);
      } else {
        weatherData = await _getForecastWeather(city, date, apiKey);
      }

      _cache[cacheKey] = weatherData;
      _cacheTimestamps[cacheKey] = DateTime.now();

      return weatherData;
    } catch (e) {
      log('❌ Error fetching weather: $e');
      rethrow;
    }
  }

  Future<WeatherData> _getCurrentWeather(String city, String apiKey) async {
    final url = Uri.parse(
      '$_baseUrl/weather?q=$city&appid=$apiKey&units=metric&lang=tr',
    );

    log('🌤️ Fetching current weather for $city...');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      log('✅ Current weather fetched');
      return WeatherData.fromJson(data);
    } else {
      throw Exception('Weather API error: ${response.statusCode}');
    }
  }

  Future<WeatherData> _getForecastWeather(
    String city,
    DateTime targetDate,
    String apiKey,
  ) async {
    final url = Uri.parse(
      '$_baseUrl/forecast?q=$city&appid=$apiKey&units=metric&lang=tr',
    );

    log('🌤️ Fetching forecast for $city...');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final list = data['list'] as List;

      WeatherData? closestForecast;
      Duration? minDifference;

      for (final item in list) {
        final forecast = WeatherData.fromJson(item as Map<String, dynamic>);
        final difference = forecast.date.difference(targetDate).abs();

        if (minDifference == null || difference < minDifference) {
          minDifference = difference;
          closestForecast = forecast;
        }
      }

      if (closestForecast != null) {
        log('✅ Forecast fetched');
        return closestForecast;
      } else {
        throw Exception('No forecast data found');
      }
    } else {
      throw Exception('Weather API error: ${response.statusCode}');
    }
  }

  // ===== Mevcut metodlar (backward compatibility) =====

  Future<WeatherModel?> getWeatherByLocation(
    double latitude,
    double longitude,
  ) async {
    try {
      final apiKey = await _getApiKey();
      String? provinceName;

      try {
        final geoUrl = Uri.parse(
          'http://api.openweathermap.org/geo/1.0/reverse?lat=$latitude&lon=$longitude&limit=1&appid=$apiKey',
        );
        final geoResponse = await http.get(geoUrl);
        if (geoResponse.statusCode == 200) {
          final geoJson = jsonDecode(geoResponse.body) as List;
          if (geoJson.isNotEmpty) {
            final location = geoJson.first as Map<String, dynamic>;
            provinceName = location['state'] as String?;
          }
        }
      } catch (_) {}

      final url = Uri.parse(
        '$_baseUrl/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric&lang=tr',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return WeatherModel.fromJson(json, overrideCityName: provinceName);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<WeatherModel?> getWeatherByCity(String cityName) async {
    try {
      final apiKey = await _getApiKey();
      final url = Uri.parse(
        '$_baseUrl/weather?q=$cityName&appid=$apiKey&units=metric&lang=tr',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return WeatherModel.fromJson(json);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
    log('🗑️ Weather cache cleared');
  }
}
