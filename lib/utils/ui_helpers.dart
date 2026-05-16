import 'package:flutter/material.dart';
import '../constants/colors.dart';

class UiHelpers {
  static void showSnack(BuildContext context, String message, {bool isError = false, bool isSuccess = false, IconData? icon}) {
    Color baseColor = AppColors.accent;
    IconData baseIcon = Icons.info_outline;

    if (isError) {
      baseColor = AppColors.red;
      baseIcon = Icons.error_outline;
    } else if (isSuccess) {
      baseColor = AppColors.green;
      baseIcon = Icons.check_circle_outline;
    }

    if (icon != null) {
      baseIcon = icon;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(baseIcon, color: baseColor, size: 20),
            SizedBox(width: 10),
            Expanded(child: Text(message, style: TextStyle(color: AppColors.white, fontSize: 13, fontWeight: FontWeight.w500))),
          ],
        ),
        backgroundColor: AppColors.bg3,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: baseColor.withValues(alpha: 0.5), width: 1),
        ),
        elevation: 0,
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
