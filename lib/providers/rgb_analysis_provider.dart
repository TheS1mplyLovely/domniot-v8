import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/rgb_analysis.dart';
import '../services/rgb_analysis_service.dart';
import '../services/notification_service.dart';
import '../core/constants.dart';

/// Provider for managing RGB analysis state
class RgbAnalysisProvider extends ChangeNotifier {
  final RgbAnalysisService _rgbService = RgbAnalysisService();
  final NotificationService _notificationService = NotificationService();
  
  RgbAnalysis? _analysis;
  bool _isAnalyzing = false;
  String? _error;
  File? _capturedImage;

  /// Get current analysis
  RgbAnalysis? get analysis => _analysis;
  
  /// Check if analyzing
  bool get isAnalyzing => _isAnalyzing;
  
  /// Get error message
  String? get error => _error;
  
  /// Get captured image
  File? get capturedImage => _capturedImage;

  /// Capture image from camera
  Future<void> captureImage() async {
    _error = null;
    
    try {
      final image = await _rgbService.captureImage();
      if (image != null) {
        _capturedImage = image;
        notifyListeners();
      }
    } on Exception catch (e) {
      _error = 'Failed to capture image: $e';
      notifyListeners();
    }
  }

  /// Pick image from gallery
  Future<void> pickImage() async {
    _error = null;
    
    try {
      final image = await _rgbService.pickImageFromGallery();
      if (image != null) {
        _capturedImage = image;
        notifyListeners();
      }
    } on Exception catch (e) {
      _error = 'Failed to pick image: $e';
      notifyListeners();
    }
  }

  /// Analyze captured image
  Future<void> analyzeImage({
    required int targetR,
    required int targetG,
    required int targetB,
    bool useSimulation = false,
  }) async {
    _isAnalyzing = true;
    _error = null;
    notifyListeners();

    try {
      if (useSimulation || _capturedImage == null) {
        // Use simulated analysis
        await Future.delayed(const Duration(seconds: 1));
        _analysis = _rgbService.getSimulatedAnalysis(
          targetR: targetR,
          targetG: targetG,
          targetB: targetB,
        );
      } else {
        // Analyze actual image
        _analysis = await _rgbService.analyzeImage(
          _capturedImage!,
          targetR: targetR,
          targetG: targetG,
          targetB: targetB,
        );
      }
      
      // Check for stress notification
      await _checkStressNotification();
      
      _isAnalyzing = false;
      notifyListeners();
    } on RgbAnalysisException catch (e) {
      _error = e.message;
      _isAnalyzing = false;
      notifyListeners();
    } catch (e) {
      _error = 'Analysis failed: $e';
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  /// Check stress level and send notification if needed
  Future<void> _checkStressNotification() async {
    if (_analysis == null) return;

    // Send notification if stress is high
    if (_analysis!.stressScore < AppConstants.highStressThreshold) {
      await _notificationService.showStressNotification(_analysis!.stressScore);
    }
  }

  /// Run simulation analysis
  Future<void> runSimulation({
    required int targetR,
    required int targetG,
    required int targetB,
  }) async {
    await analyzeImage(
      targetR: targetR,
      targetG: targetG,
      targetB: targetB,
      useSimulation: true,
    );
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear analysis and image
  void clearAnalysis() {
    _analysis = null;
    _capturedImage = null;
    _error = null;
    notifyListeners();
  }

  /// Clear only the captured image
  void clearImage() {
    _capturedImage = null;
    notifyListeners();
  }
}
