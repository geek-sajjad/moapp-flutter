import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/ledger_transaction.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_theme.dart';
import '../../utils/persian_format.dart';
import '../../widgets/persian_date_picker.dart';

/// Port of the web `app-transaction-form` (create only, like the web app).
///
/// [onSave] returns `true` when the transaction was stored; the form then
/// resets itself to its initial state.
class TransactionForm extends StatefulWidget {
  final Future<bool> Function(TransactionFormData data) onSave;

  const TransactionForm({super.key, required this.onSave});

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _amount = TextEditingController();
  final _description = TextEditingController();
  String _date = todayIsoDate();
  TransactionType _type = TransactionType.credit;
  bool _saving = false;

  @override
  void dispose() {
    _amount.dispose();
    _description.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _date = todayIsoDate();
      _type = TransactionType.credit;
      _amount.clear();
      _description.clear();
    });
  }

  Future<void> _handleSave() async {
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    final saved = await widget.onSave(TransactionFormData(
      transactionDate: _date,
      type: _type,
      // Raw numeric value (thousand separators removed).
      amount: _amount.text.replaceAll(',', ''),
      description: _description.text,
    ));
    if (!mounted) return;
    setState(() => _saving = false);
    if (saved) _reset();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(AppIcons.receipt, color: scheme.primary),
                const SizedBox(width: 10),
                Text(
                  'ثبت تراکنش جدید',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _TypeSelect(
              value: _type,
              onChanged: (type) => setState(() => _type = type),
            ),
            const SizedBox(height: 20),
            PersianDatePicker(
              label: 'تاریخ تراکنش',
              value: _date,
              onChanged: (value) => setState(() => _date = value),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amount,
              keyboardType: TextInputType.number,
              textDirection: TextDirection.ltr,
              inputFormatters: [ThousandsAmountFormatter()],
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                labelText: 'مبلغ (تومان)',
                hintText: 'مبلغ را وارد کنید',
                // Gap between the digits and the unit (start side in RTL).
                suffix: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 8),
                  child: Text(
                    'تومان',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _description,
              minLines: 2,
              maxLines: 4,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                labelText: 'توضیحات',
                hintText: 'توضیحات تراکنش را وارد کنید',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _saving ? null : _handleSave,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(AppIcons.plus),
              label: const Text('ثبت'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Keeps only digits (Persian digits are converted) and formats them with
/// `,` thousand separators, like the web `getFormattedAmount()`.
class ThousandsAmountFormatter extends TextInputFormatter {
  static const _maxDigits = 13;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String onlyDigits(String s) =>
        toEnglishNumbers(s).replaceAll(RegExp(r'[^0-9]'), '');

    var digits = onlyDigits(newValue.text);
    if (digits.length > _maxDigits) digits = digits.substring(0, _maxDigits);
    if (digits.isEmpty) {
      return const TextEditingValue(
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final formatted = formatNumberEn(int.parse(digits));

    // Keep the caret after the same number of digits as before formatting
    // (leading zeros are dropped by int.parse, so clamp).
    final cursor = newValue.selection.isValid
        ? newValue.selection.end.clamp(0, newValue.text.length)
        : newValue.text.length;
    var digitsBeforeCursor = onlyDigits(newValue.text.substring(0, cursor)).length;
    digitsBeforeCursor -= digits.length - formatted.replaceAll(',', '').length;
    if (digitsBeforeCursor < 0) digitsBeforeCursor = 0;

    var offset = 0;
    var seen = 0;
    while (offset < formatted.length && seen < digitsBeforeCursor) {
      if (formatted[offset] != ',') seen++;
      offset++;
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}

/// "نوع تراکنش": debit / credit segmented button, tinted by the selection.
class _TypeSelect extends StatelessWidget {
  final TransactionType value;
  final ValueChanged<TransactionType> onChanged;

  const _TypeSelect({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ledger = LedgerColors.of(context);
    final isDebit = value == TransactionType.debit;
    final selectedBg = isDebit ? ledger.debitContainer : ledger.creditContainer;
    final selectedFg =
        isDebit ? ledger.onDebitContainer : ledger.onCreditContainer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<TransactionType>(
          segments: const [
            // Same option order as the web select: DEBIT first, then CREDIT.
            ButtonSegment(
              value: TransactionType.debit,
              icon: Icon(AppIcons.minus),
              label: Text('بدهکار'),
            ),
            ButtonSegment(
              value: TransactionType.credit,
              icon: Icon(AppIcons.plus),
              label: Text('بستانکار'),
            ),
          ],
          selected: {value},
          showSelectedIcon: false,
          onSelectionChanged: (selection) => onChanged(selection.first),
          style: ButtonStyle(
            minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
            textStyle: WidgetStatePropertyAll(
              theme.textTheme.labelLarge?.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            backgroundColor: WidgetStateProperty.resolveWith(
              (states) =>
                  states.contains(WidgetState.selected) ? selectedBg : null,
            ),
            foregroundColor: WidgetStateProperty.resolveWith(
              (states) =>
                  states.contains(WidgetState.selected) ? selectedFg : null,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 16),
          child: Text(
            isDebit ? 'شما بدهکار هستید' : 'شما بستانکار هستید',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
