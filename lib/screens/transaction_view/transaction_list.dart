import 'package:flutter/material.dart';

import '../../models/ledger_transaction.dart';
import '../../theme/app_colors.dart';
import '../../utils/persian_format.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/entry_animation.dart';

/// Port of the web `app-transaction-list`.
class TransactionList extends StatelessWidget {
  final List<LedgerTransaction> transactions;

  const TransactionList({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return EntryAnimation(
      duration: const Duration(milliseconds: 500),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
              child: Row(
                children: [
                  const AppIcon(AppIconName.fileText, size: 20, color: AppColors.blue600),
                  const SizedBox(width: 10),
                  const Text(
                    'تراکنش‌ها',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.gray900,
                    ),
                  ),
                  if (transactions.isNotEmpty) ...[
                    const SizedBox(width: 10),
                    Text(
                      '(${transactions.length})',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (transactions.isEmpty)
              const _EmptyTransactions()
            else
              for (var i = 0; i < transactions.length; i++) ...[
                if (i > 0) const Divider(height: 1, thickness: 1, color: AppColors.gray100),
                TransactionItem(transaction: transactions[i]),
              ],
          ],
        ),
      ),
    );
  }
}

class _EmptyTransactions extends StatelessWidget {
  const _EmptyTransactions();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: const AppIcon(AppIconName.file, size: 36, color: AppColors.gray400),
          ),
          const SizedBox(height: 16),
          const Text(
            'هیچ تراکنشی ثبت نشده است',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.gray700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'تراکنش اول را ثبت کنید',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.gray500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Port of the web `app-transaction-item`.
class TransactionItem extends StatelessWidget {
  final LedgerTransaction transaction;

  const TransactionItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isDebit = transaction.type == TransactionType.debit;
    final color = isDebit ? AppColors.red600 : AppColors.green600;
    final description = transaction.description ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDebit ? AppColors.red100 : AppColors.green100,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: AppIcon(
                  isDebit ? AppIconName.minus : AppIconName.plus,
                  size: 18,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              const AppIcon(AppIconName.calendar, size: 12, color: AppColors.gray500),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  formatJalaliDisplay(transaction.date),
                  maxLines: 1,
                  style: const TextStyle(fontSize: 14, color: AppColors.gray500),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerEnd,
                  child: Text(
                    '${isDebit ? '-' : '+'} ${formatNumberFa(transaction.amount)} تومان',
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: color,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (description.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: AppColors.gray800,
              ),
            ),
          ),
      ],
    );
  }
}
