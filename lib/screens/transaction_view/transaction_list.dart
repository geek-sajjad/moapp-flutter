import 'package:flutter/material.dart';

import '../../models/ledger_transaction.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_theme.dart';
import '../../utils/persian_format.dart';
import '../../widgets/empty_state.dart';

/// Port of the web `app-transaction-list`.
class TransactionList extends StatelessWidget {
  final List<LedgerTransaction> transactions;

  const TransactionList({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card.outlined(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
            child: Row(
              children: [
                Text(
                  'تراکنش‌ها',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (transactions.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Badge(
                    label: Text(toPersianNumbers('${transactions.length}')),
                    backgroundColor: scheme.secondaryContainer,
                    textColor: scheme.onSecondaryContainer,
                  ),
                ],
              ],
            ),
          ),
          if (transactions.isEmpty)
            const EmptyState(
              icon: Icon(AppIcons.empty),
              title: 'هیچ تراکنشی ثبت نشده است',
              subtitle: 'تراکنش اول را ثبت کنید',
            )
          else
            for (var i = 0; i < transactions.length; i++) ...[
              if (i > 0) const Divider(indent: 76),
              TransactionItem(transaction: transactions[i]),
            ],
          const SizedBox(height: 8),
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final ledger = LedgerColors.of(context);
    final isDebit = transaction.type == TransactionType.debit;
    final color = isDebit ? ledger.debit : ledger.credit;
    final description = transaction.description ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor:
                isDebit ? ledger.debitContainer : ledger.creditContainer,
            foregroundColor:
                isDebit ? ledger.onDebitContainer : ledger.onCreditContainer,
            child: Icon(isDebit ? AppIcons.minus : AppIcons.plus, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      formatJalaliDisplay(transaction.date),
                      maxLines: 1,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerEnd,
                        child: Text(
                          '${isDebit ? '-' : '+'} ${formatNumberFa(transaction.amount)} تومان',
                          maxLines: 1,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
