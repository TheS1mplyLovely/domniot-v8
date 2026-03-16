import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/rgb_analysis_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/sensor_provider.dart';

/// Screen for capturing and analyzing plant RGB
class RgbCaptureScreen extends StatefulWidget {
  const RgbCaptureScreen({super.key});

  @override
  State<RgbCaptureScreen> createState() => _RgbCaptureScreenState();
}

class _RgbCaptureScreenState extends State<RgbCaptureScreen> {
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Initialize settings if not already done
    final settingsProvider = context.read<SettingsProvider>();
    if (settingsProvider.settings.espBaseUrl.isEmpty) {
      await settingsProvider.initialize();
    }
  }

  Future<void> _captureImage() async {
    final rgbProvider = context.read<RgbAnalysisProvider>();
    await rgbProvider.captureImage();
    
    if (rgbProvider.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(rgbProvider.error!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    final rgbProvider = context.read<RgbAnalysisProvider>();
    await rgbProvider.pickImage();
    
    if (rgbProvider.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(rgbProvider.error!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _analyzeImage() async {
    final settingsProvider = context.read<SettingsProvider>();
    final rgbProvider = context.read<RgbAnalysisProvider>();
    final sensorProvider = context.read<SensorProvider>();
    
    await rgbProvider.analyzeImage(
      targetR: settingsProvider.settings.targetR,
      targetG: settingsProvider.settings.targetG,
      targetB: settingsProvider.settings.targetB,
      useSimulation: sensorProvider.useSimulation,
    );
    
    if (rgbProvider.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(rgbProvider.error!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _runSimulation() async {
    final settingsProvider = context.read<SettingsProvider>();
    final rgbProvider = context.read<RgbAnalysisProvider>();
    
    await rgbProvider.runSimulation(
      targetR: settingsProvider.settings.targetR,
      targetG: settingsProvider.settings.targetG,
      targetB: settingsProvider.settings.targetB,
    );
  }

  void _clearAnalysis() {
    final rgbProvider = context.read<RgbAnalysisProvider>();
    rgbProvider.clearAnalysis();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant RGB Analysis'),
        actions: [
          Consumer<RgbAnalysisProvider>(
            builder: (context, rgbProvider, child) {
              if (rgbProvider.analysis != null || rgbProvider.capturedImage != null) {
                return IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearAnalysis,
                  tooltip: 'Clear',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer2<RgbAnalysisProvider, SettingsProvider>(
        builder: (context, rgbProvider, settingsProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image Preview or Placeholder
                _buildImageSection(rgbProvider),
                
                const SizedBox(height: 20),
                
                // Capture Controls
                _buildCaptureControls(rgbProvider),
                
                const SizedBox(height: 20),
                
                // Analysis Result
                if (rgbProvider.analysis != null) ...[
                  _buildAnalysisResult(rgbProvider),
                ],
                
                const SizedBox(height: 20),
                
                // Target RGB Info
                _buildTargetInfo(settingsProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageSection(RgbAnalysisProvider rgbProvider) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: rgbProvider.capturedImage != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                rgbProvider.capturedImage!,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.eco,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Capture or select a plant image',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCaptureControls(RgbAnalysisProvider rgbProvider) {
    final isLoading = rgbProvider.isAnalyzing;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Capture Buttons Row
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _captureImage,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Camera'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isLoading ? null : _pickImage,
                icon: const Icon(Icons.photo_library),
                label: const Text('Gallery'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Analyze Button
        ElevatedButton.icon(
          onPressed: isLoading || rgbProvider.capturedImage == null ? null : _analyzeImage,
          icon: isLoading 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.analytics),
          label: Text(isLoading ? 'Analyzing...' : 'Analyze Plant'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryGreen,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Simulation Button
        Consumer<SensorProvider>(
          builder: (context, sensorProvider, child) {
            if (sensorProvider.useSimulation) {
              return OutlinedButton.icon(
                onPressed: isLoading ? null : _runSimulation,
                icon: const Icon(Icons.science),
                label: const Text('Run Simulation'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.amber[700],
                  side: BorderSide(color: Colors.amber[700]!),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildAnalysisResult(RgbAnalysisProvider rgbProvider) {
    final analysis = rgbProvider.analysis!;
    final stressColor = AppTheme.getStressColor(analysis.stressScore);
    final stressLabel = AppTheme.getStressLabel(analysis.stressScore);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.eco, color: AppTheme.primaryGreen),
                const SizedBox(width: 8),
                const Text(
                  'Analysis Result',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Stress Score Display
            Center(
              child: Column(
                children: [
                  // Score Circle
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: stressColor.withOpacity(0.2),
                      border: Border.all(color: stressColor, width: 4),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${analysis.stressScore}',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: stressColor,
                            ),
                          ),
                          Text(
                            '/10',
                            style: TextStyle(
                              fontSize: 16,
                              color: stressColor.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Status Label
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: stressColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      stressLabel,
                      style: TextStyle(
                        color: stressColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Progress Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Stress Level',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: analysis.stressScore / 10,
                    minHeight: 12,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation(stressColor),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // RGB Comparison
            const Text(
              'RGB Comparison',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                // Captured RGB
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Captured',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildRgbIndicator('R', analysis.averageR, Colors.red),
                            const SizedBox(width: 8),
                            _buildRgbIndicator('G', analysis.averageG, Colors.green),
                            const SizedBox(width: 8),
                            _buildRgbIndicator('B', analysis.averageB, Colors.blue),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Arrow
                const Icon(Icons.arrow_forward, color: Colors.grey),
                
                const SizedBox(width: 12),
                
                // Target RGB
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Target',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildRgbIndicator('R', analysis.targetR, Colors.red),
                            const SizedBox(width: 8),
                            _buildRgbIndicator('G', analysis.targetG, Colors.green),
                            const SizedBox(width: 8),
                            _buildRgbIndicator('B', analysis.targetB, Colors.blue),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: stressColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: stressColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    analysis.isStressed ? Icons.warning : Icons.check_circle,
                    color: stressColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      analysis.summary,
                      style: TextStyle(
                        color: stressColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Notification hint
            if (analysis.isStressed) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.notifications_active, color: Colors.orange),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Notification will be sent for high stress levels.',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRgbIndicator(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTargetInfo(SettingsProvider settingsProvider) {
    final settings = settingsProvider.settings;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.tune, color: Colors.grey),
                const SizedBox(width: 8),
                const Text(
                  'Target RGB (from Settings)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTargetRgbDisplay('R', settings.targetR, Colors.red),
                const SizedBox(width: 20),
                _buildTargetRgbDisplay('G', settings.targetG, Colors.green),
                const SizedBox(width: 20),
                _buildTargetRgbDisplay('B', settings.targetB, Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetRgbDisplay(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
