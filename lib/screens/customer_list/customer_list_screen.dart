import 'package:flutter/material.dart';

import '../../data/customer_repository.dart';
import '../../models/customer.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_alert.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_modal.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_toggle.dart';
import '../../widgets/entry_animation.dart';
import '../transaction_view/transaction_view_screen.dart';
import 'app_header.dart';
import 'backup_sheet.dart';
import 'customer_card.dart';
import 'customer_form.dart';

/// Port of the web `app-customer-list` page.
class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final _repo = CustomerRepository.instance;
  final _alert = AlertService.instance;
  final _searchController = TextEditingController();

  List<Customer> _allCustomers = [];
  String _searchTerm = '';
  bool _isLoading = false;
  bool _includeArchived = false;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Port of `CustomerService.searchCustomers`: name (case-insensitive)
  /// or phone number contains the term.
  List<Customer> get _customers {
    final term = _searchTerm;
    if (term.isEmpty) return _allCustomers;
    final lowerTerm = term.toLowerCase();
    return _allCustomers
        .where((c) =>
            c.name.toLowerCase().contains(lowerTerm) ||
            (c.phoneNumber?.contains(lowerTerm) ?? false))
        .toList();
  }

  Future<void> _loadCustomers({bool showLoading = true}) async {
    if (showLoading) setState(() => _isLoading = true);
    try {
      final customers =
          await _repo.findAll(includeArchived: _includeArchived);
      if (!mounted) return;
      setState(() {
        _allCustomers = customers;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading customers: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      _alert.showError('خطا در بارگذاری لیست مشتریان');
    }
  }

  void _onToggleArchived(bool includeArchived) {
    setState(() => _includeArchived = includeArchived);
    _loadCustomers();
  }

  void _onSearchChange(String term) {
    setState(() => _searchTerm = term);
  }

  /// Shared validation for add/edit. Returns false (and shows an alert)
  /// if the form is invalid.
  bool _validate(CustomerFormData formData) {
    if (formData.name.trim().isEmpty) {
      _alert.showError('لطفاً نام مشتری را وارد کنید.');
      return false;
    }
    if (formData.phoneNumber.trim().isEmpty) {
      _alert.showError('لطفاً شماره تماس را وارد کنید.');
      return false;
    }
    return true;
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  void _openAddModal() {
    showAppModal<void>(
      context: context,
      title: 'افزودن مشتری جدید',
      builder: (sheetContext) => CustomerForm(
        buttonText: 'ثبت مشتری',
        buttonIcon: AppIconName.userPlus,
        onSave: (formData) => _addCustomer(sheetContext, formData),
      ),
    );
  }

  Future<void> _addCustomer(
    BuildContext sheetContext,
    CustomerFormData formData,
  ) async {
    if (!_validate(formData)) return;

    final dto = CreateCustomerDto(
      name: formData.name.trim(),
      phoneNumber: formData.phoneNumber.trim(),
      description: _emptyToNull(formData.description),
    );

    try {
      await _repo.create(dto);
      _alert.showSuccess('مشتری با موفقیت اضافه شد.');
      if (sheetContext.mounted) Navigator.of(sheetContext).pop();
      await _loadCustomers(showLoading: false);
    } catch (e) {
      debugPrint('Error creating customer: $e');
      _alert.showError('خطا در افزودن مشتری');
    }
  }

  void _openEditModal(Customer customer) {
    showAppModal<void>(
      context: context,
      title: 'ویرایش مشخصات مشتری',
      builder: (sheetContext) => CustomerForm(
        initialData: CustomerFormData(
          name: customer.name,
          phoneNumber: customer.phoneNumber ?? '',
          description: customer.description ?? '',
          id: customer.id,
          isArchived: customer.isArchived,
        ),
        onSave: (formData) =>
            _saveEditedCustomer(sheetContext, customer.id, formData),
        onArchive: (id) => _archiveCustomer(sheetContext, id),
        onUnarchive: (id) => _unarchiveCustomer(sheetContext, id),
      ),
    );
  }

  Future<void> _saveEditedCustomer(
    BuildContext sheetContext,
    String customerId,
    CustomerFormData formData,
  ) async {
    if (!_validate(formData)) return;

    final dto = UpdateCustomerDto(
      name: formData.name.trim(),
      phoneNumber: formData.phoneNumber.trim(),
      description: _emptyToNull(formData.description),
    );

    try {
      await _repo.update(customerId, dto);
      _alert.showSuccess('مشخصات مشتری با موفقیت به‌روزرسانی شد.');
      if (sheetContext.mounted) Navigator.of(sheetContext).pop();
      await _loadCustomers(showLoading: false);
    } catch (e) {
      debugPrint('Error updating customer: $e');
      _alert.showError('خطا در به‌روزرسانی مشتری');
    }
  }

  Future<void> _archiveCustomer(BuildContext sheetContext, String id) async {
    try {
      await _repo.archive(id);
      _alert.showSuccess('مشتری با موفقیت آرشیو شد.');
      if (sheetContext.mounted) Navigator.of(sheetContext).pop();
      await _loadCustomers(showLoading: false);
    } catch (e) {
      debugPrint('Error archiving customer: $e');
      _alert.showError('خطا در آرشیو مشتری');
    }
  }

  Future<void> _unarchiveCustomer(BuildContext sheetContext, String id) async {
    try {
      await _repo.unarchive(id);
      _alert.showSuccess('مشتری با موفقیت از آرشیو خارج شد.');
      if (sheetContext.mounted) Navigator.of(sheetContext).pop();
      await _loadCustomers(showLoading: false);
    } catch (e) {
      debugPrint('Error unarchiving customer: $e');
      _alert.showError('خطا در خروج از آرشیو مشتری');
    }
  }

  void _openBackupModal() {
    showAppModal<void>(
      context: context,
      title: 'پشتیبان‌گیری و بازیابی',
      builder: (_) => BackupSheet(
        onRestored: () => _loadCustomers(),
      ),
    );
  }

  Future<void> _viewTransactions(Customer customer) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TransactionViewScreen(customerId: customer.id),
      ),
    );
    // Customer details may have been edited on the transactions page.
    if (mounted) await _loadCustomers(showLoading: false);
  }

  @override
  Widget build(BuildContext context) {
    final customers = _customers;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.blue50, AppColors.white, AppColors.gray50],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(12),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 16),
              _buildActions(customers.length),
              const SizedBox(height: 16),
              ..._buildList(customers),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return EntryAnimation(
      type: EntryAnimationType.fadeInDown,
      child: Container(
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
            AppHeader(onBackup: _openBackupModal),
            Container(
              color: AppColors.gray50,
              padding: const EdgeInsets.all(16),
              child: AppTextField(
                controller: _searchController,
                hintText: 'جستجو بر اساس نام...',
                leadingIcon: AppIconName.search,
                onChanged: _onSearchChange,
                shadow: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(int count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const AppIcon(AppIconName.users, size: 22, color: AppColors.blue600),
            const SizedBox(width: 10),
            const Text(
              'لیست مشتریان',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.gray900,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 10),
              Text(
                '($count مشتری)',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray500,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        AppButton(
          label: 'افزودن',
          icon: AppIconName.plus,
          fullWidth: true,
          onPressed: _openAddModal,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.gray300),
            boxShadow: AppShadows.md,
          ),
          child: AppToggle(
            checked: _includeArchived,
            label: 'نمایش مشتریان آرشیو شده',
            onChanged: _onToggleArchived,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildList(List<Customer> customers) {
    if (_isLoading) {
      return [
        const _StatusCard(
          iconBackground: AppColors.blue100,
          icon: SpinningIcon(size: 36, color: AppColors.blue600),
          title: 'در حال بارگذاری...',
        ),
      ];
    }
    if (customers.isEmpty) {
      return [
        const _StatusCard(
          iconBackground: AppColors.gray100,
          icon: AppIcon(AppIconName.users, size: 36, color: AppColors.gray400),
          title: 'هیچ مشتری یافت نشد',
          subtitle: 'برای شروع، یک مشتری جدید اضافه کنید',
        ),
      ];
    }
    return [
      for (final customer in customers)
        CustomerCard(
          key: ValueKey(customer.id),
          customer: customer,
          onTap: () => _viewTransactions(customer),
          onEdit: () => _openEditModal(customer),
        ),
    ];
  }
}

class _StatusCard extends StatelessWidget {
  final Color iconBackground;
  final Widget icon;
  final String title;
  final String? subtitle;

  const _StatusCard({
    required this.iconBackground,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return EntryAnimation(
      type: EntryAnimationType.fadeInScale,
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gray300),
          boxShadow: AppShadows.lg,
        ),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: icon,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.gray700,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
