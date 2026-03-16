/// Model class representing sensor data from ESP32
class SensorData {
  final double temperature;
  final int humidity;
  final int soilMoisture;
  final DateTime timestamp;

  SensorData({
    required this.temperature,
    required this.humidity,
    required this.soilMoisture,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Create from JSON response
  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      temperature: _parseDouble(json['temperature']),
      humidity: _parseInt(json['humidity']),
      soilMoisture: _parseInt(json['soil']),
      timestamp: DateTime.now(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'soil': soilMoisture,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Safe double parsing
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Safe int parsing
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// Check if data is valid
  bool get isValid {
    return temperature > -50 && temperature < 100 &&
           humidity >= 0 && humidity <= 100 &&
           soilMoisture >= 0 && soilMoisture <= 100;
  }

  /// Get temperature status
  String get temperatureStatus {
    if (temperature < 15) return 'Cold';
    if (temperature > 30) return 'Hot';
    return 'Normal';
  }

  /// Get humidity status
  String get humidityStatus {
    if (humidity < 30) return 'Dry';
    if (humidity > 80) return 'Humid';
    return 'Normal';
  }

  /// Get soil moisture status
  String get soilMoistureStatus {
    if (soilMoisture < 20) return 'Dry';
    if (soilMoisture > 80) return 'Wet';
    return 'Normal';
  }

  @override
  String toString() {
    return 'SensorData(temp: $temperature°C, humidity: $humidity%, soil: $soilMoisture%)';
  }
}
