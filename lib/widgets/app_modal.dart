import 'package:flutter/material.dart';

import '../theme/app_icons.dart';

/// M3 modal bottom sheet with a drag handle, a title and a close button.
/// [builder] receives the sheet's context so the content can close it with
/// `Navigator.of(sheetContext).pop()`.
Future<T?> showAppModal<T>({
  required BuildContext context,
  required String title,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) => _AppModalSheet(
      title: title,
      child: builder(sheetContext),
    ),
  );
}

class _AppModalSheet extends StatelessWidget {
  final String title;
  final Widget child;

  const _AppModalSheet({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + media.padding.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'بستن',
                  icon: const Icon(AppIcons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
