import 'package:flutter/material.dart';
import 'package:fluttertest/configs/theme/app_colors.dart';

enum AppSnackBarType { success, error, info, warning }

class AppSnackBar {
  const AppSnackBar._();

  static void show(
    BuildContext context, {
    required String message,
    AppSnackBarType type = AppSnackBarType.info,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    final Color backgroundColor = switch (type) {
      AppSnackBarType.success => AppColors.success,
      AppSnackBarType.error => AppColors.error,
      AppSnackBarType.info => AppColors.info,
      AppSnackBarType.warning => AppColors.warning,
    };

    final IconData leadingIcon = switch (type) {
      AppSnackBarType.success => Icons.check_circle_rounded,
      AppSnackBarType.error => Icons.error_rounded,
      AppSnackBarType.info => Icons.info_rounded,
      AppSnackBarType.warning => Icons.warning_amber_rounded,
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(leadingIcon, color: AppColors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null && title.trim().isNotEmpty)
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    Text(
                      message,
                      style: const TextStyle(color: AppColors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          duration: duration,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  static void showError(BuildContext context, String message) {
    show(
      context,
      message: message,
      type: AppSnackBarType.error,
      title: 'Gagal',
    );
  }

  static void showSuccess(BuildContext context, String message) {
    show(
      context,
      message: message,
      type: AppSnackBarType.success,
      title: 'Berhasil',
    );
  }

  static void showInfo(BuildContext context, String message) {
    show(context, message: message, type: AppSnackBarType.info);
  }

  static void showWarning(BuildContext context, String message) {
    show(context, message: message, type: AppSnackBarType.warning);
  }
}
