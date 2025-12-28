import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ginfit/app/features/dashboard/data/models/weather_model.dart';

/// Service for fetching weather data from OpenWeatherMap API
class WeatherService {
  // TODO: OpenWeatherMap API key'ini buraya ekle
  // Ücretsiz hesap için: https://openweathermap.org/api
  static const String _apiKey = 'ad2e81eae6edab030974b401bd0e895a';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  /// Fetch current weather by latitude and longitude
  Future<WeatherModel?> getWeatherByLocation(
    double latitude,
    double longitude,
  ) async {
    try {
      // First, get the province/state name via reverse geocoding
      String? provinceName;
      try {
        final geoUrl = Uri.parse(
          'http://api.openweathermap.org/geo/1.0/reverse?lat=$latitude&lon=$longitude&limit=1&appid=$_apiKey',
        );
        final geoResponse = await http.get(geoUrl);
        if (geoResponse.statusCode == 200) {
          final geoJson = jsonDecode(geoResponse.body) as List;
          if (geoJson.isNotEmpty) {
            final location = geoJson.first as Map<String, dynamic>;
            // Use 'state' field for province (e.g., "Ankara" instead of "Mamak")
            provinceName = location['state'] as String?;
          }
        }
      } catch (_) {}

      // Then get weather data
      final url = Uri.parse(
        '$_baseUrl/weather?lat=$latitude&lon=$longitude&appid=$_apiKey&units=metric&lang=tr',
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

  /// Fetch current weather by city name
  Future<WeatherModel?> getWeatherByCity(String cityName) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/weather?q=$cityName&appid=$_apiKey&units=metric&lang=tr',
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
}
