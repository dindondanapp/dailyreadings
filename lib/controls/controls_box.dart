import 'package:flutter/material.dart';

import '../common/extensions.dart';
import 'calendar.dart';
import 'controls_bar.dart';
import 'settings.dart';

class ControlsBox extends StatelessWidget {
  final ControlsBoxController controller;
  final void Function() onCalendarTap;
  final void Function() onSettingsTap;
  final double size;

  const ControlsBox({
    Key key,
    @required this.controller,
    @required this.size,
    @required this.onCalendarTap,
    @required this.onSettingsTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: controller,
        builder: (context, value, widget) {
          final color = controller.boxOpen == BoxOpenState.open ||
                  controller.boxOpen == BoxOpenState.opening
              ? Colors.grey[200]
              : Theme.of(context).canvasColor;
          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AnimatedContainer(
              curve: Curves.ease,
              duration: Duration(milliseconds: 500),
              color: color,
              child: Column(
                children: [
                  SizedBox(
                    height: size,
                    child: _buildChildForSelection(),
                  ),
                  ControlsBar(
                    date: controller.day,
                    controller: controller,
                    onCalendarTap: onCalendarTap,
                    onSettingsTap: onSettingsTap,
                  ),
                ],
              ),
            ),
          );
        });
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

  ControlsBoxValue rebuildWith(
      {ControlsBoxSelection selection, BoxOpenState boxOpen, Day day}) {
    return ControlsBoxValue(
      boxOpen: boxOpen ?? this.boxOpen,
      selection: selection ?? this.selection,
      day: day ?? this.day,
    );
  }
}

enum ControlsBoxSelection { calendar, settings }
enum BoxOpenState { open, closed, opening, closing }
