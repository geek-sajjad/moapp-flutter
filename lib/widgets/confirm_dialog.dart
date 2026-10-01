import 'package:flutter/material.dart';

import '../theme/app_icons.dart';

/// Port of the web `app-confirm-dialog` as an M3 alert dialog.
/// Resolves to `true` on "yes".
Future<bool> showConfirmDialog({
  required BuildContext context,
  required String message,
  String confirmText = 'بله، حذف شود',
  String cancelText = 'خیر',
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      final scheme = Theme.of(dialogContext).colorScheme;
      return AlertDialog(
        icon: Icon(AppIcons.warning, color: scheme.error, size: 32),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(dialogContext).textTheme.bodyLarge?.copyWith(height: 1.7),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(cancelText),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: scheme.error,
              foregroundColor: scheme.onError,
              minimumSize: const Size(64, 40),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(confirmText),
          ),
        ],
      );
    },
  );
  return result ?? false;
}
