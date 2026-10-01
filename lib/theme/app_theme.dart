import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

const appFontFamily = 'Vazirmatn';

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: appFontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.blue600,
      primary: AppColors.blue600,
      surface: AppColors.white,
      error: AppColors.red600,
    ),
    scaffoldBackgroundColor: AppColors.white,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(
      fontFamily: appFontFamily,
      bodyColor: AppColors.gray900,
      displayColor: AppColors.gray900,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.blue600,
      selectionColor: AppColors.blue200,
      selectionHandleColor: AppColors.blue600,
    ),
    appBarTheme: const AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
  );
}
