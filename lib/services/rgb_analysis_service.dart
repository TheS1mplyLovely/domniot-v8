import 'dart:io';
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import '../models/rgb_analysis.dart';

/// Service for analyzing plant RGB from camera images
class RgbAnalysisService {
  static final RgbAnalysisService _instance = RgbAnalysisService._internal();
  factory RgbAnalysisService() => _instance;
  RgbAnalysisService._internal();

  final ImagePicker _picker = ImagePicker();

  /// Capture image from camera
  Future<File?> captureImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      throw RgbAnalysisException('Failed to capture image: $e');
    }
  }

  /// Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      throw RgbAnalysisException('Failed to pick image: $e');
    }
  }

  /// Analyze RGB from image file
  Future<RgbAnalysis> analyzeImage(
    File imageFile, {
    required int targetR,
    required int targetG,
    required int targetB,
  }) async {
    try {
      // Read image bytes
      final bytes = await imageFile.readAsBytes();
      
      // Decode image
      final image = img.decodeImage(bytes);
      if (image == null) {
        throw RgbAnalysisException('Failed to decode image');
      }

      // Sample pixels from the center region (focus on plant)
      final sampledRgb = _samplePixels(image);
      
      // Calculate stress score
      final stressScore = _calculateStressScore(
        sampledRgb['r']!,
        sampledRgb['g']!,
        sampledRgb['b']!,
        targetR,
        targetG,
        targetB,
      );

      return RgbAnalysis(
        averageR: sampledRgb['r']!,
        averageG: sampledRgb['g']!,
        averageB: sampledRgb['b']!,
        targetR: targetR,
        targetG: targetG,
        targetB: targetB,
        stressScore: stressScore,
        imagePath: imageFile.path,
      );
    } catch (e) {
      if (e is RgbAnalysisException) rethrow;
      throw RgbAnalysisException('Failed to analyze image: $e');
    }
  }

  /// Sample pixels from the center of the image
  Map<String, int> _samplePixels(img.Image image) {
    // Define sampling region (center 60% of image)
    final startX = (image.width * 0.2).toInt();
    final endX = (image.width * 0.8).toInt();
    final startY = (image.height * 0.2).toInt();
    final endY = (image.height * 0.8).toInt();

    int totalR = 0;
    int totalG = 0;
    int totalB = 0;
    int pixelCount = 0;

    // Sample every 4th pixel for performance
    for (int y = startY; y < endY; y += 4) {
      for (int x = startX; x < endX; x += 4) {
        final pixel = image.getPixel(x, y);
        
        // Get RGB values
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();

        // Skip very dark or very light pixels (likely background)
        final brightness = (r + g + b) / 3;
        if (brightness > 20 && brightness < 235) {
          totalR += r;
          totalG += g;
          totalB += b;
          pixelCount++;
        }
      }
    }

    if (pixelCount == 0) {
      // Fallback: sample entire image
      return _sampleEntireImage(image);
    }

    return {
      'r': (totalR / pixelCount).round(),
      'g': (totalG / pixelCount).round(),
      'b': (totalB / pixelCount).round(),
    };
  }

  /// Fallback: sample entire image
  Map<String, int> _sampleEntireImage(img.Image image) {
    int totalR = 0;
    int totalG = 0;
    int totalB = 0;
    int pixelCount = 0;

    for (int y = 0; y < image.height; y += 8) {
      for (int x = 0; x < image.width; x += 8) {
        final pixel = image.getPixel(x, y);
        totalR += pixel.r.toInt();
        totalG += pixel.g.toInt();
        totalB += pixel.b.toInt();
        pixelCount++;
      }
    }

    return {
      'r': (totalR / pixelCount).round(),
      'g': (totalG / pixelCount).round(),
      'b': (totalB / pixelCount).round(),
    };
  }

  /// Calculate stress score (1-10) based on color difference
  int _calculateStressScore(
    int avgR,
    int avgG,
    int avgB,
    int targetR,
    int targetG,
    int targetB,
  ) {
    // Calculate Euclidean distance in RGB space
    final diffR = avgR - targetR;
    final diffG = avgG - targetG;
    final diffB = avgB - targetB;
    
    final distance = sqrt(diffR * diffR + diffG * diffG + diffB * diffB);
    
    // Maximum expected difference (white to black)
    const maxDistance = 441.67; // sqrt(255^2 * 3)
    
    // Normalize distance to 0-1
    final normalizedDiff = (distance / maxDistance).clamp(0.0, 1.0);
    
    // Convert to stress score (inverted - higher diff = higher stress)
    // Score: 10 = no stress, 1 = maximum stress
    final score = ((1 - normalizedDiff) * 9 + 1).round();
    
    return score.clamp(1, 10);
  }

  /// Get simulated analysis for testing
  RgbAnalysis getSimulatedAnalysis({
    required int targetR,
    required int targetG,
    required int targetB,
  }) {
    // Generate slightly varied RGB values
    final random = Random();
    final variation = random.nextInt(60) - 30;
    
    return RgbAnalysis(
      averageR: (targetR + variation).clamp(0, 255),
      averageG: (targetG + variation).clamp(0, 255),
      averageB: (targetB + variation).clamp(0, 255),
      targetR: targetR,
      targetG: targetG,
      targetB: targetB,
      stressScore: 5 + random.nextInt(6), // 5-10
    );
  }
}

/// Custom exception for RGB analysis errors
class RgbAnalysisException implements Exception {
  final String message;
  RgbAnalysisException(this.message);

  @override
  String toString() => message;
}
