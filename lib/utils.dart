import 'dart:math';

import 'package:flutter/material.dart';

extension ColorToMaterialColor on Color {
  /// Converts the color into a [MaterialColor], creating variations based on brightness
  MaterialColor toMaterialColor() {
    final base = HSLColor.fromColor(this);

    final lightnessMap = {
      050: 1.8,
      100: 1.6,
      200: 1.4,
      300: 1.2,
      400: 1.0,
      500: 0.9,
      600: 0.8,
      700: 0.7,
      800: 0.6,
      900: 0.5,
    };

    return MaterialColor(
        this.value,
        lightnessMap.map<int, Color>((key, multiplier) => MapEntry(
            key,
            base
                .withLightness((base.lightness * multiplier)
                    .sat(lower: 0, upper: 1)
                    .toDouble())
                .toColor())));
  }
}

extension Saturation on num {
  /// Saturates the number between given [lower] and [upper] bounds, if provided.
  num sat({num? lower, num? upper}) {
    return min(upper ?? double.infinity, max(lower ?? -double.infinity, this));
  }
}

extension LocaleString on DateTime {
  bool isSameDay(DateTime compare) {
    return (this.toLocal().year == compare.year &&
        this.toLocal().month == compare.month &&
        this.toLocal().day == compare.day);
  }

  static final localeMonths = [
    'gennaio',
    'febbraio',
    'marzo',
    'aprile',
    'maggio',
    'giugno',
    'luglio',
    'agosto',
    'settembre',
    'ottobre',
    'novembre',
    'dicembre'
  ];

  static final localeWeekdays = [
    'lunedì',
    'martedì',
    'mercoledì',
    'giovedì',
    'venerdì',
    'sabato',
    'domenica',
  ];

  String toLocaleDateString() {
    final today = DateTime.now();
    if (this.isSameDay(today)) {
      return 'oggi';
    }

    if (this.isSameDay(today.subtract(Duration(days: 1)))) {
      return 'ieri';
    }

    if (today.difference(this) > Duration(days: 90)) {
      return '${this.day} ${localeMonths[this.month]} ${this.year}';
    } else {
      return '${this.day} ${localeMonths[this.month]}';
    }
  }

  String toLocaleWeekday() => localeWeekdays[this.weekday];
}

extension EnumSerialization on Object {
  String enumSerialize() => this.toString().split('.').last;
}
