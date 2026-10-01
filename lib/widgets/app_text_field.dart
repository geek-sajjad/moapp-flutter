import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import 'app_icon.dart';

/// Input / textarea styled like the web forms
/// (`min-h-[48px] px-4 py-3 border-2 border-gray-300 rounded-xl`).
class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final AppIconName? leadingIcon;
  final TextDirection? textDirection;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final Widget? trailing;
  final bool shadow;

  /// Empty space reserved at the start of the field (for an overlaid label).
  final double? leadingSpacer;

  const AppTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.leadingIcon,
    this.textDirection,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.trailing,
    this.shadow = false,
    this.leadingSpacer,
  });

  static OutlineInputBorder _border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: 2),
      );

  @override
  Widget build(BuildContext context) {
    final field = TextField(
      controller: controller,
      onChanged: onChanged,
      maxLines: maxLines,
      minLines: maxLines,
      keyboardType:
          keyboardType ?? (maxLines > 1 ? TextInputType.multiline : null),
      inputFormatters: inputFormatters,
      textDirection: textDirection,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.gray900,
      ),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: AppColors.white,
        hintText: hintText,
        hintTextDirection: textDirection,
        hintStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.gray400,
        ),
        constraints: const BoxConstraints(minHeight: 48),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        prefixIcon: leadingIcon != null
            ? Padding(
                padding: const EdgeInsetsDirectional.only(start: 16, end: 12),
                child: AppIcon(leadingIcon!, size: 20, color: AppColors.gray400),
              )
            : leadingSpacer != null
                ? SizedBox(width: leadingSpacer)
                : null,
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: trailing,
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        border: _border(AppColors.gray300),
        enabledBorder: _border(AppColors.gray300),
        focusedBorder: _border(AppColors.blue500),
      ),
    );

    if (!shadow) return field;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.sm,
      ),
      child: field,
    );
  }
}

/// `block text-sm font-bold text-gray-900` label used above inputs.
class FieldLabel extends StatelessWidget {
  final String text;

  const FieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.gray900,
        ),
      ),
    );
  }
}
