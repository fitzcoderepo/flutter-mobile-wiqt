import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wateriqcloud_mobile/services/weather_service/weather_service.dart';
import 'package:weather/weather.dart';

class LocationProvider with ChangeNotifier {
  LatLng? _unitLocation;
  Weather? _currentWeather;
  LatLng? get unitLocation => _unitLocation;
  Weather? get currentWeather => _currentWeather;
  final WeatherService? _weatherService;
  LocationProvider(String apiKey) : _weatherService = WeatherService(apiKey);

  void setUnitLocation(double lat, double long) {
    _unitLocation = LatLng(lat, long);
    notifyListeners();
    _fetchWeather(lat, long);
  }

  Future<void> _fetchWeather(double lat, double lon) async {
    _currentWeather = await _weatherService?.getWeather(lat, lon);
    notifyListeners();
  }

 
}
