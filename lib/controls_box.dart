import 'package:flutter/material.dart';

class ControlsBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CalendarControl();
  }
}

class CalendarControl extends StatefulWidget {
  @override
  _CalendarControlState createState() => _CalendarControlState();
}

class _CalendarControlState extends State<CalendarControl> {
  @override
  Widget build(BuildContext context) {
    return _buildCalendar(DateTime.now());
  }

  Widget _buildCalendar(DateTime time) {
    return Column();
  }
}
