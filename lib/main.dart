import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'home.dart';
import 'utils.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Letture del giorno',
      theme: ThemeData(
        primarySwatch: Color(0xFF6E95CB).toMaterialColor(),
      ),
      home: Home(),
      debugShowCheckedModeBanner: false,
    );
  }
}
