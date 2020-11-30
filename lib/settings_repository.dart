import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'readings_repository.dart';
import 'utils.dart';

/// A class that handles transparently the shared preferences reading and writing
class SettingsRepository extends ValueNotifier<SettingsRepositoryValue> {
  Future<SharedPreferences> get _prefsFuture => SharedPreferences.getInstance();

  static final defaultValue = SettingsRepositoryValue(
    fontSize: 14,
    rite: Rite.roman,
    theme: ThemeSetting.system,
    firstTime: true,
    loaded: false,
  );

  // Setters and getters for quick access to value properties
  num get fontSize => value.fontSize;
  Rite get rite => value.rite;
  ThemeSetting get theme => value.theme;
  bool get firstTime => value.firstTime;
  bool get loaded => loaded;

  set fontSize(num fontSize) => value = value.rebuildWith(fontSize: fontSize);
  set rite(Rite rite) => value = value.rebuildWith(rite: rite);
  set theme(ThemeSetting theme) => value = value.rebuildWith(theme: theme);
  set firstTime(bool firstTime) =>
      value = value.rebuildWith(firstTime: firstTime);

  /// Creates a new [SettingsRepository] and loads its value from local storage
  SettingsRepository() : super(defaultValue) {
    _prefsFuture.then((prefs) {
      // Some functions to get preference values in an optional way
      bool? _tryGetBool(key) {
        try {
          return prefs.getBool(key);
        } catch (_) {}
      }

      double? _tryGetDouble(key) {
        try {
          return prefs.getDouble(key);
        } catch (_) {}
      }

      String? _tryGetString(key) {
        try {
          return prefs.getString(key);
        } catch (_) {}
      }

      // Get stored settings and populate the value, with defaults if needed
      final String? riteString = _tryGetString('rite');
      final String? themeString = _tryGetString('theme');

      this.value = SettingsRepositoryValue(
        fontSize: _tryGetDouble('font_size') ?? defaultValue.fontSize,
        rite: Rite.values.firstWhere(
          (e) => e.enumSerialize() == riteString,
          orElse: () => defaultValue.rite,
        ),
        theme: ThemeSetting.values.firstWhere(
          (e) => e.enumSerialize() == themeString,
          orElse: () => defaultValue.theme,
        ),
        firstTime: _tryGetBool('first_time') ?? defaultValue.firstTime,
        loaded: true,
      );
    });
  }

  // Override the value setter to provide transparent writing of the preferences
  @override
  set value(SettingsRepositoryValue value) {
    super.value = value;

    // Update the preferences
    _prefsFuture.then((prefs) {
      prefs.setDouble('font_size', value.fontSize.toDouble());
      prefs.setString('rite', value.rite.enumSerialize());
      prefs.setString('theme', value.theme.enumSerialize());
      prefs.setBool('firstTime', value.firstTime);
    });
  }
}

class SettingsRepositoryValue {
  final num fontSize;
  final Rite rite;
  final ThemeSetting theme;
  final bool loaded;
  final bool firstTime;

  SettingsRepositoryValue({
    required this.fontSize,
    required this.rite,
    required this.theme,
    required this.firstTime,
    required this.loaded,
  });

  SettingsRepositoryValue rebuildWith({
    num? fontSize,
    Rite? rite,
    ThemeSetting? theme,
    bool? firstTime,
    bool? loaded,
  }) =>
      SettingsRepositoryValue(
        fontSize: fontSize ?? this.fontSize,
        rite: rite ?? this.rite,
        theme: theme ?? this.theme,
        firstTime: firstTime ?? this.firstTime,
        loaded: loaded ?? this.loaded,
      );
}

enum ThemeSetting { light, dark, system }
