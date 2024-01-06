import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart'; // Import the geocoding package for placemarkFromCoordinates
import '../models/weather_model.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  // ignore: constant_identifier_names
  static const BASE_URL = 'http://api.openweathermap.org/data/2.5/weather';
  final String apiKey;

  WeatherService(this.apiKey);

  Future<Weather> getWeather(String cityName) async {
    final response = await http.get(Uri.parse(
        '$BASE_URL?q=$cityName&appid=$apiKey&units=metric'));

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<String> getCurrentCity() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      // Fetch location
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Convert location to list of objects
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);
      
      String? city = placemarks.isNotEmpty ? placemarks[0].locality : null;

      return city ?? "";
    } else {
      throw Exception('Location permissions are not granted');
    }
  }
}
