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
        width: 340,
        height: 240,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            _buildSettingsRow(
              context: context,
              label: 'Tema',
              child: RadioSelector<ThemeSetting>(
                selected: DailyReadingsPreferences.of(context).theme,
                onSelect: (value) =>
                    DailyReadingsPreferences.of(context).theme = value,
                valueIcons: {
                  ThemeSetting.system: Icon(SFSymbols.gear),
                  ThemeSetting.dark: Icon(SFSymbols.moon),
                  ThemeSetting.light: Icon(SFSymbols.sun_max),
                },
              ),
            ),
            _buildSettingsRow(
              context: context,
              label: 'Rito',
              child: RadioSelector<Rite>(
                selected: DailyReadingsPreferences.of(context).rite,
                onSelect: (value) =>
                    DailyReadingsPreferences.of(context).rite = value,
                valueIcons: {
                  Rite.roman: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('Romano'),
                  ),
                  Rite.ambrosian: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('Ambrosiano'),
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
                        color: Theme.of(context).primaryColor,
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
      ),
    );
  }

  Widget _buildSettingsRow(
      {@required BuildContext context, String label, Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Container(
        color: Theme.of(context).canvasColor,
        padding: EdgeInsets.zero,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              padding: EdgeInsets.only(left: 25),
              width: 80,
              child: Text(
                label.toUpperCase(),
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
              ),
            ),
            Expanded(child: child),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: this
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
          .toList(),
    );
  }
}

Widget _buildRoundedButton({
  @required BuildContext context,
  bool selected = false,
  @required void Function() onTap,
  @required Widget child,
}) {
  final textColor = selected ? Colors.white : Colors.grey[700];
  final backgroundColor =
      selected ? Theme.of(context).primaryColor : Colors.grey[300];
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
                    data: IconThemeData(color: textColor),
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
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
