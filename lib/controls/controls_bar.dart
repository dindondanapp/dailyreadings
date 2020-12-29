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
      builder: (context, value, widget) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildButton(
            context: context,
            icon: SFSymbols.calendar,
            label: (date ?? DateTime.now()).toLocaleDateString(),
            selected: controller.boxOpen == BoxOpenState.open &&
                controller.selection == ControlsBoxSelection.calendar,
            onTap: onCalendarTap,
          ),
          _buildButton(
            context: context,
            icon: SFSymbols.gear,
            onTap: onSettingsTap,
            selected: controller.boxOpen == BoxOpenState.open &&
                controller.selection == ControlsBoxSelection.settings,
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
    final selectedBackground =
        Theme.of(context).primaryColor.toMaterialColor()[200];
    final background =
        selected ? selectedBackground : selectedBackground.withAlpha(0);
    return Container(
      margin: EdgeInsets.all(5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: AnimatedContainer(
          curve: Curves.easeInOut,
          duration: Duration(milliseconds: 200),
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
                              fontSize: 14,
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
