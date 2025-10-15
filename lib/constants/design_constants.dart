import 'package:flutter/material.dart';

class DesignConstants {
  // Colors
  static const primaryColor = Color(0xFFE94057);
  static const secondaryColor = Color(0xFFF27121);
  static const backgroundColor = Color(0xFFF8F9FA);
  static const cardColor = Colors.white;
  static const textPrimary = Color(0xFF333333);
  static const textSecondary = Color(0xFF666666);
  static const textLight = Color(0xFF999999);

  // Gradients
  static const primaryGradient = LinearGradient(
    colors: [secondaryColor, primaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadows
  static const cardShadow = BoxShadow(
    color: Colors.black12,
    blurRadius: 8,
    offset: Offset(0, 2),
  );

  // Border Radius
  static const cardBorderRadius = 16.0;
  static const buttonBorderRadius = 12.0;
  static const chipBorderRadius = 20.0;

  // Spacing
  static const screenPadding = 16.0;
  static const sectionSpacing = 24.0;
  static const itemSpacing = 12.0;
}