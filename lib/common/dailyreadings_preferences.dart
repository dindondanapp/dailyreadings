import 'package:dailyreadings/common/enums.dart';
import 'package:flutter/material.dart';

import 'extensions.dart';
import 'local_preferences.dart';

/// Provides specific local preferences for the VitaminaV app to descending
/// widgets
class DailyReadingsPreferences extends LocalPreferences {
  final double defaultFontSize;
  final ThemeSetting defaultTheme;
  DailyReadingsPreferences({
    @required this.defaultTheme,
    @required this.defaultFontSize,
    @required Widget child,
  }) : super(
          defaultPrefs: {
            'font_size': defaultFontSize,
            'theme': defaultTheme.enumSerialize(),
            'first_time': false,
          },
          child: child,
        );

  static DailyReadingsPreferences of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<DailyReadingsPreferences>();
  }

  /// Global font size for the reader screen
  double get fontSize => get('font_size');
  set fontSize(double value) => set('font_size', value);

  /// Rite
  Rite get rite => get('rite') == "roman" ? Rite.roman : Rite.ambrosian;
  set rite(Rite rite) => set('rite', rite.enumSerialize());

  /// Theme
  ThemeSetting get theme {
    final String themeString = get('theme');

    return ThemeSetting.values.firstWhere(
      (e) => e.enumSerialize() == themeString,
      orElse: () => defaultTheme,
    );
  }

  set theme(ThemeSetting value) => set('theme', value.enumSerialize());

  /// First open
  bool get firstTime => get('first_time');
  set firstTime(bool value) => set('first_time', value);
}

enum ThemeSetting { light, dark, system }
