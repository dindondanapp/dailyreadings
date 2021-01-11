import 'package:dailyreadings/common/platform_icons.dart';
import 'package:flutter/material.dart';

import '../common/enums.dart';
import '../common/preferences.dart';

class Settings extends StatelessWidget {
  const Settings({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(10),
        child: SizedBox(
          width: 335,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              _buildSettingsRow(
                isFirst: true,
                context: context,
                label: 'Tema',
                child: RadioSelector<ThemeMode>(
                  selected: Preferences.of(context).theme,
                  onSelect: (value) => Preferences.of(context).theme = value,
                  valueIcons: {
                    ThemeMode.system: Icon(PlatformIcons.settings),
                    ThemeMode.dark: Icon(PlatformIcons.moon),
                    ThemeMode.light: Icon(PlatformIcons.sun),
                  },
                ),
              ),
              _buildSettingsRow(
                context: context,
                label: 'Barra\ndi stato',
                child: RadioSelector<bool>(
                  selected: Preferences.of(context).fullscreen,
                  onSelect: (value) =>
                      Preferences.of(context).fullscreen = value,
                  valueIcons: {
                    false: Container(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Text('Mostra',
                          style: DefaultTextStyle.of(context).style),
                    ),
                    true: Container(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Text('Nascondi',
                          style: DefaultTextStyle.of(context).style),
                    ),
                  },
                ),
              ),
              _buildSettingsRow(
                context: context,
                label: 'Testo',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildRoundedButton(
                        context: context,
                        child: Icon(PlatformIcons.minus),
                        onTap: () => Preferences.of(context).fontSize -= 2),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        Preferences.of(context).fontSize.round().toString(),
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    _buildRoundedButton(
                        context: context,
                        child: Icon(PlatformIcons.plus),
                        onTap: () => Preferences.of(context).fontSize += 2),
                  ],
                ),
              ),
              _buildSettingsRow(
                context: context,
                label: 'Rito',
                child: RadioSelector<Rite>(
                  direction: Axis.horizontal,
                  selected: Preferences.of(context).rite,
                  onSelect: (value) => Preferences.of(context).rite = value,
                  valueIcons: {
                    Rite.roman: Container(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Text('Romano',
                          style: DefaultTextStyle.of(context).style),
                    ),
                    Rite.ambrosian: Container(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Text('Ambrosiano',
                          style: DefaultTextStyle.of(context).style),
                    ),
                  },
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildSettingsRow(
      {@required BuildContext context,
      String label,
      Widget child,
      bool isFirst = false}) {
    return Container(
      //color: Theme.of(context).canvasColor,
      decoration: isFirst
          ? null
          : BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[400]))),
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 80,
            child: Text(
              label,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: child,
              scrollDirection: Axis.horizontal,
              reverse: true,
            ),
          ),
        ],
      ),
    );
  }
}

class RadioSelector<T> extends StatelessWidget {
  final void Function(T theme) onSelect;
  final T selected;
  final Axis direction;

  final Map<T, Widget> valueIcons;

  const RadioSelector({
    Key key,
    @required this.onSelect,
    @required this.selected,
    @required this.valueIcons,
    this.direction = Axis.horizontal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final children = this
        .valueIcons
        .map<T, Widget>((key, widget) {
          return MapEntry(
            key,
            _buildRoundedButton(
                context: context,
                onTap: () => onSelect(key),
                selected: selected == key,
                child: widget),
          );
        })
        .values
        .toList();
    return (direction == Axis.horizontal)
        ? Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: children,
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: children,
          );
  }
}

Widget _buildRoundedButton({
  @required BuildContext context,
  bool selected = false,
  @required void Function() onTap,
  @required Widget child,
}) {
  final backgroundColor =
      selected ? Theme.of(context).primaryColor : Theme.of(context).buttonColor;
  return Container(
    margin: EdgeInsets.all(5),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: Material(
        color: backgroundColor,
        child: InkWell(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 40,
              minHeight: 40,
              minWidth: 40,
            ),
            child: Container(
              child: Center(
                child: DefaultTextStyle(
                  child: IconTheme(
                    child: child,
                    data: IconThemeData(
                        color: DefaultTextStyle.of(context).style.color,
                        size: 20),
                  ),
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              padding: EdgeInsets.all(10),
            ),
          ),
          onTap: onTap,
        ),
      ),
    ),
  );
}
