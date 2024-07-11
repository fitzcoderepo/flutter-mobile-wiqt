import 'package:weather/weather.dart';

class WeatherService {
  final WeatherFactory _weatherFactory;

  WeatherService(String apiKey) : _weatherFactory = WeatherFactory(apiKey);

  Future<Weather?> getWeather(double lat, double long) async {
    try {
      Weather weather =
          await _weatherFactory.currentWeatherByLocation(lat, long);
      return weather;
    } catch (e) {
      print('Error fetching weather: $e');
      return null;
    }
  }
}
