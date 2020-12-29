import 'package:flutter/material.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';

import '../common/extensions.dart';
import 'controls_box.dart';

class ControlsBar extends StatelessWidget {
  final DateTime date;
  final ControlsBoxController controller;
  final void Function() onCalendarTap;
  final void Function() onSettingsTap;
  const ControlsBar(
      {Key key,
      @required this.date,
      @required this.controller,
      this.onCalendarTap,
      this.onSettingsTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, widget) => Material(
        borderRadius: BorderRadius.circular(7),
        clipBehavior: Clip.antiAlias,
        color: Colors.grey[300],
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              // TODO: inherit colors
              child: Container(
                padding: EdgeInsets.all(7),
                child: Row(
                  children: [
                    Icon(SFSymbols.calendar,
                        color: controller.boxOpen &&
                                controller.selection ==
                                    ControlsBoxSelection.calendar
                            ? Colors.black
                            : Colors.grey),
                    SizedBox(width: 10),
                    Text(
                      (date ?? DateTime.now()).toLocaleDateString(),
                      style: TextStyle(
                          color: controller.boxOpen &&
                                  controller.selection ==
                                      ControlsBoxSelection.calendar
                              ? Colors.black
                              : Colors.grey),
                    ),
                  ],
                ),
              ),
              onTap: onCalendarTap,
            ),
            DecoratedBox(
              child: SizedBox(width: 1, height: 20),
              decoration: BoxDecoration(color: Colors.grey),
            ),
            InkWell(
              child: Container(
                padding: EdgeInsets.all(7),
                child: Icon(SFSymbols.gear,
                    color: controller.boxOpen &&
                            controller.selection ==
                                ControlsBoxSelection.settings
                        ? Colors.black
                        : Colors.grey),
              ),
              onTap: onSettingsTap,
            )
          ],
        ),
      ),
    );
  }
}
