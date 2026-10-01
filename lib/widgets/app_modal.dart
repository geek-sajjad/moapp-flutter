import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Port of the web `app-modal`: a sheet sliding up from the bottom with a
/// title and a close (X) button. [builder] receives the sheet's context so
/// the content can close it with `Navigator.of(sheetContext).pop()`.
Future<T?> showAppModal<T>({
  required BuildContext context,
  required String title,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.black.withValues(alpha: 0.6),
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
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: media.size.height * 0.9),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            border: Border(
              top: BorderSide(color: AppColors.gray300),
              left: BorderSide(color: AppColors.gray300),
              right: BorderSide(color: AppColors.gray300),
            ),
            boxShadow: AppShadows.xxl,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsetsDirectional.only(
                    start: 20,
                    end: 12,
                    top: 10,
                    bottom: 10,
                  ),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppColors.gray300),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.gray900,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded, size: 22),
                        color: AppColors.gray500,
                        style: IconButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: child,
                ),
                SizedBox(height: media.padding.bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
