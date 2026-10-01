import 'package:flutter/material.dart';

import '../../models/customer.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/entry_animation.dart';

/// Port of the web `app-customer-card`.
class CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const CustomerCard({
    super.key,
    required this.customer,
    required this.onTap,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final archived = customer.isArchived;
    final phone = customer.phoneNumber;
    final description = customer.description;

    return EntryAnimation(
      child: Opacity(
        opacity: archived ? 0.6 : 1,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gray300),
            boxShadow: AppShadows.md,
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onTap,
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: archived ? AppColors.gray300 : AppColors.blue100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: AppIcon(
                          AppIconName.user,
                          size: 22,
                          color: archived ? AppColors.gray600 : AppColors.blue600,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    customer.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.gray900,
                                    ),
                                  ),
                                ),
                                if (archived) ...[
                                  const SizedBox(width: 8),
                                  const _ArchivedBadge(),
                                ],
                              ],
                            ),
                            if (phone != null && phone.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    phone,
                                    textDirection: TextDirection.ltr,
                                    textAlign: TextAlign.left,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.gray600,
                                    ),
                                  ),
                                ),
                              ),
                            if (description != null && description.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.gray500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Material(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(8),
                  child: const SizedBox(
                    width: 40,
                    height: 40,
                    child: Center(
                      child: AppIcon(
                        AppIconName.edit,
                        size: 18,
                        color: AppColors.gray600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArchivedBadge extends StatelessWidget {
  const _ArchivedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.gray200,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon(AppIconName.flag, size: 14, color: AppColors.gray600),
          SizedBox(width: 4),
          Text(
            'آرشیو',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.gray700,
            ),
          ),
        ],
      ),
    );
  }
}
