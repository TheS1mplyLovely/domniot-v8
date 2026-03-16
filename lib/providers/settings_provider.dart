import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../services/storage_service.dart';

/// Provider for managing app settings state
class SettingsProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  
  AppSettings _settings = AppSettings();
  bool _isLoading = true;
  String? _error;

  /// Get current settings
  AppSettings get settings => _settings;
  
  /// Check if loading
  bool get isLoading => _isLoading;
  
  /// Get error message
  String? get error => _error;

  /// Get current locale
  Locale get locale => Locale(_settings.language);

  /// Initialize and load settings
  Future<void> initialize() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _settings = await _storageService.loadSettings();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load settings: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update target RGB values
  Future<void> updateTargetRgb({
    int? targetR,
    int? targetG,
    int? targetB,
  }) async {
    try {
      _settings = _settings.copyWith(
        targetR: targetR,
        targetG: targetG,
        targetB: targetB,
      );
      notifyListeners();

      await _storageService.saveSettings(_settings);
    } catch (e) {
      _error = 'Failed to save RGB settings: $e';
      notifyListeners();
    }
  }

  /// Update ESP32 base URL
  Future<void> updateEspBaseUrl(String url) async {
    try {
      _settings = _settings.copyWith(espBaseUrl: url);
      notifyListeners();

      await _storageService.saveSettings(_settings);
    } catch (e) {
      _error = 'Failed to save ESP URL: $e';
      notifyListeners();
    }
  }

  /// Update dark mode
  Future<void> updateDarkMode(bool isDark) async {
    try {
      _settings = _settings.copyWith(isDarkMode: isDark);
      notifyListeners();

      await _storageService.saveSettings(_settings);
    } catch (e) {
      _error = 'Failed to save theme: $e';
      notifyListeners();
    }
  }

  /// Update language
  Future<void> updateLanguage(String languageCode) async {
    try {
      _settings = _settings.copyWith(language: languageCode);
      notifyListeners();

      await _storageService.saveSettings(_settings);
    } catch (e) {
      _error = 'Failed to save language: $e';
      notifyListeners();
    }
  }

  /// Reset to default settings
  Future<void> resetToDefaults() async {
    try {
      _settings = AppSettings();
      notifyListeners();

      await _storageService.saveSettings(_settings);
    } catch (e) {
      _error = 'Failed to reset settings: $e';
      notifyListeners();
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
