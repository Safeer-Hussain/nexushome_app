import 'package:flutter/material.dart';

class AppFeedback {
  AppFeedback._();

  static void showSuccess(BuildContext context, String message) {
    _showSnackBar(
      context,
      message: message,
      icon: Icons.check_circle_outline,
      isSuccess: true,
    );
  }

  static void showWarning(BuildContext context, String message) {
    _showSnackBar(
      context,
      message: message,
      icon: Icons.warning_amber_rounded,
      isWarning: true,
    );
  }

  static void showError(BuildContext context, String message) {
    _showSnackBar(
      context,
      message: message,
      icon: Icons.error_outline_rounded,
      isError: true,
    );
  }

  static void showInfo(BuildContext context, String message) {
    _showSnackBar(context, message: message, icon: Icons.info_outline_rounded);
  }

  static void _showSnackBar(
    BuildContext context, {
    required String message,
    required IconData icon,
    bool isSuccess = false,
    bool isWarning = false,
    bool isError = false,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    final colorScheme = Theme.of(context).colorScheme;

    Color bg;
    Color fg;

    if (isSuccess) {
      bg = colorScheme.primaryContainer;
      fg = colorScheme.onPrimaryContainer;
    } else if (isWarning) {
      bg = colorScheme.secondaryContainer;
      fg = colorScheme.onSecondaryContainer;
    } else if (isError) {
      bg = colorScheme.errorContainer;
      fg = colorScheme.onErrorContainer;
    } else {
      bg = colorScheme.surfaceContainerHighest;
      fg = colorScheme.onSurface;
    }

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 4,
        backgroundColor: bg,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: fg.withValues(alpha: 0.2)),
        ),
        content: Row(
          children: [
            Icon(icon, color: fg, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
