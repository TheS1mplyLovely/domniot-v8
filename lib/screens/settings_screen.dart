import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../providers/settings_provider.dart';
import '../providers/sensor_provider.dart';

/// Settings screen for configuring app preferences
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _urlController;
  late TextEditingController _targetRController;
  late TextEditingController _targetGController;
  late TextEditingController _targetBController;
  
  bool _isDarkMode = false;
  String _selectedLanguage = 'tr';
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>().settings;
    
    _urlController = TextEditingController(text: settings.espBaseUrl);
    _targetRController = TextEditingController(text: settings.targetR.toString());
    _targetGController = TextEditingController(text: settings.targetG.toString());
    _targetBController = TextEditingController(text: settings.targetB.toString());
    _isDarkMode = settings.isDarkMode;
    _selectedLanguage = settings.language;
  }

  @override
  void dispose() {
    _urlController.dispose();
    _targetRController.dispose();
    _targetGController.dispose();
    _targetBController.dispose();
    super.dispose();
  }

  void _markAsChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  Future<void> _saveSettings() async {
    final settingsProvider = context.read<SettingsProvider>();
    final sensorProvider = context.read<SensorProvider>();
    
    // Validate URL
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      _showError('Please enter ESP32 URL');
      return;
    }
    
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      _showError('URL must start with http:// or https://');
      return;
    }
    
    // Validate RGB values
    final r = int.tryParse(_targetRController.text);
    final g = int.tryParse(_targetGController.text);
    final b = int.tryParse(_targetBController.text);
    
    if (r == null || g == null || b == null) {
      _showError('RGB values must be numbers');
      return;
    }
    
    if (r < 0 || r > 255 || g < 0 || g > 255 || b < 0 || b > 255) {
      _showError('RGB values must be between 0 and 255');
      return;
    }
    
    // Save all settings
    await settingsProvider.updateTargetRgb(
      targetR: r,
      targetG: g,
      targetB: b,
    );
    
    await settingsProvider.updateEspBaseUrl(url);
    await settingsProvider.updateDarkMode(_isDarkMode);
    await settingsProvider.updateLanguage(_selectedLanguage);
    
    // Update ESP32 URL in sensor provider
    sensorProvider.updateBaseUrl(url);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
      
      setState(() {
        _hasChanges = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _showResetDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('Are you sure you want to reset all settings to defaults?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    
    if (result == true && mounted) {
      await context.read<SettingsProvider>().resetToDefaults();
      
      // Reset text controllers
      _urlController.text = AppConstants.defaultEspBaseUrl;
      _targetRController.text = AppConstants.defaultTargetR.toString();
      _targetGController.text = AppConstants.defaultTargetG.toString();
      _targetBController.text = AppConstants.defaultTargetB.toString();
      _isDarkMode = false;
      _selectedLanguage = AppConstants.defaultLanguage;
      
      setState(() {
        _hasChanges = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings reset to defaults'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _saveSettings,
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ESP32 URL Section
            _buildEsp32UrlSection(),
            
            const SizedBox(height: 16),
            
            // Target RGB Section
            _buildTargetRgbSection(),
            
            const SizedBox(height: 16),
            
            // Theme Section
            _buildThemeToggle(),
            
            const SizedBox(height: 16),
            
            // Language Section
            _buildLanguageSection(),
            
            const SizedBox(height: 16),
            
            // Reset Button
            OutlinedButton.icon(
              onPressed: _showResetDialog,
              icon: const Icon(Icons.restore),
              label: const Text('Reset to Defaults'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // App Info Section
            _buildAppInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildEsp32UrlSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ESP32 Configuration',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'ESP32 Base URL',
                hintText: 'http://192.168.1.100',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.wifi),
              ),
              keyboardType: TextInputType.url,
              onChanged: (_) => _markAsChanged(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetRgbSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Target RGB Values (Calibration)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Set the RGB values for a healthy plant',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildRgbTextField(
                    controller: _targetRController,
                    label: 'Red (R)',
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildRgbTextField(
                    controller: _targetGController,
                    label: 'Green (G)',
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildRgbTextField(
                    controller: _targetBController,
                    label: 'Blue (B)',
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Color Preview
            Builder(
              builder: (context) {
                final r = int.tryParse(_targetRController.text) ?? 0;
                final g = int.tryParse(_targetGController.text) ?? 0;
                final b = int.tryParse(_targetBController.text) ?? 0;
                
                return Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(r.clamp(0, 255), g.clamp(0, 255), b.clamp(0, 255), 1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  child: Center(
                    child: Text(
                      'Target Color Preview',
                      style: TextStyle(
                        color: (r + g + b) / 3 > 128 ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRgbTextField({
    required TextEditingController controller,
    required String label,
    required Color color,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(Icons.colorize, color: color),
      ),
      keyboardType: TextInputType.number,
      onChanged: (_) => _markAsChanged(),
    );
  }

  Widget _buildThemeToggle() {
    return Card(
      child: SwitchListTile(
        title: const Text('Dark Mode'),
        subtitle: Text(_isDarkMode ? 'Dark theme enabled' : 'Light theme enabled'),
        secondary: Icon(
          _isDarkMode ? Icons.dark_mode : Icons.light_mode,
          color: _isDarkMode ? Colors.amber : Colors.orange,
        ),
        value: _isDarkMode,
        onChanged: (value) {
          setState(() {
            _isDarkMode = value;
            _hasChanges = true;
          });
        },
      ),
    );
  }

  Widget _buildLanguageSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Language / Dil / Язык',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedLanguage,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.language),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'tr',
                  child: Text('Türkçe'),
                ),
                DropdownMenuItem(
                  value: 'en',
                  child: Text('English'),
                ),
                DropdownMenuItem(
                  value: 'ru',
                  child: Text('Русский'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedLanguage = value;
                    _hasChanges = true;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'App Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('App Name', AppConstants.appName),
            _buildInfoRow('Version', AppConstants.appVersion),
            _buildInfoRow('Developer', AppConstants.developer),
            _buildInfoRow('Team', AppConstants.team),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
