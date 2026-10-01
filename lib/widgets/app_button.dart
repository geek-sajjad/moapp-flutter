import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'app_icon.dart';

enum AppButtonVariant { primary, destructive, outline, secondary, ghost }

enum AppButtonSize { normal, sm, lg }

/// Port of the web `app-button` component.
class AppButton extends StatefulWidget {
  final String label;
  final AppIconName? icon;
  final double iconSize;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.label,
    this.icon,
    this.iconSize = 18,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.normal,
    this.fullWidth = false,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  bool get _disabled => widget.onPressed == null;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final (bg, pressedBg, fg, border, shadow) = switch (widget.variant) {
      AppButtonVariant.primary => (
          AppColors.blue600,
          AppColors.blue800,
          AppColors.white,
          null,
          AppShadows.md,
        ),
      AppButtonVariant.destructive => (
          AppColors.red600,
          AppColors.red800,
          AppColors.white,
          null,
          AppShadows.md,
        ),
      AppButtonVariant.outline => (
          AppColors.white,
          AppColors.gray100,
          AppColors.gray900,
          AppColors.gray300,
          AppShadows.sm,
        ),
      AppButtonVariant.secondary => (
          AppColors.gray200,
          AppColors.gray400,
          AppColors.gray900,
          null,
          AppShadows.sm,
        ),
      AppButtonVariant.ghost => (
          Colors.transparent,
          AppColors.gray200,
          AppColors.gray900,
          null,
          const <BoxShadow>[],
        ),
    };

    final (minHeight, hPadding, vPadding, fontSize) = switch (widget.size) {
      AppButtonSize.normal => (44.0, 20.0, 12.0, 14.0),
      AppButtonSize.sm => (40.0, 16.0, 10.0, 14.0),
      AppButtonSize.lg => (48.0, 24.0, 14.0, 16.0),
    };

    final content = Row(
      mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          AppIcon(widget.icon!, size: widget.iconSize, color: fg),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            widget.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: fg,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
        ),
      ],
    );

    return Opacity(
      opacity: _disabled ? 0.5 : 1,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _disabled ? null : (_) => _setPressed(true),
        onTapUp: _disabled ? null : (_) => _setPressed(false),
        onTapCancel: _disabled ? null : () => _setPressed(false),
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _pressed ? 0.98 : 1,
          duration: const Duration(milliseconds: 100),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            constraints: BoxConstraints(minHeight: minHeight),
            width: widget.fullWidth ? double.infinity : null,
            padding: EdgeInsets.symmetric(
              horizontal: hPadding,
              vertical: vPadding,
            ),
            decoration: BoxDecoration(
              color: _pressed ? pressedBg : bg,
              borderRadius: BorderRadius.circular(12),
              border: border != null ? Border.all(color: border, width: 2) : null,
              boxShadow: shadow,
            ),
            child: Center(widthFactor: 1, heightFactor: 1, child: content),
          ),
        ),
      ),
    );
  }
}
