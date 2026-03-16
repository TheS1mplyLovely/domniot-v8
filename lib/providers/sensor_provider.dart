import 'package:flutter/foundation.dart';
import '../models/sensor_data.dart';
import '../services/esp32_service.dart';
import '../services/notification_service.dart';
import '../core/constants.dart';

/// Provider for managing sensor data state
class SensorProvider extends ChangeNotifier {
  final Esp32Service _esp32Service = Esp32Service();
  final NotificationService _notificationService = NotificationService();
  
  SensorData? _sensorData;
  bool _isLoading = false;
  String? _error;
  bool _useSimulation = false;
  DateTime? _lastUpdated;

  /// Get current sensor data
  SensorData? get sensorData => _sensorData;
  
  /// Check if loading
  bool get isLoading => _isLoading;
  
  /// Get error message
  String? get error => _error;
  
  /// Get last updated time
  DateTime? get lastUpdated => _lastUpdated;
  
  /// Check if using simulation mode
  bool get useSimulation => _useSimulation;

  /// Initialize with base URL
  void initialize(String baseUrl) {
    _esp32Service.updateBaseUrl(baseUrl);
  }

  /// Update ESP32 base URL
  void updateBaseUrl(String url) {
    _esp32Service.updateBaseUrl(url);
  }

  /// Toggle simulation mode
  void toggleSimulationMode() {
    _useSimulation = !_useSimulation;
    notifyListeners();
  }

  /// Set simulation mode
  void setSimulationMode(bool value) {
    _useSimulation = value;
    notifyListeners();
  }

  /// Fetch sensor data from ESP32
  Future<void> fetchSensorData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_useSimulation) {
        // Use simulated data
        await Future.delayed(const Duration(milliseconds: 500));
        _sensorData = _esp32Service.getSimulatedData();
      } else {
        // Fetch from ESP32
        _sensorData = await _esp32Service.fetchSensorData();
      }
      
      _lastUpdated = DateTime.now();
      
      // Check for sensor alerts
      await _checkSensorAlerts();
      
      _isLoading = false;
      notifyListeners();
    } on Esp32Exception catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Unexpected error: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Check sensor values and show alerts if needed
  Future<void> _checkSensorAlerts() async {
    if (_sensorData == null) return;

    final data = _sensorData!;

    // Temperature alerts
    if (data.temperature > 35) {
      await _notificationService.showSensorAlert(
        title: '🌡️ High Temperature Alert',
        message: 'Current temperature: ${data.temperature.toStringAsFixed(1)}°C - Too hot for most plants!',
      );
    } else if (data.temperature < 10) {
      await _notificationService.showSensorAlert(
        title: '❄️ Low Temperature Alert',
        message: 'Current temperature: ${data.temperature.toStringAsFixed(1)}°C - Too cold for plants!',
      );
    }

    // Soil moisture alerts
    if (data.soilMoisture < 20) {
      await _notificationService.showSensorAlert(
        title: '💧 Low Soil Moisture',
        message: 'Soil is very dry (${data.soilMoisture}%) - Water your plant!',
      );
    } else if (data.soilMoisture > 90) {
      await _notificationService.showSensorAlert(
        title: '🌊 High Soil Moisture',
        message: 'Soil is waterlogged (${data.soilMoisture}%) - Check for overwatering!',
      );
    }

    // Humidity alerts
    if (data.humidity < 20) {
      await _notificationService.showSensorAlert(
        title: '🏜️ Low Humidity Alert',
        message: 'Air humidity is very low (${data.humidity}%) - Consider misting!',
      );
    }
  }

  /// Test ESP32 connection
  Future<bool> testConnection() async {
    return await _esp32Service.testConnection();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear sensor data
  void clearData() {
    _sensorData = null;
    _lastUpdated = null;
    notifyListeners();
  }
}
