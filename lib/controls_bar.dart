import 'package:dailyreadings/controls_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';

import 'utils.dart';

class ControlsBar extends StatelessWidget {
  final DateTime date;
  final Function() calendarTapCallback;
  final Function() settingsTapCallback;
  final ControlsState state;
  // TODO: use a controller.
  const ControlsBar(
      {Key key,
      @required this.date,
      @required this.calendarTapCallback,
      @required this.settingsTapCallback,
      @required this.state})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 10),
      child: Material(
        borderRadius: BorderRadius.circular(7),
        clipBehavior: Clip.antiAlias,
        color: Colors.grey[300],
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            InkWell(
              // TODO: inherit colors
              child: Container(
                padding: EdgeInsets.all(7),
                child: Row(
                  children: [
                    Icon(SFSymbols.calendar,
                        color: state.boxOpen &&
                                state.selection == ControlsBoxSelection.calendar
                            ? Colors.black
                            : Colors.grey),
                    SizedBox(width: 10),
                    Text(
                      (date ?? DateTime.now()).toLocaleDateString(),
                      style: TextStyle(
                          color: state.boxOpen &&
                                  state.selection ==
                                      ControlsBoxSelection.calendar
                              ? Colors.black
                              : Colors.grey),
                    ),
                  ],
                ),
              ),
              onTap: calendarTapCallback,
            ),
            DecoratedBox(
              child: SizedBox(width: 1, height: 20),
              decoration: BoxDecoration(color: Colors.grey),
            ),
            InkWell(
              child: Container(
                padding: EdgeInsets.all(7),
                child: Icon(SFSymbols.gear,
                    color: state.boxOpen &&
                            state.selection == ControlsBoxSelection.settings
                        ? Colors.black
                        : Colors.grey),
              ),
              onTap: settingsTapCallback,
            )
          ],
        ),
      ),
    );
  }
}
