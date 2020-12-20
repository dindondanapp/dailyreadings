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
  num sat({num lower, num upper}) {
    return min(upper ?? double.infinity, max(lower ?? -double.infinity, this));
  }
}

extension LocaleString on DateTime {
  bool isSameYear(DateTime compare) {
    return this.toLocal().year == compare.year;
  }

  bool isSameMonth(DateTime compare) {
    return isSameYear(compare) && this.toLocal().month == compare.month;
  }

  bool isSameDay(DateTime compare) {
    return isSameMonth(compare) && this.toLocal().day == compare.day;
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
      return '${this.day} ${localeMonths[this.month - 1]} ${this.year}';
    } else {
      return '${this.day} ${localeMonths[this.month - 1]}';
    }
  }

  String toLocaleWeekday() => localeWeekdays[this.weekday - 1];

  String toLocaleMonthString() {
    final today = DateTime.now();
    if (this.isSameYear(today)) {
      return localeMonths[this.month - 1].toString();
    } else {
      return '${localeMonths[this.month - 1]} ${this.year}';
    }
  }
}

class Year extends DateTime {
  Year(int year) : super(year);

  Year.fromDateTime(DateTime dateTime) : super(dateTime.year);

  Year.now() : super(DateTime.now().year);

  @override
  Year add(Duration duration) {
    final updatedDateTime = super.add(duration);
    return Year(updatedDateTime.year);
  }
}

class Month extends DateTime {
  Month(int year, int month) : super(year, month);

  Month.fromDateTime(DateTime dateTime) : super(dateTime.year, dateTime.month);

  Month.now() : super(DateTime.now().year, DateTime.now().month);

  @override
  Month add(Duration duration) {
    final updatedDateTime = super.add(duration);
    return Month(updatedDateTime.year, updatedDateTime.month);
  }
}

class Day extends DateTime {
  Day(int year, int month, int day) : super(year, month, day);

  Day.fromDateTime(DateTime dateTime)
      : super(dateTime.year, dateTime.month, dateTime.day);
  Day.now()
      : super(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  @override
  Day add(Duration duration) {
    final updatedDateTime = super.add(duration);
    return Day(
      updatedDateTime.year,
      updatedDateTime.month,
      updatedDateTime.day,
    );
  }
}

extension EnumSerialization on Object {
  String enumSerialize() => this.toString().split('.').last;
}
