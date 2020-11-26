import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'controls_bar.dart';
import 'controls_box.dart';
import 'readings_display.dart';
import 'readings_repository.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final ReadingsRepository repository = ReadingsRepository(
      ReadingsDataIdentifier(date: DateTime.now(), rite: Rite.roman));
  ScrollController _controller = ScrollController();
  num _controlsBarOpacity = 1;

  ControlsBarSelection __controlsBarSelection = ControlsBarSelection.none;
  ControlsBarSelection get _controlsBarSelection => __controlsBarSelection;

  set _controlsBarSelection(ControlsBarSelection value) {
    _controller.animateTo(
      0,
      duration: Duration(seconds: 1),
      curve: Curves.easeOut,
    );

    __controlsBarSelection = value;
  }

  num get _controlsBoxOpacity =>
      _controlsBarSelection == ControlsBarSelection.none ? 0 : 1;
  num get _controlsBoxHeight =>
      _controlsBarSelection == ControlsBarSelection.none ? 0 : 300;

  @override
  void initState() {
    // Change controls opacity to only show them when the page is scrolled up
    _controller.addListener(() {
      final offsetStart = 30;
      final offsetEnd = 40;

      if (_controller.offset < offsetStart) {
        setState(() {
          _controlsBarOpacity = 1;
        });
      }

      if (_controller.offset > offsetEnd) {
        setState(() {
          _controlsBarOpacity = 0;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
    ));
    return Scaffold(
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildControlsBox(),
              Expanded(
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (_controlsBarSelection !=
                            ControlsBarSelection.none) {
                          setState(() {
                            _controlsBarSelection = ControlsBarSelection.none;
                          });
                        }
                      },
                      child: ListView(
                        controller: _controller,
                        physics:
                            _controlsBarSelection == ControlsBarSelection.none
                                ? ClampingScrollPhysics()
                                : NeverScrollableScrollPhysics(),
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

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
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
                    ),
                    ..._controlsBarSelection == ControlsBarSelection.none
                        ? [_buildStatusbarBlendCover(context)]
                        : [],
                  ],
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Container()),
                _buildControlsBar(),
              ],
            ),
          ),
        ],
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

  Widget _buildControlsBar() {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10),
      child: AnimatedOpacity(
        opacity: (_controlsBarSelection == ControlsBarSelection.none
            ? _controlsBarOpacity.toDouble()
            : 1),
        duration: Duration(milliseconds: 200),
        child: StreamBuilder<ReadingsData>(
          stream: repository.readingsStream,
          builder: (context, snapshot) => ControlsBar(
            date: snapshot.data != null ? snapshot.data!.date : null,
            calendarTapCallback: () => setState(() {
              _controlsBarSelection =
                  _controlsBarSelection == ControlsBarSelection.calendar
                      ? ControlsBarSelection.none
                      : ControlsBarSelection.calendar;
            }),
            settingsTapCallback: () => setState(() {
              _controlsBarSelection =
                  _controlsBarSelection == ControlsBarSelection.settings
                      ? ControlsBarSelection.none
                      : ControlsBarSelection.settings;
            }),
            selection: _controlsBarSelection,
          ),
        ),
      ),
    );
  }

  Widget _buildControlsBox() {
    return AnimatedOpacity(
      duration: Duration(seconds: 1),
      opacity: _controlsBoxOpacity.toDouble(),
      child: AnimatedContainer(
        duration: Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
        height: _controlsBoxHeight.toDouble(),
        child: Material(
          color: Colors.grey[300],
          elevation: 2,
          child: ControlsBox(),
        ),
      ),
    );
  }
}
