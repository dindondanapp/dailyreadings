import 'package:flutter/material.dart';

import 'calendar_control.dart';
import 'utils.dart';

class ControlsBox extends StatelessWidget {
  final void Function(Day day) onChangeDay;
  final CalendarController calendarController;

  const ControlsBox(
      {Key? key, required this.onChangeDay, required this.calendarController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        child: Center(
          child: Calendar(
            onSelect: onChangeDay,
            controller: calendarController,
          ),
        ),
        margin: EdgeInsets.only(
          top: 60,
        ),
      ),
    );
  }
}
