import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/entities.dart';
import 'extensions.dart';
import 'local_preferences.dart';

/// Provides specific local preferences for the VitaminaV app to descending
/// widgets
class Preferences extends LocalPreferences {
  final double defaultFontSize;
  final ThemeMode defaultTheme;
  final bool defaultFullscreen;
  Preferences({
    @required this.defaultTheme,
    @required this.defaultFontSize,
    @required this.defaultFullscreen,
    SharedPreferences sharedPreferencesInstance,
    @required Widget child,
  }) : super(
          defaultPrefs: {
            'font_size': defaultFontSize,
            'theme': defaultTheme.enumSerialize(),
            'fullscreen': defaultFullscreen,
            'first_time': true,
          },
          child: child,
          sharedPreferencesInstance: sharedPreferencesInstance,
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

  /// Full screen
  bool get fullscreen => get('fullscreen');
  set fullscreen(bool value) => set('fullscreen', value);

  /// First open
  bool get firstTime => get('first_time');
  set firstTime(bool value) => set('first_time', value);
}

enum ThemeSetting { light, dark, system }
