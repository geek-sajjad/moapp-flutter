import 'package:flutter/material.dart';

const appFontFamily = 'Vazirmatn';

/// Brand blue of the web app (Tailwind blue-600), used as the M3 seed.
const _seedColor = Color(0xFF2563EB);

ThemeData buildAppTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: _seedColor,
    dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    brightness: brightness,
  );
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: appFontFamily,
  );
  final text = base.textTheme;

  final fieldBorder = OutlineInputBorder(borderRadius: BorderRadius.circular(12));

  return base.copyWith(
    extensions: [
      brightness == Brightness.light ? LedgerColors.light : LedgerColors.dark,
    ],
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      surfaceTintColor: scheme.surfaceTint,
      scrolledUnderElevation: 3,
    ),
    cardTheme: const CardThemeData(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: fieldBorder,
      enabledBorder: fieldBorder.copyWith(
        borderSide: BorderSide(color: scheme.outline),
      ),
      focusedBorder: fieldBorder.copyWith(
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 52),
        textStyle: text.labelLarge?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 52),
        textStyle: text.labelLarge?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      extendedTextStyle: text.labelLarge?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      showDragHandle: true,
    ),
    dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1),
  );
}

/// Debit (red) / credit (green) colors, tuned for each brightness.
@immutable
class LedgerColors extends ThemeExtension<LedgerColors> {
  final Color debit;
  final Color debitContainer;
  final Color onDebitContainer;
  final Color credit;
  final Color creditContainer;
  final Color onCreditContainer;

  const LedgerColors({
    required this.debit,
    required this.debitContainer,
    required this.onDebitContainer,
    required this.credit,
    required this.creditContainer,
    required this.onCreditContainer,
  });

  static const light = LedgerColors(
    debit: Color(0xFFC62828),
    debitContainer: Color(0xFFFFDAD6),
    onDebitContainer: Color(0xFF410002),
    credit: Color(0xFF2E7D32),
    creditContainer: Color(0xFFC8EFC4),
    onCreditContainer: Color(0xFF07390C),
  );

  static const dark = LedgerColors(
    debit: Color(0xFFFFB4AB),
    debitContainer: Color(0xFF6B1F1A),
    onDebitContainer: Color(0xFFFFDAD6),
    credit: Color(0xFF8DD889),
    creditContainer: Color(0xFF1D4A22),
    onCreditContainer: Color(0xFFC8EFC4),
  );

  static LedgerColors of(BuildContext context) =>
      Theme.of(context).extension<LedgerColors>() ?? light;

  @override
  LedgerColors copyWith({
    Color? debit,
    Color? debitContainer,
    Color? onDebitContainer,
    Color? credit,
    Color? creditContainer,
    Color? onCreditContainer,
  }) {
    return LedgerColors(
      debit: debit ?? this.debit,
      debitContainer: debitContainer ?? this.debitContainer,
      onDebitContainer: onDebitContainer ?? this.onDebitContainer,
      credit: credit ?? this.credit,
      creditContainer: creditContainer ?? this.creditContainer,
      onCreditContainer: onCreditContainer ?? this.onCreditContainer,
    );
  }

  @override
  LedgerColors lerp(LedgerColors? other, double t) {
    if (other == null) return this;
    return LedgerColors(
      debit: Color.lerp(debit, other.debit, t)!,
      debitContainer: Color.lerp(debitContainer, other.debitContainer, t)!,
      onDebitContainer: Color.lerp(onDebitContainer, other.onDebitContainer, t)!,
      credit: Color.lerp(credit, other.credit, t)!,
      creditContainer: Color.lerp(creditContainer, other.creditContainer, t)!,
      onCreditContainer:
          Color.lerp(onCreditContainer, other.onCreditContainer, t)!,
    );
  }
}
