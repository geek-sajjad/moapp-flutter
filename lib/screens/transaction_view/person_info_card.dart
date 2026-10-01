import 'package:flutter/material.dart';

import '../../models/customer.dart';
import '../../models/ledger_transaction.dart';
import '../../theme/app_colors.dart';
import '../../utils/persian_format.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/entry_animation.dart';

/// Port of the web `app-person-info-card` (customer info + balance).
class PersonInfoCard extends StatelessWidget {
  final Customer customer;
  final TransactionSummary summary;
  final VoidCallback onEdit;

  const PersonInfoCard({
    super.key,
    required this.customer,
    required this.summary,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final phone = customer.phoneNumber ?? '';
    final description = customer.description ?? '';
    final balanceColor = summary.totalType == TransactionType.debit
        ? AppColors.red600
        : AppColors.green600;

    return EntryAnimation(
      type: EntryAnimationType.fadeInDown,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gray300),
          boxShadow: AppShadows.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
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
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.blue100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: const AppIcon(
                          AppIconName.user,
                          size: 26,
                          color: AppColors.blue600,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customer.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppColors.gray900,
                              ),
                            ),
                            if (phone.isNotEmpty || description.isNotEmpty)
                              const SizedBox(height: 8),
                            if (phone.isNotEmpty)
                              _InfoRow(
                                icon: AppIconName.phone,
                                text: phone,
                                textDirection: TextDirection.ltr,
                              ),
                            if (phone.isNotEmpty && description.isNotEmpty)
                              const SizedBox(height: 4),
                            if (description.isNotEmpty)
                              _InfoRow(
                                icon: AppIconName.fileText,
                                text: description,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: 'ویرایش مشخصات',
                    icon: AppIconName.edit,
                    iconSize: 14,
                    variant: AppButtonVariant.outline,
                    size: AppButtonSize.sm,
                    onPressed: onEdit,
                  ),
                ],
              ),
            ),

            // Balance Display
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [AppColors.blue50, AppColors.gray50],
                ),
                border: Border(top: BorderSide(color: AppColors.gray200)),
              ),
              child: Column(
                children: [
                  const Text(
                    'مانده حساب',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${formatNumberFa(summary.totalBalance)} تومان',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: balanceColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final AppIconName icon;
  final String text;
  final TextDirection? textDirection;

  const _InfoRow({required this.icon, required this.text, this.textDirection});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppIcon(icon, size: 14, color: AppColors.gray600),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            textDirection: textDirection,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.gray600,
            ),
          ),
        ),
      ],
    );
  }
}
