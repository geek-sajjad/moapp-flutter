import 'package:flutter/material.dart';

import '../../models/customer.dart';
import '../../models/ledger_transaction.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_theme.dart';
import '../../utils/persian_format.dart';

/// Port of the web `app-person-info-card`: the account balance, tinted red
/// (debit) or green (credit), with the customer's contact details.
class PersonInfoCard extends StatelessWidget {
  final Customer customer;
  final TransactionSummary summary;

  const PersonInfoCard({
    super.key,
    required this.customer,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final ledger = LedgerColors.of(context);
    final isDebit = summary.totalType == TransactionType.debit;
    // A settled (zero) balance is neither debit nor credit.
    final (bg, fg) = summary.totalBalance == 0
        ? (scheme.surfaceContainerHigh, scheme.onSurface)
        : isDebit
            ? (ledger.debitContainer, ledger.onDebitContainer)
            : (ledger.creditContainer, ledger.onCreditContainer);
    final phone = customer.phoneNumber ?? '';
    final description = customer.description ?? '';

    return Card.filled(
      color: bg,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(AppIcons.wallet, color: fg, size: 22),
                const SizedBox(width: 8),
                Text(
                  'مانده حساب',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                '${formatNumberFa(summary.totalBalance)} تومان',
                maxLines: 1,
                style: theme.textTheme.displaySmall?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (phone.isNotEmpty || description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Divider(color: fg.withValues(alpha: 0.2)),
              const SizedBox(height: 12),
              if (phone.isNotEmpty)
                _InfoRow(
                  icon: AppIcons.phone,
                  text: phone,
                  color: fg,
                  textDirection: TextDirection.ltr,
                ),
              if (phone.isNotEmpty && description.isNotEmpty)
                const SizedBox(height: 8),
              if (description.isNotEmpty)
                _InfoRow(icon: AppIcons.note, text: description, color: fg),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final TextDirection? textDirection;

  const _InfoRow({
    required this.icon,
    required this.text,
    required this.color,
    this.textDirection,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color.withValues(alpha: 0.8)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            textDirection: textDirection,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color.withValues(alpha: 0.85),
                ),
          ),
        ),
      ],
    );
  }
}
