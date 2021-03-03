import 'package:dailyreadings/common/configuration.dart';
import 'package:dailyreadings/common/platform_icons.dart';
import 'package:flutter/material.dart';

import '../common/extensions.dart';
import 'controls_box_controller.dart';

class ControlsBar extends StatelessWidget {
  final DateTime date;
  final ControlsBoxController controller;
  final void Function() onCalendarTap;
  final void Function() onSettingsTap;
  final void Function() onNextDayTap;
  final void Function() onPreviousDayTap;
  const ControlsBar(
      {Key key,
      @required this.date,
      @required this.controller,
      this.onCalendarTap,
      this.onSettingsTap,
      this.onNextDayTap,
      this.onPreviousDayTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, widget) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildButton(
                context: context,
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios),
                      onPressed: onPreviousDayTap,
                      iconSize: 20,
                      constraints: BoxConstraints(maxWidth: 44, maxHeight: 44),
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(12),
                      color: Theme.of(context).accentColor,
                    ),
                    Icon(PlatformIcons.calendar),
                    SizedBox(width: 10),
                    Text(
                      (date ?? DateTime.now())
                          .toLocaleDateString(withWeekday: true),
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_forward_ios),
                      onPressed: onNextDayTap,
                      iconSize: 20,
                      constraints: BoxConstraints(maxWidth: 44, maxHeight: 44),
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(12),
                      color: Theme.of(context).accentColor,
                    ),
                  ],
                ),
                selected: controller.selection == ControlsBoxSelection.calendar,
                onTap: onCalendarTap,
              ),
            ],
          ),
          _buildButton(
            context: context,
            child: Container(
              child: Icon(PlatformIcons.settings),
              padding: EdgeInsets.all(10),
            ),
            onTap: onSettingsTap,
            selected: controller.selection == ControlsBoxSelection.settings,
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
      {@required BuildContext context,
      Widget child,
      @required void Function() onTap,
      bool selected = false}) {
    final selectedBackground = Theme.of(context).canvasColor;
    final background =
        selected ? selectedBackground : selectedBackground.withAlpha(0);
    return Container(
      margin: EdgeInsets.all(5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: AnimatedContainer(
          curve: Curves.easeInOut,
          duration: Configuration.quickTransitionDuration,
          color: background,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: onTap,
              child: Container(
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
