import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Global Application Configuration
/// Single toggle [useFakeData] allows switching seamlessly between
/// Mock Repository (offline demo/testing) and Real ASP.NET Core API.
class AppConfig {
  static const String appTitle = 'Shiftly';
  
  // TOGGLE: Switch to false when linking with real ASP.NET Core backend
  static const bool useFakeData = false;

  // API Base URL for ASP.NET Core Web API
  // Automatically uses 10.0.2.2 on Android (for Emulator to reach host PC)
  // and localhost on Windows/Desktop.
  static String get apiBaseUrl {
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:5050/api';
    }
    return 'http://localhost:5050/api';
  }

  // Branch Geofence default in meters (50 meters as agreed)
  static double branchRadiusMeters = 50.0;

  // Lateness Ladder Grace Period in minutes
  static const int gracePeriodMinutes = 15;
}
