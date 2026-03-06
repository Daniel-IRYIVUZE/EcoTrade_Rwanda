import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Ecotrade';
  static const String version = '1.0.0';
  
  // Colors
  static const Color primaryColor = Color(0xFF0F4C3A);
  static const Color secondaryColor = Color(0xFF10B981);
  static const Color accentColor = Color(0xFF059669);
  
  // Kigali coordinates
  static const double kigaliLat = -1.9441;
  static const double kigaliLng = 30.0619;
  
  // API endpoints
  static const String baseUrl = 'https://api.ecotrade.rw';
  
  // Storage keys
  static const String userDataKey = 'user_data';
  static const String authTokenKey = 'auth_token';
  static const String firstLaunchKey = 'is_first_launch';
}