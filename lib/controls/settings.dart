import 'package:flutter/material.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';

import '../common/dailyreadings_preferences.dart';
import '../common/enums.dart';

class Settings extends StatelessWidget {
  const Settings({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OverflowBox(
      minWidth: 0.0,
      minHeight: 0.0,
      maxWidth: double.infinity,
      maxHeight: double.infinity,
      child: SizedBox(
        width: 300,
        child: Table(
          children: [
            TableRow(children: [
              Text('Tema'),
              RadioSelector<ThemeSetting>(
                selected: DailyReadingsPreferences.of(context).theme,
                onSelect: (value) =>
                    DailyReadingsPreferences.of(context).theme = value,
                valueIcons: {
                  ThemeSetting.system: Icon(SFSymbols.gear),
                  ThemeSetting.dark: Icon(SFSymbols.moon),
                  ThemeSetting.light: Icon(SFSymbols.sun_max),
                },
              ),
            ]),
            TableRow(children: [
              Text('Rito'),
              RadioSelector<Rite>(
                selected: DailyReadingsPreferences.of(context).rite,
                onSelect: (value) =>
                    DailyReadingsPreferences.of(context).rite = value,
                valueIcons: {
                  Rite.roman: Text('Romano'),
                  Rite.ambrosian: Text('Ambrosiano'),
                },
              ),
            ]),
            TableRow(children: [
              Text('Testo'),
              Row(
                children: [
                  IconButton(
                      icon: Icon(SFSymbols.minus),
                      onPressed: () =>
                          DailyReadingsPreferences.of(context).fontSize--),
                  Text(
                      DailyReadingsPreferences.of(context).fontSize.toString()),
                  IconButton(
                      icon: Icon(SFSymbols.plus),
                      onPressed: () =>
                          DailyReadingsPreferences.of(context).fontSize++),
                ],
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class RadioSelector<T> extends StatelessWidget {
  final void Function(T theme) onSelect;
  final T selected;

  final Map<T, Widget> valueIcons;

  const RadioSelector({
    Key key,
    @required this.onSelect,
    @required this.selected,
    @required this.valueIcons,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      children: valueIcons.values.toList(),
      isSelected: valueIcons.keys.map((e) => e == selected).toList(),
      onPressed: (index) => onSelect(valueIcons.keys.elementAt(index)),
    );
  }
}
