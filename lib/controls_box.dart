import 'package:dailyreadings/settings_repository.dart';
import 'package:flutter/material.dart';

import 'calendar.dart';
import 'settings.dart';
import 'utils.dart';

class ControlsBox extends StatelessWidget {
  final void Function(Day day) onChangeDay;
  final CalendarController calendarController;
  final SettingsRepository settingsRepository;
  final ControlsState state;

  num get _controlsBoxOpacity => state.boxOpen ? 1 : 0;
  num? get _controlsBoxHeight => state.boxOpen ? null : 0;

  const ControlsBox(
      {Key? key,
      required this.onChangeDay,
      required this.calendarController,
      required this.state,
      required this.settingsRepository})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: Duration(seconds: 1),
      opacity: _controlsBoxOpacity.toDouble(),
      child: AnimatedContainer(
        duration: Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
        height:
            _controlsBoxHeight != null ? _controlsBoxHeight!.toDouble() : 400,
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
    );
  }

  Widget _buildChildForSelection() {
    if (state.selection == ControlsBoxSelection.calendar) {
      return Calendar(controller: calendarController);
    } else if (state.selection == ControlsBoxSelection.settings) {
      return Settings(controller: settingsRepository);
    } else {
      return Container();
    }
  }
}

// TODO: Should probably be a ValueNotifier
class ControlsState {
  final ControlsBoxSelection selection;
  final bool boxOpen;

  ControlsState({required this.selection, required this.boxOpen});

  ControlsState rebuildWith({ControlsBoxSelection? selection, bool? boxOpen}) {
    return ControlsState(
      boxOpen: boxOpen ?? this.boxOpen,
      selection: selection ?? this.selection,
    );
  }
}

enum ControlsBoxSelection { calendar, settings }
