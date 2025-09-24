import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'FestiveLink';
  static const String appVersion = '1.0.0';

  // Colors
  static const Color primaryColor = Color(0xFFE91E63);
  static const Color secondaryColor = Color(0xFFF8BBD9);
  static const Color accentColor = Color(0xFF673AB7);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFE53E3E);
  static const Color successColor = Color(0xFF38A169);

  // Text Colors
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color textLight = Color(0xFFA0AEC0);

  // Profile Types
  static const List<String> profileTypes = [
    'Dating',
    'Networking', 
    'Friendship'
  ];

  // Interests
  static const List<String> interests = [
    '🎵 Music', '💃 Dance', '💻 Tech', '🎨 Art', '🎮 Gaming', 
    '⚽ Sports', '📚 Reading', '🎬 Movies', '📸 Photography', 
    '✈️ Travel', '🍕 Food', '👗 Fashion', '💪 Fitness', 
    '🌿 Nature', '😂 Comedy', '🍷 Wine', '🏖️ Beach', 
    '🎭 Theater', '🎸 Guitar', '🏃 Running', '🎯 Darts',
    '🎲 Board Games', '🍳 Cooking', '🧘 Yoga', '📱 Apps'
  ];

  // Dimensions
  static const double borderRadius = 12.0;
  static const double cardElevation = 4.0;
  static const EdgeInsets defaultPadding = EdgeInsets.all(16.0);
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 24.0);

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Grid Settings
  static const int userGridCrossAxisCount = 2;
  static const double userGridAspectRatio = 0.75;
  static const double userGridSpacing = 12.0;
}


class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.primaryColor,
        brightness: Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: AppConstants.primaryColor,
        unselectedItemColor: AppConstants.textSecondary,
        type: BottomNavigationBarType.fixed,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: AppConstants.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(color: AppConstants.primaryColor, width: 2),
        ),
      ),
    );
  }
}

