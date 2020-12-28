import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'common/dailyreadings_preferences.dart';
import 'home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DailyReadingsPreferences(
      defaultFontSize: 14.0,
      defaultTheme: ThemeSetting.system,
      child: MaterialApp(
        title: 'Letture del giorno',
        debugShowCheckedModeBanner: false,
        home: Home(),
      ),
    );
  }
}
