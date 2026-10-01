import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'app_button.dart';

/// Port of the web `app-confirm-dialog`. Resolves to `true` on "yes".
Future<bool> showConfirmDialog({
  required BuildContext context,
  required String message,
  String confirmText = 'بله، حذف شود',
  String cancelText = 'خیر',
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isDismissible: false,
    enableDrag: false,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.black.withValues(alpha: 0.6),
    builder: (sheetContext) => Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(
          top: BorderSide(color: AppColors.gray300),
          left: BorderSide(color: AppColors.gray300),
          right: BorderSide(color: AppColors.gray300),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(sheetContext).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.red50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              size: 32,
              color: AppColors.red600,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.gray900,
                height: 1.6,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: cancelText,
                    variant: AppButtonVariant.outline,
                    size: AppButtonSize.lg,
                    fullWidth: true,
                    onPressed: () => Navigator.of(sheetContext).pop(false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: confirmText,
                    variant: AppButtonVariant.destructive,
                    size: AppButtonSize.lg,
                    fullWidth: true,
                    onPressed: () => Navigator.of(sheetContext).pop(true),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
  return result ?? false;
}
