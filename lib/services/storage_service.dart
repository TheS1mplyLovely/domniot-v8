import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../models/app_settings.dart';

/// Service for handling local storage using SharedPreferences
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;
  bool _isInitialized = false;

  /// Initialize storage service
  Future<void> initialize() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
  }

  /// Ensure initialized
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  // ==================== App Settings ====================

  /// Save app settings
  Future<bool> saveSettings(AppSettings settings) async {
    await _ensureInitialized();
    
    try {
      await Future.wait([
        _prefs!.setInt(AppConstants.keyTargetR, settings.targetR),
        _prefs!.setInt(AppConstants.keyTargetG, settings.targetG),
        _prefs!.setInt(AppConstants.keyTargetB, settings.targetB),
        _prefs!.setString(AppConstants.keyEspBaseUrl, settings.espBaseUrl),
        _prefs!.setBool(AppConstants.keyDarkMode, settings.isDarkMode),
        _prefs!.setString(AppConstants.keyLanguage, settings.language),
      ]);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Load app settings
  Future<AppSettings> loadSettings() async {
    await _ensureInitialized();
    
    return AppSettings(
      targetR: _prefs!.getInt(AppConstants.keyTargetR) ?? AppConstants.defaultTargetR,
      targetG: _prefs!.getInt(AppConstants.keyTargetG) ?? AppConstants.defaultTargetG,
      targetB: _prefs!.getInt(AppConstants.keyTargetB) ?? AppConstants.defaultTargetB,
      espBaseUrl: _prefs!.getString(AppConstants.keyEspBaseUrl) ?? AppConstants.defaultEspBaseUrl,
      isDarkMode: _prefs!.getBool(AppConstants.keyDarkMode) ?? false,
      language: _prefs!.getString(AppConstants.keyLanguage) ?? AppConstants.defaultLanguage,
    );
  }

  // ==================== Individual Settings ====================

  /// Save target R value
  Future<bool> saveTargetR(int value) async {
    await _ensureInitialized();
    return await _prefs!.setInt(AppConstants.keyTargetR, value.clamp(0, 255));
  }

  /// Save target G value
  Future<bool> saveTargetG(int value) async {
    await _ensureInitialized();
    return await _prefs!.setInt(AppConstants.keyTargetG, value.clamp(0, 255));
  }

  /// Save target B value
  Future<bool> saveTargetB(int value) async {
    await _ensureInitialized();
    return await _prefs!.setInt(AppConstants.keyTargetB, value.clamp(0, 255));
  }

  /// Save ESP base URL
  Future<bool> saveEspBaseUrl(String url) async {
    await _ensureInitialized();
    return await _prefs!.setString(AppConstants.keyEspBaseUrl, url);
  }

  /// Save dark mode preference
  Future<bool> saveDarkMode(bool isDark) async {
    await _ensureInitialized();
    return await _prefs!.setBool(AppConstants.keyDarkMode, isDark);
  }

  /// Save language preference
  Future<bool> saveLanguage(String languageCode) async {
    await _ensureInitialized();
    return await _prefs!.setString(AppConstants.keyLanguage, languageCode);
  }

  /// Load target R value
  Future<int> loadTargetR() async {
    await _ensureInitialized();
    return _prefs!.getInt(AppConstants.keyTargetR) ?? AppConstants.defaultTargetR;
  }

  /// Load target G value
  Future<int> loadTargetG() async {
    await _ensureInitialized();
    return _prefs!.getInt(AppConstants.keyTargetG) ?? AppConstants.defaultTargetG;
  }

  /// Load target B value
  Future<int> loadTargetB() async {
    await _ensureInitialized();
    return _prefs!.getInt(AppConstants.keyTargetB) ?? AppConstants.defaultTargetB;
  }

  /// Load ESP base URL
  Future<String> loadEspBaseUrl() async {
    await _ensureInitialized();
    return _prefs!.getString(AppConstants.keyEspBaseUrl) ?? AppConstants.defaultEspBaseUrl;
  }

  /// Load dark mode preference
  Future<bool> loadDarkMode() async {
    await _ensureInitialized();
    return _prefs!.getBool(AppConstants.keyDarkMode) ?? false;
  }

  /// Load language preference
  Future<String> loadLanguage() async {
    await _ensureInitialized();
    return _prefs!.getString(AppConstants.keyLanguage) ?? AppConstants.defaultLanguage;
  }

  // ==================== Utility Methods ====================

  /// Clear all stored data
  Future<bool> clearAll() async {
    await _ensureInitialized();
    return await _prefs!.clear();
  }

  /// Check if settings exist
  Future<bool> hasSettings() async {
    await _ensureInitialized();
    return _prefs!.containsKey(AppConstants.keyTargetR);
  }
}
