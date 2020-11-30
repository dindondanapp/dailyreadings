import 'package:dailyreadings/settings_repository.dart';
import 'package:flutter/material.dart';

import 'calendar_control.dart';
import 'controls_bar.dart';
import 'utils.dart';

class ControlsBox extends StatelessWidget {
  final void Function(Day day) onChangeDay;
  final CalendarController calendarController;
  final SettingsRepository settingsRepository;
  final ControlsBarSelection selection;

  num get _controlsBoxOpacity => selection == ControlsBarSelection.none ? 0 : 1;
  num? get _controlsBoxHeight =>
      selection == ControlsBarSelection.none ? 0 : null;

  const ControlsBox(
      {Key? key,
      required this.onChangeDay,
      required this.calendarController,
      required this.selection,
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
          child: Container(
            child: Center(
              child: _buildChildForSelection(),
            ),
            margin: EdgeInsets.only(
              top: 60,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChildForSelection() {
    if (selection == ControlsBarSelection.calendar) {
      return Calendar(
        onSelect: onChangeDay,
        controller: calendarController,
      );
    } else if (selection == ControlsBarSelection.settings) {
      return DropdownButton<ThemeSetting>(
        value: settingsRepository.theme,
        items: [
          DropdownMenuItem(
              value: ThemeSetting.system,
              child: Text(
                'Auto',
                style: TextStyle(color: Colors.black),
              )),
          DropdownMenuItem(
              value: ThemeSetting.dark,
              child: Text(
                'Scuro',
                style: TextStyle(color: Colors.black),
              )),
          DropdownMenuItem(
              value: ThemeSetting.light,
              child: Text('Chiaro', style: TextStyle(color: Colors.black))),
        ],
        onChanged: (value) => settingsRepository.theme = value!,
      );
    } else {
      return Container();
    }
  }
}
