/// Application-wide constants for DOMINOiT
class AppConstants {
  // App Info
  static const String appName = 'DOMINOiT';
  static const String appVersion = '1.0.0';
  static const String developer = 'Ahmet Elieyi';
  static const String team = 'Ekal Tech Team';
  
  // Default ESP32 Configuration
  static const String defaultEspBaseUrl = 'http://192.168.1.100';
  static const String sensorEndpoint = '/sensor';
  
  // Default RGB Target Values (healthy plant baseline)
  static const int defaultTargetR = 85;
  static const int defaultTargetG = 150;
  static const int defaultTargetB = 85;
  
  // Stress Score Thresholds
  static const int highStressThreshold = 4;
  static const int maxStressScore = 10;
  static const int minStressScore = 1;
  
  // Timing
  static const int splashDurationSeconds = 3;
  static const int connectionTimeoutSeconds = 10;
  
  // SharedPreferences Keys
  static const String keyTargetR = 'target_r';
  static const String keyTargetG = 'target_g';
  static const String keyTargetB = 'target_b';
  static const String keyEspBaseUrl = 'esp_base_url';
  static const String keyDarkMode = 'dark_mode';
  static const String keyLanguage = 'language';
  
  // Default Language
  static const String defaultLanguage = 'tr';
  
  // Supported Languages
  static const List<String> supportedLanguages = ['tr', 'en', 'ru'];
  
  // Notification Channel
  static const String notificationChannelId = 'domniot_alerts';
  static const String notificationChannelName = 'Plant Alerts';
  static const String notificationChannelDescription = 'Alerts for plant stress and sensor readings';
}
