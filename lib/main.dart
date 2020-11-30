import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'home.dart';
import 'utils.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static final dinDonDanBlue = Color(0xFF6E95CB);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Letture del giorno',
      theme: ThemeData(
        primarySwatch: dinDonDanBlue.toMaterialColor(),
      ),
      darkTheme:
          ThemeData(brightness: Brightness.dark, primarySwatch: Colors.orange),
      home: Home(),
      debugShowCheckedModeBanner: false,
    );
  }
}
