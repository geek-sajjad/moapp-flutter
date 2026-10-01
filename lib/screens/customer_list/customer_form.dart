import 'package:flutter/material.dart';

import '../../theme/app_icons.dart';

class CustomerFormData {
  final String name;
  final String phoneNumber;
  final String description;
  final String? id;
  final bool isArchived;

  const CustomerFormData({
    this.name = '',
    this.phoneNumber = '',
    this.description = '',
    this.id,
    this.isArchived = false,
  });
}

/// Port of the web `app-customer-form` (used for both add and edit).
class CustomerForm extends StatefulWidget {
  final CustomerFormData initialData;
  final String buttonText;
  final IconData buttonIcon;
  final ValueChanged<CustomerFormData> onSave;
  final ValueChanged<String>? onArchive;
  final ValueChanged<String>? onUnarchive;

  const CustomerForm({
    super.key,
    this.initialData = const CustomerFormData(),
    this.buttonText = 'ذخیره تغییرات',
    this.buttonIcon = AppIcons.save,
    required this.onSave,
    this.onArchive,
    this.onUnarchive,
  });

  @override
  State<CustomerForm> createState() => _CustomerFormState();
}

class _CustomerFormState extends State<CustomerForm> {
  late final TextEditingController _name =
      TextEditingController(text: widget.initialData.name);
  late final TextEditingController _phone =
      TextEditingController(text: widget.initialData.phoneNumber);
  late final TextEditingController _description =
      TextEditingController(text: widget.initialData.description);

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _description.dispose();
    super.dispose();
  }

  void _handleSave() {
    widget.onSave(CustomerFormData(
      name: _name.text,
      phoneNumber: _phone.text,
      description: _description.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final customerId = widget.initialData.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _name,
          autofocus: true,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'نام مشتری *',
            hintText: 'نام مشتری را وارد کنید',
            prefixIcon: Icon(AppIcons.user),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _phone,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.phone,
          textDirection: TextDirection.ltr,
          decoration: const InputDecoration(
            labelText: 'شماره تماس *',
            hintText: 'مثال: +989123456789',
            hintTextDirection: TextDirection.ltr,
            prefixIcon: Icon(AppIcons.phone),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _description,
          minLines: 3,
          maxLines: 4,
          keyboardType: TextInputType.multiline,
          decoration: const InputDecoration(
            labelText: 'توضیحات',
            hintText: 'توضیحات اضافی (اختیاری)',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _handleSave,
          icon: Icon(widget.buttonIcon),
          label: Text(widget.buttonText),
        ),
        if (customerId != null) ...[
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          widget.initialData.isArchived
              ? OutlinedButton.icon(
                  onPressed: () => widget.onUnarchive?.call(customerId),
                  icon: const Icon(AppIcons.unarchive),
                  label: const Text('بازگردانی از آرشیو'),
                )
              : OutlinedButton.icon(
                  onPressed: () => widget.onArchive?.call(customerId),
                  icon: const Icon(AppIcons.archive),
                  label: const Text('آرشیو کردن'),
                ),
        ],
      ],
    );
  }
}
