import 'package:flutter/material.dart';

import '../../widgets/app_button.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_text_field.dart';

class PersonFormData {
  final String name;
  final String phone;
  final String address;

  const PersonFormData({this.name = '', this.phone = '', this.address = ''});
}

/// Port of the web `app-edit-person-form` (edit customer from the
/// transactions page; phone is optional here, like the web app).
class EditPersonForm extends StatefulWidget {
  final PersonFormData initialData;
  final String buttonText;
  final AppIconName buttonIcon;
  final ValueChanged<PersonFormData> onSave;

  const EditPersonForm({
    super.key,
    required this.initialData,
    this.buttonText = 'ذخیره تغییرات',
    this.buttonIcon = AppIconName.save,
    required this.onSave,
  });

  @override
  State<EditPersonForm> createState() => _EditPersonFormState();
}

class _EditPersonFormState extends State<EditPersonForm> {
  late final TextEditingController _name =
      TextEditingController(text: widget.initialData.name);
  late final TextEditingController _phone =
      TextEditingController(text: widget.initialData.phone);
  late final TextEditingController _address =
      TextEditingController(text: widget.initialData.address);

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  void _handleSave() {
    widget.onSave(PersonFormData(
      name: _name.text,
      phone: _phone.text,
      address: _address.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const FieldLabel('نام مشتری'),
        AppTextField(
          controller: _name,
          hintText: 'نام مشتری را وارد کنید',
        ),
        const SizedBox(height: 20),
        const FieldLabel('شماره تماس'),
        AppTextField(
          controller: _phone,
          hintText: 'مثال: +989123456789',
          textDirection: TextDirection.ltr,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 20),
        const FieldLabel('توضیحات'),
        AppTextField(
          controller: _address,
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
      ],
    );
  }
}
