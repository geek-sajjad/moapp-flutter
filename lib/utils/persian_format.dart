import 'package:shamsi_date/shamsi_date.dart';

const _persianDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
const _arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

const jalaliMonthNames = [
  'فروردین',
  'اردیبهشت',
  'خرداد',
  'تیر',
  'مرداد',
  'شهریور',
  'مهر',
  'آبان',
  'آذر',
  'دی',
  'بهمن',
  'اسفند',
];

/// Week days starting from Saturday (same as the web date picker).
const persianWeekDays = ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'];

/// Converts English digits to Persian digits.
String toPersianNumbers(String input) {
  return input.replaceAllMapped(
    RegExp(r'[0-9]'),
    (m) => _persianDigits[int.parse(m.group(0)!)],
  );
}

/// Converts Persian / Arabic-Indic digits to English digits.
String toEnglishNumbers(String input) {
  var out = input;
  for (var i = 0; i < 10; i++) {
    out = out.replaceAll(_persianDigits[i], '$i').replaceAll(_arabicDigits[i], '$i');
  }
  return out;
}

String _groupThousands(int num, String separator) {
  final negative = num < 0;
  final digits = num.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(separator);
    buffer.write(digits[i]);
  }
  return '${negative ? '-' : ''}$buffer';
}

/// Equivalent of `num.toLocaleString('fa-IR')`: Persian digits with the
/// Arabic thousands separator (٬).
String formatNumberFa(int num) => toPersianNumbers(_groupThousands(num, '٬'));

/// Equivalent of `Number(x).toLocaleString('en-US')`.
String formatNumberEn(int num) => _groupThousands(num, ',');

/// Gregorian local date -> `yyyy-MM-dd`.
String toIsoDate(DateTime date) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${date.year.toString().padLeft(4, '0')}-${two(date.month)}-${two(date.day)}';
}

/// `yyyy-MM-dd` (or any ISO string) -> local Gregorian date, or null.
DateTime? parseIsoDate(String value) {
  if (value.isEmpty) return null;
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(value);
  if (match == null) return null;
  return DateTime(
    int.parse(match.group(1)!),
    int.parse(match.group(2)!),
    int.parse(match.group(3)!),
  );
}

String todayIsoDate() => toIsoDate(DateTime.now());

/// Port of `PersianCalendarService.formatDisplayValue`:
/// Gregorian date string -> Jalali `yyyy/MM/dd` with Persian digits.
String formatJalaliDisplay(String gregorianDate) {
  final date = parseIsoDate(gregorianDate);
  if (date == null) return '';
  final j = Jalali.fromDateTime(date);
  String two(int n) => n.toString().padLeft(2, '0');
  return toPersianNumbers('${j.year}/${two(j.month)}/${two(j.day)}');
}

/// Equivalent of `new Date().toLocaleDateString('fa-IR')` (no zero padding).
String currentJalaliDateFa() {
  final j = Jalali.now();
  return toPersianNumbers('${j.year}/${j.month}/${j.day}');
}

/// `MMMM yyyy` in Jalali with Persian digits, e.g. "مهر ۱۴۰۵".
String jalaliMonthTitle(int year, int month) {
  return toPersianNumbers('${jalaliMonthNames[month - 1]} $year');
}
