import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;
import 'package:flutter/foundation.dart';

class Config {
  static Config? _instance;
  final String googleMapsApiKey;
  static const platform = MethodChannel('google_geofence_helper');

  Config({
    required this.googleMapsApiKey,
  });

  static Future<Config> getInstance() async {
    if (_instance == null) {
      // Load .env file
      await dotenv.dotenv.load(fileName: '.env');
      
      // Get API key from environment
      String apiKey = dotenv.dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
      
      if (apiKey.isEmpty) {
        throw Exception('Failed to load Google Maps API key. Please ensure you have created .env '
            'file from .env.example and added your API key.');
      }

      _instance = Config(googleMapsApiKey: apiKey);

      // Set up platform-specific API key
      if (!kIsWeb) {
        try {
          await platform.invokeMethod('getGoogleMapsApiKey', {'apiKey': apiKey});
        } catch (e) {
          print('Warning: Failed to set platform API key: $e');
        }
      }
    }
    return _instance!;
  }
} 