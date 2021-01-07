import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';

import 'common/dailyreadings_preferences.dart';
import 'common/extensions.dart';
import 'controls/controls_box.dart';
import 'reader/readings_display.dart';
import 'readings_repository.dart';

/// Main widget, that contains all the dynamic content of the app
class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static final double controlsBoxSize = 300;

  // A repository to access a remote reading. Will be initialized in initState.
  ReadingsRepository repository;

  // Controller to handle and manage the scrollview state
  ScrollController scrollController =
      ScrollController(initialScrollOffset: controlsBoxSize);
  ControlsBoxController _controlsState = ControlsBoxController();

  @override
  void initState() {
    super.initState();

    // Change controls opacity to only show them when the page is scrolled up
    scrollController.addListener(() {
      if (scrollController.offset <= controlsBoxSize * 0.25) {
        if (_controlsState.boxOpen != BoxOpenState.open) {
          _controlsState.boxOpen = BoxOpenState.open;
        }
      } else if (scrollController.offset < controlsBoxSize * 0.75) {
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

    // Listen to calendar selection
    _controlsState.addListener(() {
      if (_controlsState.day != repository.id.day) {
        setState(() {
          repository = ReadingsRepository(
            ReadingsDataIdentifier(
              day: _controlsState.day,
              rite: DailyReadingsPreferences.of(context).rite,
            ),
            DailyReadingsPreferences.of(context).rite,
          );
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    repository = ReadingsRepository(
      ReadingsDataIdentifier(
        day: _controlsState.day,
        rite: DailyReadingsPreferences.of(context).rite,
      ),
      DailyReadingsPreferences.of(context).rite,
    );

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
    ));
    return Scaffold(
      body: _buildReader(),
    );
  }

  Widget _buildReader() {
    assert(repository != null);

    return Stack(
      children: [
        ListView(
          physics: HomeScrollPhysics(controlsBoxSize: controlsBoxSize),
          controller: scrollController,
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
                  maxWidth: 400,
                  minHeight: controlsBoxSize +
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.bottom -
                      MediaQuery.of(context).padding.top,
                ),
                child: Column(
                  children: [
                    _buildControlsBoxAndBar(),
                    DefaultTextStyle.merge(
                      style: TextStyle(
                        fontSize: DailyReadingsPreferences.of(context)
                            .fontSize
                            .toDouble(),
                      ),
                      child: StreamBuilder<ReadingsSnapshot>(
                        stream: repository.readingsStream,
                        initialData:
                            ReadingsSnapshot.notDownloaded(repository.id),
                        builder: (context, snapshot) {
                          return Container(
                            padding: EdgeInsets.all(15),
                            child: AnimatedOpacity(
                              duration: Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                              opacity: snapshot.connectionState ==
                                      ConnectionState.waiting
                                  ? 0.5
                                  : 1,
                              child: Builder(builder: (context) {
                                if (snapshot.hasError ||
                                    snapshot.data == null ||
                                    snapshot.data.state ==
                                        ReadingsSnapshotState.badFormat) {
                                  print(snapshot.error);
                                  return _buildReadingsError();
                                }
                                if (snapshot.data.state ==
                                    ReadingsSnapshotState.downloaded) {
                                  return ReadingsDisplay(
                                      data: snapshot.data.data);
                                }

                                if (snapshot.data.state ==
                                    ReadingsSnapshotState.waitingForDownload) {
                                  return FutureBuilder<Widget>(
                                      key: Key(snapshot.data.requestedId
                                          .serialize()),
                                      future: Future.delayed(
                                          Duration(
                                              seconds:
                                                  15), // TODO: Standard timeouts
                                          () => _buildReadingsError()),
                                      initialData: _buildReadingsDownload(),
                                      builder: (context, snapshot) {
                                        return snapshot.data;
                                      });
                                }

                                return _buildReadingsNotAvailable(
                                    snapshot.data.requestedId);
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
        StatusBarBlendCover(),
      ],
    );
  }

  Widget _buildControlsBoxAndBar() {
    return ControlsBox(
      controller: _controlsState,
      size: controlsBoxSize,
      onCalendarTap: onCalendarTap,
      onSettingsTap: onSettingsTap,
    );
  }

  Widget _buildReadingsNotAvailable(ReadingsDataIdentifier id) {
    final text =
        'Le letture per ${id.day.toLocaleDateString(withArticle: true)} non sono ${id.day.isAfter(Day.now()) ? "ancora" : "più"} disponibili. Seleziona un altro giorno.';
    return Center(
      child: Column(
        children: [
          SizedBox(height: 50),
          Icon(
            SFSymbols.clock,
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
            SFSymbols.exclamationmark_circle,
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
            SFSymbols.cloud_download,
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
      scrollController.animateTo(controlsBoxSize,
          duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
    } else {
      _controlsState.selection = ControlsBoxSelection.calendar;
      scrollController.animateTo(0,
          duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
    }
  }

  void onSettingsTap() {
    if (_controlsState.selection == ControlsBoxSelection.settings &&
        _controlsState.boxOpen != BoxOpenState.closed) {
      scrollController.animateTo(controlsBoxSize,
          duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
    } else {
      _controlsState.selection = ControlsBoxSelection.settings;
      scrollController.animateTo(0,
          duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
    }
  }

  @override
  void dispose() {
    _controlsState.dispose();
    super.dispose();
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

class HomeScrollPhysics extends ScrollPhysics {
  final double controlsBoxSize;
  const HomeScrollPhysics(
      {@required this.controlsBoxSize, ScrollPhysics parent})
      : super(parent: parent);

  @override
  HomeScrollPhysics applyTo(ScrollPhysics ancestor) {
    return HomeScrollPhysics(
        controlsBoxSize: controlsBoxSize, parent: buildParent(ancestor));
  }

  @override
  Simulation createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    if ([0, controlsBoxSize].contains(position.pixels) && velocity == 0) {
      return super.createBallisticSimulation(position, velocity);
    } else {
      if (position.pixels < controlsBoxSize / 2) {
        return ScrollSpringSimulation(spring, position.pixels, 0, velocity,
            tolerance: tolerance);
      } else if (position.pixels >= controlsBoxSize / 2 &&
          position.pixels < controlsBoxSize) {
        return ScrollSpringSimulation(
            spring, position.pixels, controlsBoxSize, velocity,
            tolerance: tolerance);
      } else if (position.pixels < position.maxScrollExtent) {
        return BoundedFrictionSimulation(0.15, position.pixels, velocity,
            controlsBoxSize, position.maxScrollExtent);
      } else {
        return super.createBallisticSimulation(position, velocity);
      }
    }
  }

  @override
  bool get allowImplicitScrolling => false;
}
