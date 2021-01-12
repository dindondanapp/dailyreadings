import 'package:dailyreadings/common/extensions.dart';
import 'package:flutter/material.dart';

class ControlsBoxController extends ValueNotifier<ControlsBoxValue> {
  ControlsBoxSelection get selection => value.selection;
  set selection(ControlsBoxSelection newValue) =>
      value = value.rebuildWith(selection: newValue);

  BoxOpenState get boxOpen => value.boxOpen;
  set boxOpen(BoxOpenState newValue) =>
      value = value.rebuildWith(boxOpen: newValue);

  Day get day => value.day;
  set day(Day newValue) => value = value.rebuildWith(day: newValue);

  ControlsBoxController([ControlsBoxValue value])
      : super(
          value ??
              ControlsBoxValue(
                boxOpen: BoxOpenState.closed,
                selection: ControlsBoxSelection.calendar,
                day: Day.now(),
              ),
        );
}

class ControlsBoxValue {
  final ControlsBoxSelection selection;
  final Day day;
  final BoxOpenState boxOpen;

  ControlsBoxValue(
      {@required this.day, @required this.selection, @required this.boxOpen});

  ControlsBoxValue rebuildWith({
    ControlsBoxSelection selection,
    BoxOpenState boxOpen,
    Day day,
  }) {
    return ControlsBoxValue(
      boxOpen: boxOpen ?? this.boxOpen,
      selection: selection ?? this.selection,
      day: day ?? this.day,
    );
  }
}

enum ControlsBoxSelection { calendar, settings }
enum BoxOpenState { open, closed, opening, closing }
