import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'controls_bar.dart';
import 'readings_display.dart';
import 'readings_repository.dart';
import 'utils.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final ReadingsRepository repository = ReadingsRepository(
      ReadingsDataIdentifier(date: DateTime.now(), rite: Rite.roman));
  ScrollController _controller = ScrollController();
  final _controlsOpacity = ValueNotifier<num>(1);

  @override
  void initState() {
    // Change controls opacity to only show them when the page is scrolled up
    _controller.addListener(() {
      final offsetStart = 30;
      final offsetEnd = 40;
      _controlsOpacity.value =
          (1 - (_controller.offset - offsetStart) / (offsetEnd - offsetStart))
              .sat(lower: 0, upper: 1);
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

                    return ReadingsDisplay(data: snapshot.data!);
                  },
                ),
                SizedBox(
                  height: MediaQuery.of(context).padding.bottom,
                ),
              ],
            ),
            _buildStatusbarBlendCover(context),
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
                      valueListenable: _controlsOpacity,
                      builder: (BuildContext context, num opacity, _) =>
                          Opacity(
                        child: StreamBuilder<ReadingsData>(
                          stream: repository.readingsStream,
                          builder: (context, snapshot) => ControlsBar(
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

  Widget _buildStatusbarBlendCover(BuildContext context) {
    // Statusbar height
    final paddingTop = MediaQuery.of(context).padding.top;

    // How much it should extend below the statusbar
    final offset = 20;

    // Where the gradient should start with respect to the end of the statusbar
    final gradientStartOffset = -10;

    return IgnorePointer(
      // No gesture interaction
      child: Container(
        height: paddingTop + offset,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(
                0,
                (paddingTop + gradientStartOffset) / (paddingTop + offset) * 2 -
                    1),
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).scaffoldBackgroundColor.withAlpha(0),
            ],
          ),
        ),
      ),
    );
  }
}
