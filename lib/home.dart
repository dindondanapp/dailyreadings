import 'package:dailyreadings/calendar_control.dart';
import 'package:dailyreadings/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'controls_bar.dart';
import 'controls_box.dart';
import 'readings_display.dart';
import 'readings_repository.dart';
import 'utils.dart';

class Home extends StatefulWidget {
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
  final SettingsRepository settings = SettingsRepository();
  ReadingsRepository? repository;

  ScrollController scrollController = ScrollController();

  num _controlsBarOpacity = 1;

  final CalendarController calendarController =
      CalendarController(day: Day.now());

  ControlsBarSelection __controlsBarSelection = ControlsBarSelection.none;
  ControlsBarSelection get _controlsBarSelection => __controlsBarSelection;

  set _controlsBarSelection(ControlsBarSelection value) {
    scrollController.animateTo(
      0,
      duration: Duration(seconds: 1),
      curve: Curves.easeOut,
    );

    __controlsBarSelection = value;
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
          child: DefaultTextStyle(
            style: TextStyle(fontSize: settings.fontSize.toDouble()),
            child: Scaffold(
              body: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ControlsBox(
                        calendarController: calendarController,
                        selection: _controlsBarSelection,
                        settingsRepository: settings,
                        onChangeDay: (day) {
                          calendarController.day = day;
                        },
                      ),
                      _buildReader(),
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
          ),
        );
      },
    );
  }

  Widget _buildReader() {
    return Expanded(
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              if (_controlsBarSelection != ControlsBarSelection.none) {
                setState(() {
                  _controlsBarSelection = ControlsBarSelection.none;
                });
              }
            },
            child: ListView(
              controller: scrollController,
              physics: _controlsBarSelection == ControlsBarSelection.none
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
                  stream: repository!.readingsStream, // TODO: Better ideas?
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
          ),
          ..._controlsBarSelection == ControlsBarSelection.none
              ? [StatusBarBlendCover()]
              : [],
        ],
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
          stream: repository!.readingsStream,
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
}

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
