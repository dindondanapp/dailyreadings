import 'package:date_util/date_util.dart';
import 'package:flutter/material.dart';

import '../common/extensions.dart';

/// A widget that displays a calendar and allows to select a day
class Calendar extends StatefulWidget {
  final Day selectedDay;
  final DayInterval availableInterval;
  final void Function(Day day) onSelect;

  /// Creates a Calendar widget
  /// A selected [day] must be provided and an [onSelect] function can be used
  /// to listen to day selection
  Calendar({
    Key key,
    @required this.selectedDay,
    @required this.onSelect,
    this.availableInterval = const DayInterval(),
  }) : super(key: key);

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  // Initial page index of the PageController.
  // Needs to be positive to allow scrolling in both directions.
  static int initialPage = 12;

  // Controller of the PageView widget.
  final pageController = PageController(initialPage: initialPage);

  // The current month is used as the initial page
  final initialPageMonth = Month.now();

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: pageController,
      itemBuilder: (BuildContext context, index) {
        final monthOffset = index - initialPage;
        return _buildMonthPage(
            Month(initialPageMonth.year, initialPageMonth.month + monthOffset),
            widget.selectedDay);
      },
    );
  }

  // Build a month page widget, which consists of a table of days
  Widget _buildMonthPage(Month month, Day selected) {
    final firstDay = Day(month.year, month.month, 1);
    final totalDays = DateUtil().daysInMonth(firstDay.month, firstDay.year);
    final totalWeeks = ((totalDays + (firstDay.weekday - 1)) / 7).ceil();
    final headingRow = TableRow(
      children: ['L', 'M', 'M', 'G', 'V', 'S', 'D']
          .map(
            (e) => Container(
              child: Text(
                e,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 4),
            ),
          )
          .toList(),
      decoration: BoxDecoration(
        border: Border.symmetric(
          horizontal:
              BorderSide(color: DefaultTextStyle.of(context).style.color),
        ),
      ),
    );
    final weekWidgets = List<TableRow>.generate(
      totalWeeks,
      (weekIndex) => TableRow(
        children: List<Widget>.generate(7, (weekdayIndex) {
          final day = firstDay.add(
            Duration(
              days: weekIndex * 7 + weekdayIndex - (firstDay.weekday - 1),
            ),
          );

          return _buildDay(
              day: day,
              month: month,
              selected: selected,
              onSelect: () => widget.onSelect(day));
        }),
      ),
    );

    return Container(
      padding: EdgeInsets.only(top: 20),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Text(
              month.toLocaleMonthString().toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 18,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 30),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 300, minHeight: 150),
                child: Table(
                  children: [
                    headingRow,
                    TableRow(
                      children: headingRow.children
                          .map((e) => SizedBox(
                                height: 10,
                              ))
                          .toList(),
                    ),
                    ...weekWidgets
                  ],
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build a day widget, with a different style whether:
  // - it is selected
  // - it is today
  // - it belongs to the displayed month
  // - it belongs to the previous or next month

  Widget _buildDay({
    @required Day day,
    @required Month month,
    @required Day selected,
    void Function() onSelect,
  }) {
    final isSameDay = day.isSameDay(selected);

    final today = Day.now();
    final isToday = day.isSameDay(today);
    final isAvailable = widget.availableInterval.hasInside(day);

    final color = isSameDay
        ? Theme.of(context).accentColor
        : isToday
            ? Theme.of(context).accentColor.withOpacity(0.6)
            : isAvailable
                ? Colors.grey[400]
                : Colors.grey[300];

    final textColor = isSameDay ? Colors.white : Colors.grey[800];

    if (day.month != month.month) {
      return Center(
        child: Text(
          day.day.toString(),
          style:
              TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold),
        ),
      );
    } else {
      return Container(
        width: 30,
        height: 30,
        margin: EdgeInsets.all(2),
        child: Material(
          shape: CircleBorder(),
          color: color,
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            child: Center(
              child: Text(
                day.day.toString(),
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              ),
            ),
            onTap: onSelect,
          ),
        ),
      );
    }
  }
}
