import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Main headings (e.g. AppBar title, Section title)
  static TextStyle get heading => GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  // Subheadings (e.g. Card Title, Buttons)
  static TextStyle get subheading => GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  // Normal body text descriptions
  static TextStyle get body => GoogleFonts.outfit(
        fontSize: 14,
        color: AppColors.textSecondary,
      );

  // Bold price tags
  static TextStyle get price => GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      );
}
