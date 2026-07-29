import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF000000);        // Black — buttons, headers, appbars
  static const Color secondary = Color(0xFFC9A15A);      // Luxury Gold — highlights, stars, dynamic buttons
  static const Color bgcolor = Color(0xFFF7F5F2);        // Off-white app background
  static const Color cardBackground = Color(0xFFFFFFFF);  // White cards
  static const Color textPrimary = Color(0xFF1A1A1A);    // Dark Charcoal for main headings
  static const Color textSecondary = Color(0xFF6B6B6B);  // Medium Grey for descriptions
  static const Color success = Color(0xFF2E7D32);        // Dark green for positive statuses
  static const Color danger = Color(0xFFD32F2F);         // Red for error/delete states

  // Legacy fallback compatibility fields
  static const Color dark = Color(0xFF000000);
  static const Color info = Color(0xFFC9A15A);
  static const Color barcolor = Color(0xFF6B6B6B);
}
