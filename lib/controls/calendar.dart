import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dailyreadings/common/enums.dart';
import 'package:date_util/date_util.dart';
import 'package:flutter/material.dart';

import '../common/extensions.dart';

/// A widget that displays a calendar and allows to select a day
class Calendar extends StatefulWidget {
  final Day selectedDay;
  final void Function(Day day) onSelect;

  /// Creates a Calendar widget
  /// A selected [day] must be provided and an [onSelect] function can be used
  /// to listen to day selection
  Calendar({Key key, @required this.selectedDay, @required this.onSelect})
      : super(key: key);

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

  // A stream of metadata from the backend
  final Stream<Map<Rite, DayInterval>> metaStream = FirebaseFirestore.instance
      .collection('meta')
      .doc('calendar')
      .snapshots()
      .map((event) {
        return Map.fromEntries(
          Rite.values.map((rite) {
            try {
              final riteMeta =
                  event.get(rite.enumSerialize()) as Map<String, dynamic>;
              final start =
                  Day.fromDateTime((riteMeta['start'] as Timestamp).toDate());
              final end =
                  Day.fromDateTime((riteMeta['end'] as Timestamp).toDate());

              return MapEntry<Rite, DayInterval>(
                rite,
                DayInterval(
                  start: start,
                  end: end,
                ),
              );
            } catch (e) {}

            return MapEntry(rite, DayInterval());
          }),
        );
      })
      .where((event) => event != null)
      .distinct();

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
            (e) => Text(
              e,
              textAlign: TextAlign.center,
            ),
          )
          .toList(),
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

    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: Text(
            month.toLocaleMonthString().toUpperCase(),
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 50),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 300, minHeight: 150),
              child: Table(
                children: [headingRow, ...weekWidgets],
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              ),
            ),
          ),
        ),
      ],
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

    final color = isSameDay
        ? Theme.of(context).primaryColor
        : isToday
            ? Theme.of(context).primaryColor.toMaterialColor()[200]
            : Colors.grey[350];

    final textColor = isSameDay ? Colors.white : Colors.grey[800];

    if (day.month != month.month) {
      return Center(
        child: Text(
          day.day.toString(),
          style: TextStyle(color: Colors.grey[500]),
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
