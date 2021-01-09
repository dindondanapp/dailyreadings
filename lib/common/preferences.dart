import 'package:dailyreadings/common/enums.dart';
import 'package:flutter/material.dart';

import 'extensions.dart';
import 'local_preferences.dart';

/// Provides specific local preferences for the VitaminaV app to descending
/// widgets
class Preferences extends LocalPreferences {
  final double defaultFontSize;
  final ThemeMode defaultTheme;
  Preferences({
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

  static Preferences of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Preferences>();
  }

  /// Global font size for the reader screen
  static const minFontSize = 10.0;
  static const maxFontSize = 24.0;
  double get fontSize =>
      (get('font_size') as num).sat(lower: minFontSize, upper: maxFontSize);
  set fontSize(double value) =>
      set('font_size', value.sat(lower: minFontSize, upper: maxFontSize));

  /// Rite
  Rite get rite => get('rite') == "roman" ? Rite.roman : Rite.ambrosian;
  set rite(Rite rite) => set('rite', rite.enumSerialize());

  /// Theme
  ThemeMode get theme {
    final String themeString = get('theme');

    return ThemeMode.values.firstWhere(
      (e) => e.enumSerialize() == themeString,
      orElse: () => defaultTheme,
    );
  }

  set theme(ThemeMode value) => set('theme', value.enumSerialize());

  /// First open
  bool get firstTime => get('first_time');
  set firstTime(bool value) => set('first_time', value);
}

enum ThemeSetting { light, dark, system }