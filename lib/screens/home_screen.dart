import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../providers/sensor_provider.dart';
import '../providers/rgb_analysis_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/sensor_card.dart';
import '../widgets/stress_card.dart';
import 'settings_screen.dart';
import 'rgb_capture_screen.dart';

/// Home screen displaying sensor data and stress score
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // Initialize sensor provider with settings
    final settingsProvider = context.read<SettingsProvider>();
    final sensorProvider = context.read<SensorProvider>();
    
    // Wait for settings to load
    await settingsProvider.initialize();
    
    // Update ESP32 URL from settings
    sensorProvider.updateBaseUrl(settingsProvider.settings.espBaseUrl);
    
    // Fetch initial sensor data
    await sensorProvider.fetchSensorData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          // Simulation mode toggle
          Consumer<SensorProvider>(
            builder: (context, sensorProvider, child) {
              return IconButton(
                icon: Icon(
                  sensorProvider.useSimulation 
                      ? Icons.science 
                      : Icons.science_outlined,
                  color: sensorProvider.useSimulation 
                      ? Colors.amber 
                      : Colors.white,
                ),
                tooltip: sensorProvider.useSimulation 
                    ? 'Simulation Mode ON' 
                    : 'Use Real ESP32',
                onPressed: () {
                  sensorProvider.toggleSimulationMode();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        sensorProvider.useSimulation
                            ? 'Simulation mode enabled'
                            : 'ESP32 mode enabled',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              );
            },
          ),
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final sensorProvider = context.read<SensorProvider>();
          await sensorProvider.fetchSensorData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sensor Data Card
              const SensorCard(),
              
              const SizedBox(height: 16),
              
              // Stress Score Card
              const StressCard(),
              
              const SizedBox(height: 24),
              
              // Action Buttons
              _buildActionButtons(),
              
              const SizedBox(height: 24),
              
              // Developer Info
              _buildDeveloperInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Capture Photo Button
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RgbCaptureScreen()),
            );
          },
          icon: const Icon(Icons.camera_alt),
          label: const Text('Capture Plant Photo'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: Colors.white,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Refresh ESP Data Button
        OutlinedButton.icon(
          onPressed: () async {
            final sensorProvider = context.read<SensorProvider>();
            await sensorProvider.fetchSensorData();
            
            if (sensorProvider.error != null && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(sensorProvider.error!),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh ESP Data'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildDeveloperInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Developed by',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            AppConstants.developer,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'from ${AppConstants.team}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
