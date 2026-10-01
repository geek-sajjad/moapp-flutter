import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../theme/app_icons.dart';
import '../utils/persian_format.dart';

/// Port of the web `app-persian-datepicker`: an outlined field that opens an
/// M3-style Jalali calendar dialog.
///
/// [value] / [onChanged] use a Gregorian local date in `yyyy-MM-dd` format.
class PersianDatePicker extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final String? label;
  final String placeholder;

  const PersianDatePicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.placeholder = 'تاریخ را انتخاب کنید',
  });

  Jalali? get _selectedJalali {
    final date = parseIsoDate(value);
    return date == null ? null : Jalali.fromDateTime(date);
  }

  Future<void> _open(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final picked = await showDialog<Jalali>(
      context: context,
      builder: (_) => _JalaliCalendarDialog(selected: _selectedJalali),
    );
    if (picked != null) onChanged(toIsoDate(picked.toDateTime()));
  }

  @override
  Widget build(BuildContext context) {
    final display = formatJalaliDisplay(value);
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => _open(context),
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        isEmpty: display.isEmpty,
        decoration: InputDecoration(
          labelText: label,
          hintText: placeholder,
          prefixIcon: const Icon(AppIcons.calendar),
        ),
        child: Text(
          display,
          style: theme.textTheme.bodyLarge,
        ),
      ),
    );
  }
}

class _JalaliCalendarDialog extends StatefulWidget {
  final Jalali? selected;

  const _JalaliCalendarDialog({required this.selected});

  @override
  State<_JalaliCalendarDialog> createState() => _JalaliCalendarDialogState();
}

class _JalaliCalendarDialogState extends State<_JalaliCalendarDialog> {
  late int _year;
  late int _month;

  @override
  void initState() {
    super.initState();
    final initial = widget.selected ?? Jalali.now();
    _year = initial.year;
    _month = initial.month;
  }

  void _previousMonth() {
    setState(() {
      if (_month == 1) {
        _month = 12;
        _year--;
      } else {
        _month--;
      }
    });
  }

  void _nextMonth() {
    setState(() {
      if (_month == 12) {
        _month = 1;
        _year++;
      } else {
        _month++;
      }
    });
  }

  /// Days of the visible month, with leading `null`s so the first day
  /// lines up under its week day (week starts on Saturday).
  List<Jalali?> _calendarDays() {
    final first = Jalali(_year, _month, 1);
    final leading = first.weekDay - 1; // weekDay: 1 = Saturday ... 7 = Friday
    return [
      for (var i = 0; i < leading; i++) null,
      for (var d = 1; d <= first.monthLength; d++) Jalali(_year, _month, d),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final selected = widget.selected;
    final today = Jalali.now();
    final selectedText = selected == null
        ? 'تاریخ را انتخاب کنید'
        : formatJalaliDisplay(toIsoDate(selected.toDateTime()));

    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'انتخاب تاریخ',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    selectedText,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),

            // Month navigation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _previousMonth,
                    tooltip: 'ماه قبل',
                    icon: const Icon(AppIcons.previous),
                  ),
                  Expanded(
                    child: Text(
                      jalaliMonthTitle(_year, _month),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _nextMonth,
                    tooltip: 'ماه بعد',
                    icon: const Icon(AppIcons.next),
                  ),
                ],
              ),
            ),

            // Calendar grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      for (final day in persianWeekDays)
                        Expanded(
                          child: SizedBox(
                            height: 36,
                            child: Center(
                              child: Text(
                                day,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  GridView.count(
                    crossAxisCount: 7,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    children: [
                      for (final day in _calendarDays())
                        if (day == null)
                          const SizedBox.shrink()
                        else
                          _DayCell(
                            day: day,
                            isSelected: _isSameDay(day, selected),
                            isToday: _isSameDay(day, today),
                            onTap: () => Navigator.of(context).pop(day),
                          ),
                    ],
                  ),
                ],
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(Jalali.now()),
                    child: const Text('امروز'),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('انصراف'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

bool _isSameDay(Jalali a, Jalali? b) =>
    b != null && a.year == b.year && a.month == b.month && a.day == b.day;

class _DayCell extends StatelessWidget {
  final Jalali day;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fg = isSelected
        ? scheme.onPrimary
        : isToday
            ? scheme.primary
            : scheme.onSurface;

    return Padding(
      padding: const EdgeInsets.all(2),
      child: Material(
        color: isSelected ? scheme.primary : Colors.transparent,
        shape: CircleBorder(
          side: isToday && !isSelected
              ? BorderSide(color: scheme.primary)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Center(
            child: Text(
              toPersianNumbers('${day.day}'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: fg,
                fontWeight: isSelected || isToday ? FontWeight.w700 : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
