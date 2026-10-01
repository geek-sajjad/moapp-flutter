import 'package:flutter/material.dart';

import '../../data/customer_repository.dart';
import '../../data/transaction_repository.dart';
import '../../models/customer.dart';
import '../../models/ledger_transaction.dart';
import '../../services/statement_share_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_alert.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_modal.dart';
import '../../widgets/entry_animation.dart';
import 'edit_person_form.dart';
import 'person_info_card.dart';
import 'transaction_form.dart';
import 'transaction_list.dart';

/// Port of the web `app-transaction-view` page (route `/transactions/:id`).
class TransactionViewScreen extends StatefulWidget {
  final String customerId;

  const TransactionViewScreen({super.key, required this.customerId});

  @override
  State<TransactionViewScreen> createState() => _TransactionViewScreenState();
}

class _TransactionViewScreenState extends State<TransactionViewScreen> {
  final _customerRepo = CustomerRepository.instance;
  final _transactionRepo = TransactionRepository.instance;
  final _alert = AlertService.instance;

  Customer? _customer;
  List<LedgerTransaction> _transactions = [];
  TransactionSummary? _summary;
  bool _transactionsLoading = false;

  String get _customerId => widget.customerId;

  @override
  void initState() {
    super.initState();
    _loadPersonData();
    _loadTransactions();
    _loadTransactionSummary();
  }

  Future<void> _loadPersonData() async {
    try {
      final customer = await _customerRepo.findOne(_customerId);
      if (mounted) setState(() => _customer = customer);
    } catch (e) {
      debugPrint('Error loading customer: $e');
    }
  }

  Future<void> _loadTransactions({bool showLoading = true}) async {
    if (showLoading) setState(() => _transactionsLoading = true);
    try {
      final transactions =
          await _transactionRepo.findAllByCustomer(_customerId);
      if (!mounted) return;
      setState(() {
        _transactions = transactions;
        _transactionsLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading transactions: $e');
      if (!mounted) return;
      setState(() {
        _transactions = [];
        _transactionsLoading = false;
      });
      _alert.showError('خطا در بارگذاری تراکنش‌ها.');
    }
  }

  Future<void> _loadTransactionSummary() async {
    try {
      final summary = await _transactionRepo.getCustomerSummary(_customerId);
      if (mounted) setState(() => _summary = summary);
    } catch (e) {
      debugPrint('Error loading transaction summary: $e');
      if (!mounted) return;
      setState(() => _summary = null);
      _alert.showError('خطا در بارگذاری خلاصه تراکنش ها.');
    }
  }

  Future<bool> _saveTransaction(TransactionFormData formData) async {
    final amount = int.tryParse(formData.amount);

    if (amount == null || amount <= 0) {
      _alert.showError('لطفاً مبلغ را به درستی وارد کنید.');
      return false;
    }

    final dto = CreateTransactionDto(
      customerId: _customerId,
      date: formData.transactionDate,
      type: formData.type,
      amount: amount,
      description: formData.description,
    );

    try {
      await _transactionRepo.create(dto);
      _alert.showSuccess('تراکنش با موفقیت ثبت شد.');
      await Future.wait([
        _loadTransactions(showLoading: false),
        _loadTransactionSummary(),
      ]);
      return true;
    } catch (e) {
      debugPrint('Error creating transaction: $e');
      _alert.showError('خطا در ثبت تراکنش.');
      return false;
    }
  }

  void _openEditPersonModal() {
    final customer = _customer;
    if (customer == null) return;

    showAppModal<void>(
      context: context,
      title: 'ویرایش مشخصات مشتری',
      builder: (sheetContext) => EditPersonForm(
        initialData: PersonFormData(
          name: customer.name,
          phone: customer.phoneNumber ?? '',
          address: customer.description ?? '',
        ),
        onSave: (formData) => _saveEditedPerson(sheetContext, formData),
      ),
    );
  }

  Future<void> _saveEditedPerson(
    BuildContext sheetContext,
    PersonFormData formData,
  ) async {
    if (formData.name.trim().isEmpty) {
      _alert.showError('لطفاً نام مشتری را وارد کنید.');
      return;
    }

    final phone = formData.phone.trim();
    final description = formData.address.trim();
    final dto = UpdateCustomerDto(
      name: formData.name.trim(),
      phoneNumber: phone.isEmpty ? null : phone,
      description: description.isEmpty ? null : description,
    );

    try {
      await _customerRepo.update(_customerId, dto);
      _alert.showSuccess('مشخصات مشتری با موفقیت به‌روزرسانی شد.');
      await _loadPersonData();
      if (sheetContext.mounted) Navigator.of(sheetContext).pop();
    } catch (e) {
      debugPrint('Error updating customer: $e');
      _alert.showError('خطا در به‌روزرسانی مشتری.');
    }
  }

  Future<void> _shareStatement() async {
    final customer = _customer;
    if (customer == null || _transactions.isEmpty) {
      _alert.showError('تراکنشی برای ارسال وجود ندارد.');
      return;
    }

    await StatementShareService.instance.shareStatement(
      _transactions,
      customer.name,
      phoneNumber: customer.phoneNumber,
    );
    _alert.showSuccess('متن صورت‌حساب کپی شد.');
  }

  void _goBack() => Navigator.of(context).maybePop();

  @override
  Widget build(BuildContext context) {
    final customer = _customer;
    final summary = _summary;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            // Back Button
            EntryAnimation(
              type: EntryAnimationType.fadeInDown,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: AppButton(
                  label: 'بازگشت به لیست افراد',
                  icon: AppIconName.arrowLeft,
                  iconSize: 16,
                  variant: AppButtonVariant.outline,
                  size: AppButtonSize.sm,
                  onPressed: _goBack,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Person Info Card
            if (customer != null && summary != null) ...[
              PersonInfoCard(
                customer: customer,
                summary: summary,
                onEdit: _openEditPersonModal,
              ),
              const SizedBox(height: 16),
            ],

            // Transaction Form Card
            TransactionForm(onSave: _saveTransaction),
            const SizedBox(height: 16),

            // Transactions List
            if (_transactionsLoading)
              const _LoadingCard()
            else
              TransactionList(transactions: _transactions),

            // Share Button
            if (_transactions.isNotEmpty) ...[
              const SizedBox(height: 16),
              EntryAnimation(
                duration: const Duration(milliseconds: 500),
                child: AppButton(
                  label: 'اشتراک‌گذاری صورتحساب',
                  icon: AppIconName.share,
                  variant: AppButtonVariant.secondary,
                  size: AppButtonSize.lg,
                  fullWidth: true,
                  onPressed: _shareStatement,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray300),
        boxShadow: AppShadows.xl,
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.blue50,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: const SpinningIcon(size: 28),
          ),
          const SizedBox(height: 16),
          const Text(
            'در حال بارگذاری تراکنش‌ها...',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.gray600,
            ),
          ),
        ],
      ),
    );
  }
}
