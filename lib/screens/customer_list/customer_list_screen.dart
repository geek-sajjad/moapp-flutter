import 'package:flutter/material.dart';

import '../../data/customer_repository.dart';
import '../../models/customer.dart';
import '../../theme/app_icons.dart';
import '../../utils/persian_format.dart';
import '../../widgets/app_alert.dart';
import '../../widgets/app_modal.dart';
import '../../widgets/empty_state.dart';
import '../transaction_view/transaction_view_screen.dart';
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
        buttonIcon: AppIcons.userPlus,
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverAppBar.medium(
            title: const Text(
              'دفتر معین شخصی',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            actions: [
              IconButton(
                onPressed: _openBackupModal,
                tooltip: 'پشتیبان‌گیری',
                icon: const Icon(AppIcons.database),
              ),
              const SizedBox(width: 4),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: SearchBar(
                controller: _searchController,
                hintText: 'جستجو بر اساس نام...',
                leading: const Padding(
                  padding: EdgeInsetsDirectional.only(start: 4),
                  child: Icon(AppIcons.search),
                ),
                trailing: [
                  if (_searchTerm.isNotEmpty)
                    IconButton(
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChange('');
                      },
                      tooltip: 'پاک کردن',
                      icon: const Icon(AppIcons.close),
                    ),
                ],
                elevation: const WidgetStatePropertyAll(0),
                backgroundColor:
                    WidgetStatePropertyAll(scheme.surfaceContainerHigh),
                onChanged: _onSearchChange,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(
                children: [
                  FilterChip(
                    selected: _includeArchived,
                    onSelected: _onToggleArchived,
                    avatar: _includeArchived ? null : const Icon(AppIcons.archive),
                    label: const Text('نمایش مشتریان آرشیو شده'),
                  ),
                  const Spacer(),
                  if (customers.isNotEmpty)
                    Text(
                      '${toPersianNumbers('${customers.length}')} مشتری',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ),
          ..._buildList(customers),
          // Room for the FAB below the last card.
          const SliverToBoxAdapter(child: SizedBox(height: 96)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddModal,
        icon: const Icon(AppIcons.userPlus),
        label: const Text('افزودن مشتری'),
      ),
    );
  }

  List<Widget> _buildList(List<Customer> customers) {
    if (_isLoading) {
      return const [
        SliverToBoxAdapter(
          child: EmptyState(
            icon: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            title: 'در حال بارگذاری...',
          ),
        ),
      ];
    }
    if (customers.isEmpty) {
      return const [
        SliverToBoxAdapter(
          child: EmptyState(
            icon: Icon(AppIcons.users),
            title: 'هیچ مشتری یافت نشد',
            subtitle: 'برای شروع، یک مشتری جدید اضافه کنید',
          ),
        ),
      ];
    }
    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverList.separated(
          itemCount: customers.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final customer = customers[index];
            return CustomerCard(
              key: ValueKey(customer.id),
              customer: customer,
              onTap: () => _viewTransactions(customer),
              onEdit: () => _openEditModal(customer),
            );
          },
        ),
      ),
    ];
  }
}
