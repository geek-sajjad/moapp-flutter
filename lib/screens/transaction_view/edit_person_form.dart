import 'package:flutter/material.dart';

import '../../theme/app_icons.dart';

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
  final IconData buttonIcon;
  final ValueChanged<PersonFormData> onSave;

  const EditPersonForm({
    super.key,
    required this.initialData,
    this.buttonText = 'ذخیره تغییرات',
    this.buttonIcon = AppIcons.save,
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
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _name,
          autofocus: true,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'نام مشتری',
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
            labelText: 'شماره تماس',
            hintText: 'مثال: +989123456789',
            hintTextDirection: TextDirection.ltr,
            prefixIcon: Icon(AppIcons.phone),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _address,
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
      ],
    );
  }
}
