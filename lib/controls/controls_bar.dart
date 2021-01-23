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
      builder: (context, value, widget) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildButton(
            context: context,
            icon: PlatformIcons.calendar,
            label:
                (date ?? DateTime.now()).toLocaleDateString(withWeekday: true),
            selected: controller.selection == ControlsBoxSelection.calendar,
            onTap: onCalendarTap,
          ),
          _buildButton(
            context: context,
            icon: PlatformIcons.settings,
            onTap: onSettingsTap,
            selected: controller.selection == ControlsBoxSelection.settings,
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
      {@required BuildContext context,
      IconData icon,
      String label,
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
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    icon != null ? Icon(icon) : Container(),
                    icon != null && label != null
                        ? SizedBox(width: 10)
                        : Container(),
                    label != null
                        ? Text(
                            label,
                            style: TextStyle(
                              fontSize: 13,
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
