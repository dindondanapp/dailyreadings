import 'package:dailyreadings/ControlsBarWidget.dart';
import 'package:dailyreadings/ReadingsRepository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ReadingsWidget.dart';
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
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ReadingsRepository repository = ReadingsRepository(
      ReadingsDataIdentifier(date: DateTime.now(), rite: Rite.roman));
  ScrollController _controller = ScrollController();
  final _buttonsOpacity = ValueNotifier<num>(1);

  @override
  void initState() {
    _controller.addListener(() {
      _buttonsOpacity.value =
          (1 - _controller.offset / 30).sat(lower: 0, upper: 1);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
    ));
    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            ListView(
              controller: _controller,
              physics: ClampingScrollPhysics(),
              padding: EdgeInsets.only(
                left: 10,
                right: 10,
                bottom: MediaQuery.of(context).padding.bottom,
                top: MediaQuery.of(context).padding.top + 20,
              ),
              children: [
                StreamBuilder<ReadingsData>(
                  stream: repository.readingsStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError || snapshot.data == null) {
                      print(snapshot.error);
                      return Text('Something went wrong');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text("Loading");
                    }

                    return ReadingsWidget(data: snapshot.data!);
                  },
                ),
                SizedBox(
                  height: MediaQuery.of(context).padding.bottom,
                ),
              ],
            ),
            IgnorePointer(
              child: Container(
                height: MediaQuery.of(context).padding.top + 30,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment(
                          0,
                          (MediaQuery.of(context).padding.top - 10) /
                                  (MediaQuery.of(context).padding.top + 30) *
                                  2 -
                              1),
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context).scaffoldBackgroundColor,
                        Theme.of(context).scaffoldBackgroundColor.withAlpha(0),
                      ]),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Container()),
                  Container(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 10),
                    child: ValueListenableBuilder(
                      valueListenable: _buttonsOpacity,
                      builder: (BuildContext context, num opacity, _) =>
                          Opacity(
                        child: StreamBuilder<ReadingsData>(
                          stream: repository.readingsStream,
                          builder: (context, snapshot) => ControlsBarWidget(
                              date: snapshot.data != null
                                  ? snapshot.data!.date
                                  : null),
                        ),
                        opacity: opacity.toDouble(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
