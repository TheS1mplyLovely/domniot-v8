import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/sensor_data.dart';

/// Service for communicating with ESP32 over WiFi
class Esp32Service {
  static final Esp32Service _instance = Esp32Service._internal();
  factory Esp32Service() => _instance;
  Esp32Service._internal();

  String _baseUrl = AppConstants.defaultEspBaseUrl;

  /// Update base URL
  void updateBaseUrl(String url) {
    _baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  /// Get current base URL
  String get baseUrl => _baseUrl;

  /// Fetch sensor data from ESP32
  Future<SensorData> fetchSensorData() async {
    final url = '$_baseUrl${AppConstants.sensorEndpoint}';
    
    try {
      // Validate URL format
      final uri = Uri.parse(url);
      if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
        throw Esp32Exception('Invalid URL format. URL must start with http:// or https://');
      }

      final response = await http.get(
        uri,
      ).timeout(
        const Duration(seconds: AppConstants.connectionTimeoutSeconds),
        onTimeout: () {
          throw Esp32Exception('Connection timed out. ESP32 may be offline.');
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return SensorData.fromJson(json);
      } else if (response.statusCode == 404) {
        throw Esp32Exception('ESP32 endpoint not found. Check the URL.');
      } else if (response.statusCode == 500) {
        throw Esp32Exception('ESP32 server error. Please try again.');
      } else {
        throw Esp32Exception('Failed to connect: HTTP ${response.statusCode}');
      }
    } on SocketException {
      throw Esp32Exception('Cannot connect to ESP32. Check WiFi connection.');
    } on FormatException {
      throw Esp32Exception('Invalid JSON response from ESP32.');
    } on http.ClientException catch (e) {
      throw Esp32Exception('Network error: ${e.message}');
    } on Esp32Exception {
      rethrow;
    } catch (e) {
      throw Esp32Exception('Unexpected error: $e');
    }
  }

  /// Test connection to ESP32
  Future<bool> testConnection() async {
    try {
      await fetchSensorData();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Generate simulated sensor data for testing
  /// This can be used when ESP32 is not available
  SensorData getSimulatedData() {
    return SensorData(
      temperature: 22.0 + (DateTime.now().second % 10) * 0.5,
      humidity: 50 + (DateTime.now().second % 30),
      soilMoisture: 40 + (DateTime.now().second % 40),
    );
  }
}

/// Custom exception for ESP32 errors
class Esp32Exception implements Exception {
  final String message;
  Esp32Exception(this.message);

  @override
  String toString() => message;
}
