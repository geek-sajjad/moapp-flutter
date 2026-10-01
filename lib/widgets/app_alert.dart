import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_icons.dart';
import '../theme/app_theme.dart';

enum AlertType { success, error, info, warning }

class AlertConfig {
  final String message;
  final AlertType type;

  const AlertConfig(this.message, this.type);
}

/// Port of the web `AlertService`. Messages are shown as an M3 snackbar.
class AlertService {
  AlertService._();

  static final AlertService instance = AlertService._();

  final ValueNotifier<AlertConfig?> alert = ValueNotifier(null);
  Timer? _timer;

  void show(String message, {AlertType type = AlertType.info, Duration? duration}) {
    _timer?.cancel();
    alert.value = AlertConfig(message, type);
    _timer = Timer(duration ?? const Duration(milliseconds: 2500), hide);
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

/// Renders the current alert above everything else (incl. bottom sheets and
/// dialogs, which a Scaffold snackbar would be hidden behind).
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
            final media = MediaQuery.of(context);
            final bottomInset = media.viewInsets.bottom > media.padding.bottom
                ? media.viewInsets.bottom
                : media.padding.bottom;
            return Positioned(
              bottom: bottomInset + 16,
              left: 16,
              right: 16,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: _AlertSnackbar(key: ValueKey(alert), alert: alert),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _AlertSnackbar extends StatelessWidget {
  final AlertConfig alert;

  const _AlertSnackbar({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    // The snackbar uses the inverse surface, so take accent colors from the
    // opposite brightness.
    final inverseLedger = theme.brightness == Brightness.light
        ? LedgerColors.dark
        : LedgerColors.light;

    final (iconColor, icon) = switch (alert.type) {
      AlertType.success => (inverseLedger.credit, AppIcons.success),
      AlertType.error => (inverseLedger.debit, AppIcons.error),
      AlertType.warning => (Colors.amber, AppIcons.warning),
      AlertType.info => (scheme.inversePrimary, AppIcons.info),
    };

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, 16 * (1 - t)), child: child),
      ),
      child: Material(
        color: scheme.inverseSurface,
        elevation: 6,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: AlertService.instance.hide,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, size: 22, color: iconColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    alert.message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onInverseSurface,
                      fontWeight: FontWeight.w500,
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
