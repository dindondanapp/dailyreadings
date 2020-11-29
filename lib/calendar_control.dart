import 'package:date_util/date_util.dart';
import 'package:flutter/material.dart';

import 'utils.dart';

class Calendar extends StatefulWidget {
  final CalendarController controller;
  final void Function(DateTime day) onSelect;

  const Calendar({Key? key, required this.onSelect, required this.controller})
      : super(key: key);

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  static int initialPage = 12;
  final pageController = PageController(initialPage: initialPage);
  final referenceDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: widget.controller,
        builder: (context, DateTime date, _) => _buildCalendar(date));
  }

  Widget _buildCalendar(DateTime selected) {
    return PageView.builder(
      controller: pageController,
      itemBuilder: (BuildContext context, index) {
        final monthOffset = index - initialPage;
        return _buildMonth(
            DateTime(referenceDay.year, referenceDay.month + monthOffset),
            selected);
      },
    );
  }

  Widget _buildMonth(DateTime date, DateTime selected) {
    final firstDay = DateTime(date.year, date.month, 1);
    final totalDays = DateUtil().daysInMonth(firstDay.month, firstDay.year);
    final totalWeeks = ((totalDays + (firstDay.weekday - 1)) / 7).ceil();
    final weekWidgets = List<TableRow>.generate(
      totalWeeks,
      (week) => TableRow(
        children: List<Widget>.generate(7, (weekday) {
          final day = firstDay
              .add(Duration(days: week * 7 + weekday - (firstDay.weekday - 1)));

          return _buildDay(
              day: day,
              month: date,
              selected: selected,
              onSelect: () => {widget.onSelect(day)});
        }),
      ),
    );

    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: Text(
            date.toLocaleMonthString().toUpperCase(),
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
                children: weekWidgets,
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDay(
      {required DateTime day,
      required DateTime month,
      required DateTime selected,
      void Function()? onSelect}) {
    final isSameDay = day.isSameDay(selected);

    final today = DateTime.now();
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

class CalendarController extends ValueNotifier<DateTime> {
  CalendarController(DateTime date) : super(date);
}
