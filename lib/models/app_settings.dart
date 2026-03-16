import 'package:flutter/material.dart';
import '../core/constants.dart';

/// Model class representing app settings
class AppSettings {
  final int targetR;
  final int targetG;
  final int targetB;
  final String espBaseUrl;
  final bool isDarkMode;
  final String language;

  AppSettings({
    int? targetR,
    int? targetG,
    int? targetB,
    String? espBaseUrl,
    bool? isDarkMode,
    String? language,
  })  : targetR = targetR ?? AppConstants.defaultTargetR,
        targetG = targetG ?? AppConstants.defaultTargetG,
        targetB = targetB ?? AppConstants.defaultTargetB,
        espBaseUrl = espBaseUrl ?? AppConstants.defaultEspBaseUrl,
        isDarkMode = isDarkMode ?? false,
        language = language ?? AppConstants.defaultLanguage;

  /// Create a copy with modified values
  AppSettings copyWith({
    int? targetR,
    int? targetG,
    int? targetB,
    String? espBaseUrl,
    bool? isDarkMode,
    String? language,
  }) {
    return AppSettings(
      targetR: targetR ?? this.targetR,
      targetG: targetG ?? this.targetG,
      targetB: targetB ?? this.targetB,
      espBaseUrl: espBaseUrl ?? this.espBaseUrl,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      language: language ?? this.language,
    );
  }

  /// Get full sensor URL
  String get sensorUrl => '$espBaseUrl${AppConstants.sensorEndpoint}';

  /// Validate RGB values
  static int clampRgbValue(int value) {
    return value.clamp(0, 255);
  }

  @override
  String toString() {
    return 'AppSettings(targetRGB: ($targetR, $targetG, $targetB), espUrl: $espBaseUrl, darkMode: $isDarkMode, language: $language)';
  }
}
