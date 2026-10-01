import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_icon.dart';

/// Port of the web `app-header`. The logout button (multi-user only) is
/// replaced by the offline backup button.
class AppHeader extends StatelessWidget {
  final VoidCallback onBackup;

  const AppHeader({super.key, required this.onBackup});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        gradient: cardHeaderGradient,
        border: Border(bottom: BorderSide(color: AppColors.gray300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.blue100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const AppIcon(
                  AppIconName.book,
                  size: 24,
                  color: AppColors.blue600,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'دفتر معین شخصی',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.gray900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'پشتیبان‌گیری',
            icon: AppIconName.database,
            iconSize: 16,
            variant: AppButtonVariant.outline,
            size: AppButtonSize.sm,
            onPressed: onBackup,
          ),
        ],
      ),
    );
  }
}
