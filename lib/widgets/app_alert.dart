import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum AlertType { success, error, info, warning }

class AlertConfig {
  final String message;
  final AlertType type;

  const AlertConfig(this.message, this.type);
}

/// Port of the web `AlertService` (toast at the top of the screen).
class AlertService {
  AlertService._();

  static final AlertService instance = AlertService._();

  final ValueNotifier<AlertConfig?> alert = ValueNotifier(null);
  Timer? _timer;

  void show(String message, {AlertType type = AlertType.info, Duration? duration}) {
    _timer?.cancel();
    alert.value = AlertConfig(message, type);
    _timer = Timer(duration ?? const Duration(milliseconds: 2000), hide);
  }

  void showSuccess(String message, {Duration? duration}) =>
      show(message, type: AlertType.success, duration: duration);

  void showError(String message, {Duration? duration}) =>
      show(message, type: AlertType.error, duration: duration);

  void showInfo(String message, {Duration? duration}) =>
      show(message, type: AlertType.info, duration: duration);

  void hide() {
    _timer?.cancel();
    alert.value = null;
  }
}

/// Renders the current alert above everything else (incl. bottom sheets).
/// Used from `MaterialApp.builder`.
class AlertHost extends StatelessWidget {
  final Widget child;

  const AlertHost({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        ValueListenableBuilder<AlertConfig?>(
          valueListenable: AlertService.instance.alert,
          builder: (context, alert, _) {
            if (alert == null) return const SizedBox.shrink();
            return Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              left: 12,
              right: 12,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 448),
                  child: _AlertToast(key: ValueKey(alert), alert: alert),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _AlertToast extends StatelessWidget {
  final AlertConfig alert;

  const _AlertToast({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border, icon) = switch (alert.type) {
      AlertType.success => (
          AppColors.green50,
          AppColors.green900,
          AppColors.green200,
          Icons.check_circle_outline,
        ),
      AlertType.error => (
          AppColors.red50,
          AppColors.red900,
          AppColors.red200,
          Icons.highlight_off,
        ),
      AlertType.warning => (
          AppColors.yellow50,
          AppColors.yellow900,
          AppColors.yellow200,
          Icons.warning_amber_rounded,
        ),
      AlertType.info => (
          AppColors.blue50,
          AppColors.blue900,
          AppColors.blue200,
          Icons.info_outline,
        ),
    };

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, -12 * (1 - t)), child: child),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: GestureDetector(
          onTap: AlertService.instance.hide,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: border, width: 2),
              boxShadow: AppShadows.xxl,
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: fg),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    alert.message,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: fg,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
