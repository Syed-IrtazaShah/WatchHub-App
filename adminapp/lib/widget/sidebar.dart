import 'package:adminapp/utils/app_colors.dart';
import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isActive;
  final bool isCollapsed; // Optional collapsible state flag

  const Sidebar({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isActive = false,
    this.isCollapsed = false, // Default is expanded state
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          // Change color based on selection
          color: isActive
              ? AppColors.secondary.withAlpha(50)
              : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: AppColors.secondary,
              size: 22,
            ),
            // Show title text and spacing only if expanded
            if (!isCollapsed) ...[
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 16,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
