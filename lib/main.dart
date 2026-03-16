import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/constants.dart';
import 'core/theme.dart';
import 'core/localization.dart';
import 'providers/settings_provider.dart';
import 'providers/sensor_provider.dart';
import 'providers/rgb_analysis_provider.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'screens/splash_screen.dart';

/// Main entry point for DOMINOiT application
void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  // Initialize services
  await _initializeServices();
  
  // Run the app
  runApp(const DominoApp());
}

/// Initialize all required services
Future<void> _initializeServices() async {
  // Initialize storage service
  await StorageService().initialize();
  
  // Initialize notification service
  await NotificationService().initialize();
}

/// Main application widget
class DominoApp extends StatelessWidget {
  const DominoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Settings Provider - manages app settings
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(),
        ),
        
        // Sensor Provider - manages ESP32 sensor data
        ChangeNotifierProvider(
          create: (_) => SensorProvider(),
        ),
        
        // RGB Analysis Provider - manages plant RGB analysis
        ChangeNotifierProvider(
          create: (_) => RgbAnalysisProvider(),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            
            // Localization configuration
            locale: settingsProvider.locale,
            supportedLocales: const [
              Locale('tr'),
              Locale('en'),
              Locale('ru'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            
            // Theme configuration
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsProvider.settings.isDarkMode 
                ? ThemeMode.dark 
                : ThemeMode.light,
            
            // Initial route
            home: const SplashScreen(),
            
            // Error handling
            builder: (context, widget) {
              // Global error handling wrapper
              return ErrorWidget.builder = (errorDetails) {
                return Scaffold(
                  body: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Something went wrong',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            errorDetails.exception.toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              };
              
              return widget ?? const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
}
