import 'dart:math';

import 'package:dailyreadings/common/configuration.dart';
import 'package:dailyreadings/reader/readings_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../common/extensions.dart';
import '../common/platform_icons.dart';
import '../common/preferences.dart';
import '../controls/controls_box.dart';
import '../controls/controls_box_controller.dart';
import '../readings_repository.dart';
import 'first_time_tutorial.dart';
import 'home_scroll_physics.dart';
import 'statusbar_blend_cover.dart';

/// Main widget, that contains all the dynamic content of the app
class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final double _controlsBoxSize = 300;

  // A repository to access a remote reading. Will be initialized in initState.
  ReadingsRepository _repository;

  // Controller to handle and manage the scrollview state
  ScrollController _scrollController;

  // Controller to handle the controls box state
  ControlsBoxController _controlsState = ControlsBoxController();

  @override
  void initState() {
    _repository = ReadingsRepository();

    // Update repository when the control state changes, as the date may have
    // changed
    _controlsState.addListener(
      () => _repository.id = ReadingsDataIdentifier(
        day: _controlsState.day,
        rite: Preferences.of(context).rite,
      ),
    );

    super.initState();
  }

  @override
  void didChangeDependencies() {
    // Update status bar brightness and visibility
    if (Preferences.of(context).fullscreen) {
      SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    } else {
      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarBrightness: Theme.of(context).brightness),
      );
    }

    // Update scroll controller
    _scrollController = ScrollController(initialScrollOffset: _controlsBoxSize);

    // Change controls opacity to only show them when the page is scrolled up
    _scrollController.addListener(() {
      if (_scrollController.offset <= _controlsBoxSize * 0.25) {
        if (_controlsState.boxOpen != BoxOpenState.open) {
          _controlsState.boxOpen = BoxOpenState.open;
        }
      } else if (_scrollController.offset < _controlsBoxSize * 0.75) {
        if (_controlsState.boxOpen == BoxOpenState.open) {
          _controlsState.boxOpen = BoxOpenState.closing;
        } else if (_controlsState.boxOpen == BoxOpenState.closed) {
          _controlsState.boxOpen = BoxOpenState.opening;
        }
      } else {
        if (_controlsState.boxOpen != BoxOpenState.closed) {
          _controlsState.boxOpen = BoxOpenState.closed;
        }
      }
    });

    // Update repository, as the rite and day may have changed
    _repository.id = ReadingsDataIdentifier(
      day: _controlsState.day,
      rite: Preferences.of(context).rite,
    );

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ListView(
            physics: HomeScrollPhysics(bound: _controlsBoxSize + 15),
            controller: _scrollController,
            padding: EdgeInsets.only(
              left: max(MediaQuery.of(context).padding.left, 15),
              right: max(MediaQuery.of(context).padding.right, 15),
              bottom: MediaQuery.of(context).padding.bottom,
              top: MediaQuery.of(context).padding.top + 15,
            ),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: Configuration.maxReaderWidth,
                    minHeight: _controlsBoxSize +
                        MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.bottom -
                        MediaQuery.of(context).padding.top,
                  ),
                  child: Column(
                    children: [
                      _buildControlsBoxAndBar(),
                      DefaultTextStyle.merge(
                        style: TextStyle(
                          fontSize: Preferences.of(context).fontSize.toDouble(),
                        ),
                        child: StreamBuilder<ReadingsSnapshot>(
                          stream: _repository.readingsStream,
                          initialData:
                              ReadingsSnapshot.notDownloaded(_repository.id),
                          builder: (context, snapshot) {
                            return Container(
                              padding: EdgeInsets.all(15),
                              child: AnimatedOpacity(
                                duration:
                                    Configuration.defaultTransitionDuration,
                                curve: Curves.easeInOut,
                                opacity: snapshot.connectionState ==
                                        ConnectionState.waiting
                                    ? 0.5
                                    : 1,
                                child: Builder(builder: (context) {
                                  return _renderSnapshot(snapshot, context);
                                }),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Preferences.of(context).fullscreen
              ? Container()
              : StatusBarBlendCover(),
          IgnorePointer(
            ignoring: !Preferences.of(context).firstTime,
            child: AnimatedOpacity(
              opacity: Preferences.of(context).firstTime ? 1 : 0,
              curve: Curves.easeInOut,
              duration: Configuration.defaultTransitionDuration,
              child: FirstTimeTutorial(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsBoxAndBar() {
    return StreamBuilder<DayInterval>(
      stream: _repository.calendarIntervalStream,
      initialData: DayInterval.none(),
      builder: (context, snapshot) {
        return ControlsBox(
          controller: _controlsState,
          size: _controlsBoxSize,
          onCalendarTap: onCalendarTap,
          onSettingsTap: onSettingsTap,
          onNextDayTap: onNextDayTap,
          onPreviousDayTap: onPreviousDayTap,
          availableInterval: snapshot.data,
        );
      },
    );
  }

  Widget _renderSnapshot(
      AsyncSnapshot<ReadingsSnapshot> snapshot, BuildContext context) {
    if (snapshot.hasError ||
        snapshot.data == null ||
        snapshot.data.state == ReadingsSnapshotState.badFormat) {
      return _buildReadingsError();
    }
    if (snapshot.data.state == ReadingsSnapshotState.downloaded) {
      return ReadingsDisplay(
        data: snapshot.data.data,
        // The key ensures that the states of the
        // widgets that constitute the reader are
        // not preserved across different readings
        key: Key(snapshot.data.requestedId.serialize()),
      );
    }

    if (snapshot.data.state == ReadingsSnapshotState.waitingForDownload) {
      return FutureBuilder<Widget>(
          key: Key(snapshot.data.requestedId.serialize()),
          future: Future.delayed(
              Configuration.networkTimeout, () => _buildReadingsError()),
          initialData: _buildReadingsDownload(),
          builder: (context, snapshot) {
            return snapshot.data;
          });
    }

    return _buildReadingsNotAvailable(snapshot.data.requestedId);
  }

  Widget _buildReadingsNotAvailable(ReadingsDataIdentifier id) {
    final text =
        'Le letture per ${id.day.toLocaleDateString(withArticle: true)} non sono ${id.day.isAfter(Day.now()) ? "ancora" : "più"} disponibili. Seleziona un altro giorno.';
    return Center(
      child: Column(
        children: [
          SizedBox(height: 50),
          Icon(
            PlatformIcons.wait,
            size: 50,
            color: Colors.grey,
          ),
          SizedBox(height: 50),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 200),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingsError() {
    final text =
        'Non è stato possibile scaricare le letture del giorno. Controlla la connessione di rete.';
    return Center(
      child: Column(
        children: [
          SizedBox(height: 50),
          Icon(
            PlatformIcons.error,
            size: 50,
            color: Colors.grey,
          ),
          SizedBox(height: 50),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 210),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingsDownload() {
    final text = 'Download in corso…';
    return Center(
      child: Column(
        children: [
          SizedBox(height: 50),
          Icon(
            PlatformIcons.downloaad,
            size: 50,
            color: Colors.grey,
          ),
          SizedBox(height: 50),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 210),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  void onCalendarTap() {
    if (_controlsState.selection == ControlsBoxSelection.calendar &&
        _controlsState.boxOpen != BoxOpenState.closed) {
      _scrollController.animateTo(_controlsBoxSize,
          duration: Configuration.defaultTransitionDuration,
          curve: Curves.easeInOut);
    } else {
      _controlsState.selection = ControlsBoxSelection.calendar;
      _scrollController.animateTo(0,
          duration: Configuration.defaultTransitionDuration,
          curve: Curves.easeInOut);
    }
  }

  void onSettingsTap() {
    if (_controlsState.selection == ControlsBoxSelection.settings &&
        _controlsState.boxOpen != BoxOpenState.closed) {
      _scrollController.animateTo(_controlsBoxSize,
          duration: Configuration.defaultTransitionDuration,
          curve: Curves.easeInOut);
    } else {
      _controlsState.selection = ControlsBoxSelection.settings;
      _scrollController.animateTo(0,
          duration: Configuration.defaultTransitionDuration,
          curve: Curves.easeInOut);
    }
  }

  void onNextDayTap() {
    _controlsState.day = _controlsState.day.add(Duration(days: 1));
  }

  void onPreviousDayTap() {
    _controlsState.day = _controlsState.day.subtract(Duration(days: 1));
  }

  @override
  void dispose() {
    super.dispose();
    _controlsState.dispose();
    _repository.dispose();
  }
}
