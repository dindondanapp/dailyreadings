import 'package:flutter/material.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';

import '../common/dailyreadings_preferences.dart';
import '../common/enums.dart';

class Settings extends StatelessWidget {
  const Settings({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(10),
        child: SizedBox(
          width: 260,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              _buildSettingsRow(
                isFirst: true,
                context: context,
                label: 'Tema',
                child: RadioSelector<ThemeMode>(
                  selected: DailyReadingsPreferences.of(context).theme,
                  onSelect: (value) =>
                      DailyReadingsPreferences.of(context).theme = value,
                  valueIcons: {
                    ThemeMode.system: Icon(SFSymbols.gear),
                    ThemeMode.dark: Icon(SFSymbols.moon),
                    ThemeMode.light: Icon(SFSymbols.sun_max),
                  },
                ),
              ),
              _buildSettingsRow(
                context: context,
                label: 'Rito',
                child: RadioSelector<Rite>(
                  direction: Axis.vertical,
                  selected: DailyReadingsPreferences.of(context).rite,
                  onSelect: (value) =>
                      DailyReadingsPreferences.of(context).rite = value,
                  valueIcons: {
                    Rite.roman: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('Romano',
                          style: DefaultTextStyle.of(context).style),
                    ),
                    Rite.ambrosian: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('Ambrosiano',
                          style: DefaultTextStyle.of(context).style),
                    ),
                  },
                ),
              ),
              _buildSettingsRow(
                context: context,
                label: 'Testo',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildRoundedButton(
                        context: context,
                        child: Icon(SFSymbols.minus),
                        onTap: () =>
                            DailyReadingsPreferences.of(context).fontSize -= 2),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        DailyReadingsPreferences.of(context)
                            .fontSize
                            .round()
                            .toString(),
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    _buildRoundedButton(
                        context: context,
                        child: Icon(SFSymbols.plus),
                        onTap: () =>
                            DailyReadingsPreferences.of(context).fontSize += 2),
                  ],
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
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            padding: EdgeInsets.only(left: 25),
            width: 80,
            child: Text(
              label,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
          Expanded(child: child),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              maxHeight: 50,
              minHeight: 50,
              minWidth: 50,
            ),
            child: Container(
              child: Center(
                child: DefaultTextStyle(
                  child: IconTheme(
                    child: child,
                    data: IconThemeData(
                        color: DefaultTextStyle.of(context).style.color),
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
