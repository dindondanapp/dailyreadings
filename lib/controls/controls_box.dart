import 'package:flutter/material.dart';

import '../common/extensions.dart';
import 'calendar.dart';
import 'settings.dart';

class ControlsBox extends StatelessWidget {
  final ControlsBoxController controller;

  num get _controlsBoxOpacity => controller.boxOpen ? 1 : 1;
  num get _controlsBoxHeight => controller.boxOpen ? null : null;

  const ControlsBox({
    Key key,
    @required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, widget) => AnimatedOpacity(
        duration: Duration(seconds: 1),
        opacity: _controlsBoxOpacity.toDouble(),
        child: AnimatedContainer(
          duration: Duration(seconds: 1),
          curve: Curves.fastOutSlowIn,
          height:
              _controlsBoxHeight != null ? _controlsBoxHeight.toDouble() : 400,
          child: SafeArea(
            child: ClipRect(
              child: Container(
                child: _buildChildForSelection(),
                margin: EdgeInsets.only(
                  top: 60,
                ),
              ),
            ),
          ),
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

  bool get barVisible => value.barVisible;
  set barVisible(bool newValue) =>
      value = value.rebuildWith(barVisible: newValue);

  Day get day => value.day;
  set day(Day newValue) => value = value.rebuildWith(day: newValue);

  void toggleCalendar() {
    if (selection == ControlsBoxSelection.calendar && boxOpen) {
      boxOpen = false;
    } else {
      boxOpen = true;
      selection = ControlsBoxSelection.calendar;
    }
  }

  void toggleSettings() {
    if (selection == ControlsBoxSelection.settings && boxOpen) {
      boxOpen = false;
    } else {
      boxOpen = true;
      selection = ControlsBoxSelection.settings;
    }
  }

  ControlsBoxController([ControlsBoxValue value])
      : super(
          value ??
              ControlsBoxValue(
                boxOpen: false,
                barVisible: true,
                selection: ControlsBoxSelection.calendar,
                day: Day.now(),
              ),
        );
}

class ControlsBoxValue {
  final ControlsBoxSelection selection;
  final bool boxOpen;
  final Day day;
  final bool barVisible;

  ControlsBoxValue(
      {@required this.day,
      @required this.selection,
      @required this.boxOpen,
      @required this.barVisible});

  ControlsBoxValue rebuildWith(
      {ControlsBoxSelection selection,
      bool boxOpen,
      Day day,
      bool barVisible}) {
    return ControlsBoxValue(
      boxOpen: boxOpen ?? this.boxOpen,
      selection: selection ?? this.selection,
      day: day ?? this.day,
      barVisible: barVisible ?? this.barVisible,
    );
  }
}

enum ControlsBoxSelection { calendar, settings }
