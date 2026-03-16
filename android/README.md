# DOMINOiT - Smart Plant Monitoring System

A Flutter mobile application for smart plant monitoring using RGB analysis and ESP32 sensor integration.

## Features

- **Plant RGB Analysis**: Capture photos and analyze plant color to calculate stress scores
- **ESP32 Integration**: Connect to ESP32 over WiFi to receive live sensor data
- **Live Sensor Data**: Monitor temperature, humidity, and soil moisture
- **Push Notifications**: Get alerts when plant stress is high
- **RGB Calibration**: Customize target RGB values for accurate analysis
- **Local Storage**: Save preferences locally using SharedPreferences
- **Dark/Light Theme**: Support for both dark and light themes

## Project Structure

```
domniot/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── core/
│   │   ├── constants.dart         # App constants
│   │   └── theme.dart             # Theme configuration
│   ├── models/
│   │   ├── sensor_data.dart       # Sensor data model
│   │   ├── rgb_analysis.dart      # RGB analysis model
│   │   └── app_settings.dart     # App settings model
│   ├── services/
│   │   ├── notification_service.dart    # Push notifications
│   │   ├── storage_service.dart         # Local storage
│   │   ├── esp32_service.dart           # ESP32 communication
│   │   └── rgb_analysis_service.dart    # RGB image analysis
│   ├── providers/
│   │   ├── settings_provider.dart       # Settings state
│   │   ├── sensor_provider.dart         # Sensor data state
│   │   └── rgb_analysis_provider.dart   # RGB analysis state
│   ├── screens/
│   │   ├── splash_screen.dart           # Splash screen
│   │   ├── home_screen.dart            # Home screen
│   │   ├── settings_screen.dart        # Settings screen
│   │   └── rgb_capture_screen.dart     # RGB capture screen
│   └── widgets/
│       ├── sensor_card.dart             # Sensor data card
│       └── stress_card.dart             # Stress score card
├── android/                     # Android configuration
├── ios/                         # iOS configuration
└── pubspec.yaml                 # Dependencies
```

## Getting Started

### Prerequisites

- Flutter SDK (stable channel)
- Android SDK / Xcode (for iOS)
- ESP32 device (optional - simulation mode available)

### Installation

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter build apk` to build the debug APK

### Configuration

1. **ESP32 Setup**: Configure the ESP32 base URL in Settings
2. **RGB Calibration**: Set target RGB values for healthy plants
3. **Notifications**: Grant notification permissions when prompted

## ESP32 API Endpoints

### GET /sensor
Returns JSON:
```
json
{
  "temperature": 25.4,
  "humidity": 60,
  "soil": 45
}
```

## Developer

- **Developer**: Ahmet Elieyi
- **Team**: Ekal Tech Team

## License

This project is proprietary software developed by Ekal Tech Team.
