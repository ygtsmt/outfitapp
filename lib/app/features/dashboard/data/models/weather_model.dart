/// Weather model for OpenWeatherMap API response
class WeatherModel {
  final String cityName;
  final double temperature;
  final String description;
  final String iconCode;
  final int humidity;
  final double windSpeed;
  final double feelsLike;

  WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.iconCode,
    required this.humidity,
    required this.windSpeed,
    required this.feelsLike,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json,
      {String? overrideCityName}) {
    final main = json['main'] as Map<String, dynamic>;
    final weather = (json['weather'] as List).first as Map<String, dynamic>;
    final wind = json['wind'] as Map<String, dynamic>;

    return WeatherModel(
      cityName: overrideCityName ?? (json['name'] as String),
      temperature: (main['temp'] as num).toDouble(),
      description: weather['description'] as String,
      iconCode: weather['icon'] as String,
      humidity: main['humidity'] as int,
      windSpeed: (wind['speed'] as num).toDouble(),
      feelsLike: (main['feels_like'] as num).toDouble(),
    );
  }

  /// Get weather icon URL from OpenWeatherMap
  String get iconUrl => 'https://openweathermap.org/img/wn/$iconCode@2x.png';

  /// Format temperature as string with Celsius
  String get temperatureString => '${temperature.round()}°C';

  /// Format feels like temperature
  String get feelsLikeString => '${feelsLike.round()}°C';

  /// Capitalize description
  String get capitalizedDescription {
    if (description.isEmpty) return '';
    return description[0].toUpperCase() + description.substring(1);
  }
}
