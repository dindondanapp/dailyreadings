import 'package:dailyreadings/calendar.dart';
import 'package:dailyreadings/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'controls_bar.dart';
import 'controls_box.dart';
import 'readings_display.dart';
import 'readings_repository.dart';
import 'utils.dart';

/// Main widget, that contains all the dynamic content of the app
class Home extends StatefulWidget {
  // TODO: Move somewhere else
  static final dinDonDanBlue = Color(0xFF6E95CB);
  final ThemeData lightTheme = ThemeData(
    primarySwatch: dinDonDanBlue.toMaterialColor(),
  );

  final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: dinDonDanBlue.toMaterialColor(),
  );

  Home({Key? key}) : super(key: key);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // A repository for the settings stored in local preferences
  final SettingsRepository settings = SettingsRepository();

  // A repository to access a remote reading. Will be initialized in initState.
  ReadingsRepository? repository;

  // Controller to handle and manage the scrollview state
  ScrollController scrollController = ScrollController();

  // TODO: move in a dedicated controller
  num _controlsBarOpacity = 1;

  final CalendarController calendarController =
      CalendarController(day: Day.now());

  ControlsState __controlsState = ControlsState(
    boxOpen: false,
    selection: ControlsBoxSelection.calendar,
  );

  ControlsState get _controlsState => __controlsState;

  set _controlsState(ControlsState value) {
    scrollController.animateTo(
      0,
      duration: Duration(seconds: 1),
      curve: Curves.easeOut,
    );

    __controlsState = value;
  }

  @override
  void initState() {
    repository = repository = ReadingsRepository(
      ReadingsDataIdentifier(
        day: Day.now(),
        rite: settings.rite,
      ),
    );

    // Change controls opacity to only show them when the page is scrolled up
    scrollController.addListener(() {
      final offsetStart = 30;
      final offsetEnd = 40;

      if (scrollController.offset < offsetStart) {
        setState(() {
          _controlsBarOpacity = 1;
        });
      }

      if (scrollController.offset > offsetEnd) {
        setState(() {
          _controlsBarOpacity = 0;
        });
      }
    });

    settings.addListener(() {
      if (repository == null || settings.rite != repository!.id.rite) {
        setState(() {
          repository = ReadingsRepository(ReadingsDataIdentifier(
              day: calendarController.day, rite: settings.rite));
        });
      }
    });

    calendarController.addListener(() {
      setState(() {
        repository = ReadingsRepository(ReadingsDataIdentifier(
            day: calendarController.day, rite: settings.rite));
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
    ));
    return ValueListenableBuilder<SettingsRepositoryValue>(
      valueListenable: settings,
      builder: (context, value, child) {
        final Brightness brightness = settings.theme == ThemeSetting.system
            ? MediaQuery.of(context).platformBrightness
            : settings.theme == ThemeSetting.dark
                ? Brightness.dark
                : Brightness.light;

        return Theme(
          data: brightness == Brightness.dark
              ? widget.darkTheme
              : widget.lightTheme,
          child: Scaffold(
            body: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ControlsBox(
                      calendarController: calendarController,
                      state: _controlsState,
                      settingsRepository: settings,
                      onChangeDay: (day) {
                        calendarController.day = day;
                      },
                    ),
                    DefaultTextStyle(
                      style: TextStyle(
                          fontSize: settings.fontSize.toDouble(),
                          color: Colors.black),
                      child: _buildReader(),
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
          ),
        );
      },
    );
  }

  Widget _buildReader() {
    assert(repository != null);

    return Expanded(
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              if (_controlsState.boxOpen) {
                setState(() {
                  _controlsState = _controlsState.rebuildWith(boxOpen: false);
                });
              }
            },
            child: ListView(
              controller: scrollController,
              physics: !_controlsState.boxOpen
                  ? ClampingScrollPhysics()
                  : NeverScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                left: 10,
                right: 10,
                bottom: MediaQuery.of(context).padding.bottom,
                top: MediaQuery.of(context).padding.top + 20,
              ),
              children: [
                StreamBuilder<ReadingsSnapshot>(
                  stream: repository!.readingsStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError ||
                        snapshot.data == null ||
                        snapshot.data!.badFormat) {
                      print(snapshot.error);
                      return Text(
                          'Something went wrong'); // TODO: Handle appropriately
                    }

                    return AnimatedOpacity(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      opacity:
                          snapshot.connectionState == ConnectionState.waiting
                              ? 0.5
                              : 1,
                      child: snapshot.data!.exists
                          ? ReadingsDisplay(data: snapshot.data!.data!)
                          : Text(
                              "Le letture per questo giorno non sono disponibili."),
                    );
                  },
                ),
                SizedBox(
                  height: MediaQuery.of(context).padding.bottom,
                ),
              ],
            ),
          ),
          ...!_controlsState.boxOpen ? [StatusBarBlendCover()] : [],
        ],
      ),
    );
  }

  Widget _buildControlsBar() {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10),
      child: AnimatedOpacity(
        opacity: (!_controlsState.boxOpen ? _controlsBarOpacity.toDouble() : 1),
        duration: Duration(milliseconds: 200),
        child: ControlsBar(
          date: calendarController.day,
          calendarTapCallback: () => setState(() {
            if (_controlsState.selection == ControlsBoxSelection.calendar &&
                _controlsState.boxOpen) {
              _controlsState = _controlsState.rebuildWith(boxOpen: false);
            } else {
              _controlsState = _controlsState.rebuildWith(
                  boxOpen: true, selection: ControlsBoxSelection.calendar);
            }
          }),
          settingsTapCallback: () => setState(() {
            if (_controlsState.selection == ControlsBoxSelection.settings &&
                _controlsState.boxOpen) {
              _controlsState = _controlsState.rebuildWith(boxOpen: false);
            } else {
              _controlsState = _controlsState.rebuildWith(
                  boxOpen: true, selection: ControlsBoxSelection.settings);
            }
          }),
          state: _controlsState,
        ),
      ),
    );
  }
}

/// Just a simple widget that creates a soft gradient between the status bar and the scrollable content
class StatusBarBlendCover extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Status bar height
    final paddingTop = MediaQuery.of(context).padding.top;

    // How much it should extend below the status bar
    final offset = 20;

    // Where the gradient should start with respect to the end of the status bar
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
