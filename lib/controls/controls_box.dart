import 'package:flutter/material.dart';

import '../common/extensions.dart';
import 'calendar.dart';
import 'settings.dart';

class ControlsBox extends StatelessWidget {
  final ControlsBoxController controller;

  const ControlsBox({
    Key key,
    @required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, widget) => ClipRect(
        child: Container(
          child: _buildChildForSelection(),
        ),
      ),
    );
  }

  Widget _buildChildForSelection() {
    if (controller.selection == ControlsBoxSelection.calendar) {
      return Calendar(
        selectedDay: controller.day,
        onSelect: (Day day) => controller.day = day,
      );
    } else if (controller.selection == ControlsBoxSelection.settings) {
      return Settings();
    } else {
      return Container();
    }
  }
}

class ControlsBoxController extends ValueNotifier<ControlsBoxValue> {
  ControlsBoxSelection get selection => value.selection;
  set selection(ControlsBoxSelection newValue) =>
      value = value.rebuildWith(selection: newValue);

  bool get boxOpen => value.boxOpen;
  set boxOpen(bool newValue) => value = value.rebuildWith(boxOpen: newValue);

  Day get day => value.day;
  set day(Day newValue) => value = value.rebuildWith(day: newValue);

  ControlsBoxController([ControlsBoxValue value])
      : super(
          value ??
              ControlsBoxValue(
                boxOpen: false,
                selection: ControlsBoxSelection.calendar,
                day: Day.now(),
              ),
        );
}

class ControlsBoxValue {
  final ControlsBoxSelection selection;
  final Day day;
  final bool boxOpen;

  ControlsBoxValue(
      {@required this.day, @required this.selection, @required this.boxOpen});

  ControlsBoxValue rebuildWith(
      {ControlsBoxSelection selection, bool boxOpen, Day day}) {
    return ControlsBoxValue(
      boxOpen: boxOpen ?? this.boxOpen,
      selection: selection ?? this.selection,
      day: day ?? this.day,
    );
  }
}

enum ControlsBoxSelection { calendar, settings }
