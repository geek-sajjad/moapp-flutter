import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_text_field.dart';

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
  final AppIconName buttonIcon;
  final ValueChanged<CustomerFormData> onSave;
  final ValueChanged<String>? onArchive;
  final ValueChanged<String>? onUnarchive;

  const CustomerForm({
    super.key,
    this.initialData = const CustomerFormData(),
    this.buttonText = 'ذخیره تغییرات',
    this.buttonIcon = AppIconName.save,
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
        const FieldLabel('نام مشتری *'),
        AppTextField(
          controller: _name,
          hintText: 'نام مشتری را وارد کنید',
        ),
        const SizedBox(height: 20),
        const FieldLabel('شماره تماس *'),
        AppTextField(
          controller: _phone,
          hintText: 'مثال: +989123456789',
          textDirection: TextDirection.ltr,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 20),
        const FieldLabel('توضیحات'),
        AppTextField(
          controller: _description,
          hintText: 'توضیحات اضافی (اختیاری)',
          maxLines: 4,
        ),
        const SizedBox(height: 28),
        AppButton(
          label: widget.buttonText,
          icon: widget.buttonIcon,
          size: AppButtonSize.lg,
          fullWidth: true,
          onPressed: _handleSave,
        ),
        if (customerId != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.gray300)),
            ),
            child: widget.initialData.isArchived
                ? AppButton(
                    label: 'بازگردانی از آرشیو',
                    icon: AppIconName.arrowLeft,
                    variant: AppButtonVariant.outline,
                    fullWidth: true,
                    onPressed: () => widget.onUnarchive?.call(customerId),
                  )
                : AppButton(
                    label: 'آرشیو کردن',
                    icon: AppIconName.file,
                    variant: AppButtonVariant.outline,
                    fullWidth: true,
                    onPressed: () => widget.onArchive?.call(customerId),
                  ),
          ),
        ],
      ],
    );
  }
}
