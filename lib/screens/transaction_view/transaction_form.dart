import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/ledger_transaction.dart';
import '../../theme/app_colors.dart';
import '../../utils/persian_format.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/entry_animation.dart';
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
    return EntryAnimation(
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
              child: const Row(
                children: [
                  AppIcon(AppIconName.dollarSign, size: 20, color: AppColors.blue600),
                  SizedBox(width: 10),
                  Text(
                    'ثبت تراکنش جدید',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.gray900,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const FieldLabel('تاریخ تراکنش'),
                  PersianDatePicker(
                    value: _date,
                    onChanged: (value) => setState(() => _date = value),
                  ),
                  const SizedBox(height: 20),
                  const FieldLabel('نوع تراکنش'),
                  _TypeSelect(
                    value: _type,
                    onChanged: (type) => setState(() => _type = type),
                  ),
                  const SizedBox(height: 20),
                  const FieldLabel('مبلغ (تومان)'),
                  _AmountField(controller: _amount),
                  const SizedBox(height: 20),
                  const FieldLabel('توضیحات'),
                  AppTextField(
                    controller: _description,
                    hintText: 'توضیحات تراکنش را وارد کنید',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'ثبت',
                    icon: AppIconName.plus,
                    size: AppButtonSize.lg,
                    fullWidth: true,
                    onPressed: _saving ? null : _handleSave,
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

/// Amount input (LTR) with the fixed "تومان" label on its left side.
class _AmountField extends StatelessWidget {
  final TextEditingController controller;

  const _AmountField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          AppTextField(
            controller: controller,
            hintText: 'مبلغ را وارد کنید',
            textDirection: TextDirection.ltr,
            keyboardType: TextInputType.number,
            inputFormatters: [ThousandsAmountFormatter()],
            // Leaves room for the label (web: `pl-20`). In this LTR
            // context the prefix slot is on the left.
            leadingSpacer: 64,
          ),
          const Positioned(
            left: 16,
            child: IgnorePointer(
              child: Text(
                'تومان',
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray500,
                ),
              ),
            ),
          ),
        ],
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
    var digits =
        toEnglishNumbers(newValue.text).replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > _maxDigits) digits = digits.substring(0, _maxDigits);
    if (digits.isEmpty) return const TextEditingValue();

    final formatted = formatNumberEn(int.parse(digits));
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// The colored "نوع تراکنش" select.
class _TypeSelect extends StatelessWidget {
  final TransactionType value;
  final ValueChanged<TransactionType> onChanged;

  const _TypeSelect({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDebit = value == TransactionType.debit;
    final border = isDebit ? AppColors.red500 : AppColors.green500;
    final bg = isDebit ? AppColors.red50 : AppColors.green50;
    final fg = isDebit ? AppColors.red700 : AppColors.green700;

    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 2),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<TransactionType>(
          value: value,
          isExpanded: true,
          iconEnabledColor: fg,
          borderRadius: BorderRadius.circular(12),
          dropdownColor: AppColors.white,
          style: TextStyle(
            fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: fg,
          ),
          selectedItemBuilder: (context) => [
            for (final type in _order)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(_label(type)),
              ),
          ],
          items: [
            for (final type in _order)
              DropdownMenuItem(
                value: type,
                child: Text(
                  _label(type),
                  style: const TextStyle(color: AppColors.gray900),
                ),
              ),
          ],
          onChanged: (type) {
            if (type != null) onChanged(type);
          },
        ),
      ),
    );
  }

  /// Same option order as the web select: DEBIT first, then CREDIT.
  static const _order = [TransactionType.debit, TransactionType.credit];

  static String _label(TransactionType type) => switch (type) {
        TransactionType.debit => 'بدهکار (شما بدهکار هستید)',
        TransactionType.credit => 'بستانکار (شما بستانکار هستید)',
      };
}
