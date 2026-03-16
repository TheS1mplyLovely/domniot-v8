import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/sensor_provider.dart';

/// Card widget displaying live sensor data from ESP32
class SensorCard extends StatelessWidget {
  const SensorCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SensorProvider>(
      builder: (context, sensorProvider, child) {
        final sensorData = sensorProvider.sensorData;
        final isLoading = sensorProvider.isLoading;
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    const Icon(Icons.sensors, color: AppTheme.primaryGreen),
                    const SizedBox(width: 8),
                    const Text(
                      'Live Sensor Data',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (sensorProvider.useSimulation)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.science, size: 14, color: Colors.amber),
                            SizedBox(width: 4),
                            Text(
                              'SIM',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                if (isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (sensorData == null)
                  _buildNoDataWidget(sensorProvider)
                else
                  _buildSensorData(sensorData, sensorProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoDataWidget(SensorProvider sensorProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            Icons.cloud_off,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            sensorProvider.error ?? 'No sensor data available',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Pull down to refresh or check ESP32 connection',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorData(sensorData, SensorProvider sensorProvider) {
    return Column(
      children: [
        // Sensor Values Grid
        Row(
          children: [
            Expanded(
              child: _buildSensorItem(
                icon: Icons.thermostat,
                label: 'Temperature',
                value: '${sensorData.temperature.toStringAsFixed(1)}°C',
                status: sensorData.temperatureStatus,
                statusColor: _getTemperatureColor(sensorData.temperature),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSensorItem(
                icon: Icons.water_drop,
                label: 'Humidity',
                value: '${sensorData.humidity}%',
                status: sensorData.humidityStatus,
                statusColor: _getHumidityColor(sensorData.humidity),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Soil Moisture (Full Width)
        _buildSensorItem(
          icon: Icons.grass,
          label: 'Soil Moisture',
          value: '${sensorData.soilMoisture}%',
          status: sensorData.soilMoistureStatus,
          statusColor: _getSoilMoistureColor(sensorData.soilMoisture),
          isFullWidth: true,
        ),
        
        const SizedBox(height: 12),
        
        // Last Updated
        if (sensorProvider.lastUpdated != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.access_time, size: 14, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Text(
                'Updated: ${_formatTime(sensorProvider.lastUpdated!)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildSensorItem({
    required IconData icon,
    required String label,
    required String value,
    required String status,
    required Color statusColor,
    bool isFullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: statusColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTemperatureColor(double temp) {
    if (temp < 15) return Colors.blue;
    if (temp > 30) return Colors.red;
    return AppTheme.primaryGreen;
  }

  Color _getHumidityColor(int humidity) {
    if (humidity < 30) return Colors.orange;
    if (humidity > 80) return Colors.blue;
    return AppTheme.primaryGreen;
  }

  Color _getSoilMoistureColor(int moisture) {
    if (moisture < 20) return Colors.red;
    if (moisture > 80) return Colors.blue;
    return AppTheme.primaryGreen;
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inSeconds < 60) {
      return '${diff.inSeconds}s ago';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}
