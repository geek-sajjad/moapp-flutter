import 'package:flutter/material.dart';

import '../../data/transaction_repository.dart';
import '../../models/ledger_report.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_theme.dart';
import '../../utils/persian_format.dart';
import '../../widgets/app_alert.dart';
import '../../widgets/customer_avatar.dart';
import '../../widgets/empty_state.dart';
import '../transaction_view/transaction_view_screen.dart';

/// Overall report: net balance, totals owed both ways and each customer's
/// open balance.
class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  LedgerReport? _report;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final report = await TransactionRepository.instance.getReport();
      if (mounted) setState(() => _report = report);
    } catch (e) {
      debugPrint('Error loading report: $e');
      AlertService.instance.showError('خطا در بارگذاری گزارش');
    }
  }

  Future<void> _openCustomer(CustomerBalance balance) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TransactionViewScreen(customerId: balance.customer.id),
      ),
    );
    // Transactions may have been added there.
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final report = _report;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: 'بازگشت',
          icon: const Icon(AppIcons.back),
        ),
        title: const Text(
          'گزارش حساب‌ها',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: report == null
          ? const EmptyState(
              icon: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
              title: 'در حال بارگذاری...',
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  16 + MediaQuery.of(context).padding.bottom,
                ),
                children: [
                  _NetBalanceCard(report: report),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _TotalTile(
                          icon: AppIcons.trendUp,
                          label: 'طلب شما',
                          hint: 'مشتریان بستانکار',
                          amount: report.totalCredit,
                          count: report.creditorCount,
                          isDebit: false,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TotalTile(
                          icon: AppIcons.trendDown,
                          label: 'بدهی شما',
                          hint: 'مشتریان بدهکار',
                          amount: report.totalDebit,
                          count: report.debtorCount,
                          isDebit: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _CountsCard(report: report),
                  const SizedBox(height: 12),
                  _BalancesCard(report: report, onOpen: _openCustomer),
                ],
              ),
            ),
    );
  }
}

class _NetBalanceCard extends StatelessWidget {
  final LedgerReport report;

  const _NetBalanceCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final ledger = LedgerColors.of(context);
    final net = report.netBalance;

    final (bg, fg, status) = net == 0
        ? (scheme.surfaceContainerHigh, scheme.onSurface, 'تسویه')
        : net > 0
            ? (ledger.creditContainer, ledger.onCreditContainer, 'بستانکار')
            : (ledger.debitContainer, ledger.onDebitContainer, 'بدهکار');

    return Card.filled(
      color: bg,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(AppIcons.scales, color: fg, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'مانده کل',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: fg.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                '${formatNumberFa(net.abs())} تومان',
                maxLines: 1,
                style: theme.textTheme.displaySmall?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'طلب شما منهای بدهی شما',
              style: theme.textTheme.bodySmall?.copyWith(
                color: fg.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String hint;
  final int amount;
  final int count;
  final bool isDebit;

  const _TotalTile({
    required this.icon,
    required this.label,
    required this.hint,
    required this.amount,
    required this.count,
    required this.isDebit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final ledger = LedgerColors.of(context);
    final color = isDebit ? ledger.debit : ledger.credit;

    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                '${formatNumberFa(amount)} تومان',
                maxLines: 1,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$hint: ${toPersianNumbers('$count')}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountsCard extends StatelessWidget {
  final LedgerReport report;

  const _CountsCard({required this.report});

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            _Count(label: 'مشتریان', value: report.customerCount),
            const _VerticalDivider(),
            _Count(label: 'تراکنش‌ها', value: report.transactionCount),
            const _VerticalDivider(),
            _Count(label: 'تسویه‌شده', value: report.settledCount),
          ],
        ),
      ),
    );
  }
}

class _Count extends StatelessWidget {
  final String label;
  final int value;

  const _Count({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            toPersianNumbers('$value'),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: VerticalDivider(color: Theme.of(context).colorScheme.outlineVariant),
    );
  }
}

class _BalancesCard extends StatelessWidget {
  final LedgerReport report;
  final ValueChanged<CustomerBalance> onOpen;

  const _BalancesCard({required this.report, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final open = report.openBalances;

    return Card.outlined(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
            child: Text(
              'مانده مشتریان',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (open.isEmpty)
            const EmptyState(
              icon: Icon(AppIcons.checks),
              title: 'همه حساب‌ها تسویه است',
              subtitle: 'هیچ مشتری مانده بدهکار یا بستانکار ندارد',
            )
          else
            for (var i = 0; i < open.length; i++) ...[
              if (i > 0) const Divider(indent: 76),
              _BalanceRow(balance: open[i], onTap: () => onOpen(open[i])),
            ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _BalanceRow extends StatelessWidget {
  final CustomerBalance balance;
  final VoidCallback onTap;

  const _BalanceRow({required this.balance, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final ledger = LedgerColors.of(context);
    final customer = balance.customer;
    final isDebit = balance.balance < 0;
    final color = isDebit ? ledger.debit : ledger.credit;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            CustomerAvatar(
              name: customer.name,
              muted: customer.isArchived,
              radius: 20,
            ),
            const SizedBox(width: 16),
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
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (customer.isArchived) ...[
                        const SizedBox(width: 6),
                        Icon(
                          AppIcons.archive,
                          size: 16,
                          color: scheme.onSurfaceVariant,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isDebit ? 'بدهکار' : 'بستانکار',
                    style: theme.textTheme.bodySmall?.copyWith(color: color),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerEnd,
                child: Text(
                  '${formatNumberFa(balance.balance.abs())} تومان',
                  maxLines: 1,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
