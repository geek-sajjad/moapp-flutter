import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Port of the web `app-toggle` (switch on the left, label next to it).
class AppToggle extends StatelessWidget {
  final bool checked;
  final String label;
  final ValueChanged<bool> onChanged;
  final bool disabled;

  const AppToggle({
    super.key,
    required this.checked,
    required this.label,
    required this.onChanged,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final track = GestureDetector(
      onTap: disabled ? null : () => onChanged(!checked),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 44,
        height: 24,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: checked ? AppColors.blue600 : AppColors.gray300,
          borderRadius: BorderRadius.circular(999),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 150),
          alignment: checked ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 16,
            height: 16,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );

    // The web toggle row is `dir="ltr"`: switch first (left), then label.
    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            track,
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: disabled ? null : () => onChanged(!checked),
                child: Text(
                  label,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
