/// Model class representing RGB analysis result
class RgbAnalysis {
  final int averageR;
  final int averageG;
  final int averageB;
  final int targetR;
  final int targetG;
  final int targetB;
  final int stressScore;
  final DateTime timestamp;
  final String? imagePath;

  RgbAnalysis({
    required this.averageR,
    required this.averageG,
    required this.averageB,
    required this.targetR,
    required this.targetG,
    required this.targetB,
    required this.stressScore,
    DateTime? timestamp,
    this.imagePath,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Calculate RGB difference from target
  int get colorDifference {
    final dr = averageR - targetR;
    final dg = averageG - targetG;
    final db = averageB - targetB;
    return (dr * dr + dg * dg + db * db).toInt();
  }

  /// Get the dominant color channel
  String get dominantChannel {
    if (averageR > averageG && averageR > averageB) return 'Red';
    if (averageG > averageR && averageG > averageB) return 'Green';
    return 'Blue';
  }

  /// Check if plant is stressed (score below threshold)
  bool get isStressed => stressScore < 4;

  /// Get analysis summary
  String get summary {
    if (stressScore >= 8) return 'Plant appears healthy';
    if (stressScore >= 6) return 'Plant shows minor stress';
    if (stressScore >= 4) return 'Plant is moderately stressed';
    return 'Plant requires immediate attention';
  }

  @override
  String toString() {
    return 'RgbAnalysis(avg: ($averageR, $averageG, $averageB), target: ($targetR, $targetG, $targetB), stress: $stressScore/10)';
  }
}
