import 'dart:io';
import 'package:weather/weather.dart'; 

class WeatherService {
  final WeatherFactory _weatherFactory;

  WeatherService(String apiKey) : _weatherFactory = WeatherFactory(apiKey);

  Future<Weather?> getWeather(double lat, double long) async {
    try {
      // Fetch weather data using the factory
      Weather weather =
          await _weatherFactory.currentWeatherByLocation(lat, long);
      return weather;
    } on SocketException catch (e) {
      // Handle network-related errors
      print('Network error: $e');
      return null;
    } on HttpException catch (e) {
      // Handle HTTP-specific errors (like 404, 500, etc.)
      print('HTTP error: $e');
      return null;
    } on FormatException catch (e) {
      // Handle format errors (like unexpected data format)
      print('Format error: $e');
      return null;
    } catch (e) {
      // Generic error handling
      print('Error fetching weather: $e');
      return null;
    }
  }
}
