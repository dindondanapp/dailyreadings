import 'package:dailyreadings/common/configuration.dart';
import 'package:dailyreadings/common/platform_icons.dart';
import 'package:flutter/material.dart';

import '../common/extensions.dart';
import 'calendar.dart';
import 'controls_bar.dart';
import 'controls_box_controller.dart';
import 'settings.dart';

class ControlsBox extends StatelessWidget {
  final ControlsBoxController controller;
  final void Function() onCalendarTap;
  final void Function() onSettingsTap;
  final void Function() onNextDayTap;
  final void Function() onPreviousDayTap;
  final void Function() showInfo;
  final double size;
  final DayInterval availableInterval;

  static const _appBarSize = 54.0;

  const ControlsBox({
    Key key,
    @required this.controller,
    @required this.size,
    @required this.onCalendarTap,
    @required this.onSettingsTap,
    @required this.onNextDayTap,
    @required this.onPreviousDayTap,
    @required this.showInfo,
    this.availableInterval = const DayInterval.none(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).brightness == Brightness.light
        ? Colors.grey[700]
        : Colors.grey[200];
    final backgroundColor = Theme.of(context).brightness == Brightness.light
        ? Colors.grey[200]
        : Colors.grey[800];
    final buttonColor = Theme.of(context).brightness == Brightness.light
        ? Colors.grey[300]
        : Colors.grey[600];
    final selectionColor = Theme.of(context).canvasColor;
    return Theme(
      data: Theme.of(context).copyWith(
          primaryColor: selectionColor,
          backgroundColor: backgroundColor,
          buttonColor: buttonColor),
      child: DefaultTextStyle(
        style: TextStyle(color: textColor),
        child: ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, value, widget) {
              final isOpen = controller.boxOpen == BoxOpenState.open ||
                  controller.boxOpen == BoxOpenState.opening;
              final color = isOpen
                  ? Theme.of(context).backgroundColor
                  : Theme.of(context).backgroundColor.withAlpha(0);
              final opacity = isOpen ? 1.0 : 0.0;
              return Column(
                children: [
                  _buildAppBar(context),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      curve: Curves.ease,
                      duration: Configuration.defaultTransitionDuration,
                      color: color,
                      child: Column(
                        children: [
                          AnimatedOpacity(
                            opacity: opacity,
                            duration: Configuration.defaultTransitionDuration,
                            curve: Curves.ease,
                            child: SizedBox(
                              height: size - _appBarSize,
                              child: IgnorePointer(
                                ignoring: !isOpen,
                                child: _buildChildForSelection(),
                              ),
                            ),
                          ),
                          ControlsBar(
                            date: controller.day,
                            controller: controller,
                            onCalendarTap: onCalendarTap,
                            onSettingsTap: onSettingsTap,
                            onNextDayTap: onNextDayTap,
                            onPreviousDayTap: onPreviousDayTap,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(PlatformIcons.info),
                onPressed: showInfo,
                color: Theme.of(context).accentColor,
              ),
              Text(
                "Letture del giorno",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
      height: _appBarSize,
    );
  }

  Widget _buildChildForSelection() {
    if (controller.selection == ControlsBoxSelection.calendar) {
      return Calendar(
        selectedDay: controller.day,
        availableInterval: availableInterval,
        onSelect: (Day day) => controller.day = day,
      );
    } else if (controller.selection == ControlsBoxSelection.settings) {
      return Settings();
    } else {
      return Container();
    }
  }
}
