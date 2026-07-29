import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = ElevatedButton.styleFrom(
      backgroundColor: isPrimary ? AppColors.accent : Colors.transparent,
      foregroundColor: isPrimary ? Colors.white : AppColors.accent,
      elevation: isPrimary ? 3 : 0,
      side: isPrimary ? BorderSide.none : const BorderSide(color: AppColors.accent, width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
    );

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: style,
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text.toUpperCase(),
                style: AppTextStyles.subheading.copyWith(
                  color: isPrimary ? Colors.white : AppColors.accent,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
