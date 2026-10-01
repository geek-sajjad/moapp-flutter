import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../theme/app_colors.dart';
import '../utils/persian_format.dart';
import 'app_icon.dart';

/// Port of the web `app-persian-datepicker`.
///
/// [value] / [onChanged] use a Gregorian local date in `yyyy-MM-dd` format.
/// The calendar opens inline below the field and closes on outside tap.
class PersianDatePicker extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final String placeholder;

  const PersianDatePicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.placeholder = 'تاریخ را انتخاب کنید',
  });

  @override
  State<PersianDatePicker> createState() => _PersianDatePickerState();
}

class _PersianDatePickerState extends State<PersianDatePicker> {
  bool _isOpen = false;
  final _calendarKey = GlobalKey();
  late int _year;
  late int _month;

  @override
  void initState() {
    super.initState();
    _syncMonthWithValue();
  }

  @override
  void didUpdateWidget(covariant PersianDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) _syncMonthWithValue();
  }

  void _syncMonthWithValue() {
    final selected = _selectedJalali ?? Jalali.now();
    _year = selected.year;
    _month = selected.month;
  }

  Jalali? get _selectedJalali {
    final date = parseIsoDate(widget.value);
    return date == null ? null : Jalali.fromDateTime(date);
  }

  void _toggle() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _isOpen = !_isOpen);
    if (_isOpen) {
      // Wait for AnimatedSize to finish, then bring the calendar into view.
      Future.delayed(const Duration(milliseconds: 220), () {
        final ctx = _calendarKey.currentContext;
        if (mounted && ctx != null) {
          Scrollable.ensureVisible(
            ctx,
            duration: const Duration(milliseconds: 200),
            alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
          );
        }
      });
    }
  }

  void _close() {
    if (_isOpen && mounted) setState(() => _isOpen = false);
  }

  /// Closes the calendar only on a real tap outside (pointer released close
  /// to where it went down), so scrolling the page does not close it.
  void _onTapOutside(PointerDownEvent down) {
    if (!_isOpen) return;
    void route(PointerEvent event) {
      if (event.pointer != down.pointer) return;
      if (event is PointerUpEvent || event is PointerCancelEvent) {
        GestureBinding.instance.pointerRouter.removeGlobalRoute(route);
        if (event is PointerUpEvent &&
            (event.position - down.position).distance < kTouchSlop) {
          _close();
        }
      }
    }

    GestureBinding.instance.pointerRouter.addGlobalRoute(route);
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

  void _select(Jalali day) {
    widget.onChanged(toIsoDate(day.toDateTime()));
    setState(() => _isOpen = false);
  }

  void _selectToday() => _select(Jalali.now());

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
    return TapRegion(
      onTapOutside: _onTapOutside,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildField(),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.topCenter,
            child: _isOpen ? _buildCalendar() : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _buildField() {
    final display = formatJalaliDisplay(widget.value);
    return GestureDetector(
      onTap: _toggle,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isOpen ? AppColors.blue500 : AppColors.gray300,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            const AppIcon(AppIconName.calendar, size: 18, color: AppColors.gray400),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                display.isEmpty ? widget.placeholder : display,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: display.isEmpty ? FontWeight.w400 : FontWeight.w500,
                  color: display.isEmpty ? AppColors.gray400 : AppColors.gray900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    final selected = _selectedJalali;
    final today = Jalali.now();
    final days = _calendarDays();

    return Container(
      key: _calendarKey,
      margin: const EdgeInsets.only(top: 8),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200, width: 2),
        boxShadow: AppShadows.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [AppColors.blue500, AppColors.blue600],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: _HeaderButton(
                    onTap: _previousMonth,
                    children: const [
                      AppIcon(AppIconName.chevronRight, size: 20, color: AppColors.white),
                      Flexible(child: _HeaderLabel('ماه قبل')),
                    ],
                  ),
                ),
                Expanded(
                  child: Text(
                    jalaliMonthTitle(_year, _month),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                Flexible(
                  child: _HeaderButton(
                    onTap: _nextMonth,
                    children: const [
                      Flexible(child: _HeaderLabel('ماه بعد')),
                      AppIcon(AppIconName.chevronLeft, size: 20, color: AppColors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Calendar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                GridView.count(
                  crossAxisCount: 7,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  childAspectRatio: 1.4,
                  padding: const EdgeInsets.only(bottom: 8),
                  children: [
                    for (final day in persianWeekDays)
                      Center(
                        child: Text(
                          day,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.gray600,
                          ),
                        ),
                      ),
                  ],
                ),
                GridView.count(
                  crossAxisCount: 7,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  padding: EdgeInsets.zero,
                  children: [
                    for (final day in days)
                      if (day == null)
                        const SizedBox.shrink()
                      else
                        _DayCell(
                          day: day,
                          isSelected: _isSameDay(day, selected),
                          isToday: _isSameDay(day, today),
                          onTap: () => _select(day),
                        ),
                  ],
                ),
              ],
            ),
          ),

          // Today button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.gray200)),
            ),
            child: Material(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: _selectToday,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Text(
                    'امروز',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.gray700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

bool _isSameDay(Jalali a, Jalali? b) =>
    b != null && a.year == b.year && a.month == b.month && a.day == b.day;

class _HeaderLabel extends StatelessWidget {
  final String text;

  const _HeaderLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(color: AppColors.white),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final VoidCallback onTap;
  final List<Widget> children;

  const _HeaderButton({required this.onTap, required this.children});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(mainAxisSize: MainAxisSize.min, children: children),
        ),
      ),
    );
  }
}

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
    final (bg, fg) = isSelected
        ? (AppColors.blue600, AppColors.white)
        : isToday
            ? (AppColors.blue50, AppColors.blue600)
            : (Colors.transparent, AppColors.gray700);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(8),
      elevation: isSelected ? 2 : 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Center(
          child: Text(
            toPersianNumbers('${day.day}'),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }
}
