import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../common/configuration.dart';
import '../common/entities.dart';
import '../common/preferences.dart';
import '../controls/settings.dart';

/// A Widget that shows a first-time tutorial
class FirstTimeTutorial extends StatefulWidget {
  /// Creates a widget with instruction on how to use the app. This is supposed
  /// to be shown only on first open, as an overlay of the Home screen
  FirstTimeTutorial({Key key}) : super(key: key);

  @override
  _FirstTimeTutorialState createState() => _FirstTimeTutorialState();
}

class _FirstTimeTutorialState extends State<FirstTimeTutorial> {
  PageController pageController = PageController();
  double _lowerOpacity = 1;
  double _upperOpacity = 1;

  @override
  void initState() {
    super.initState();

    pageController.addListener(() {
      if (pageController.page > 0.8) {
        setState(() {
          _lowerOpacity = 1;
          _upperOpacity = 0;
        });
      }
      if (pageController.page < 0.4) {
        setState(() {
          _lowerOpacity = 1;
          _upperOpacity = 1;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Column(
        children: [
          SizedBox(
            height: 50 + MediaQuery.of(context).padding.top,
            child: AnimatedOpacity(
              opacity: _upperOpacity,
              curve: Curves.easeInOut,
              duration: Configuration.slowTransitionDuration,
              child: Container(
                decoration: BoxDecoration(color: Theme.of(context).canvasColor),
              ),
            ),
          ),
          Expanded(
            child: AnimatedOpacity(
              opacity: _lowerOpacity,
              curve: Curves.easeInOut,
              duration: Configuration.slowTransitionDuration,
              child: Container(
                decoration: BoxDecoration(color: Theme.of(context).canvasColor),
              ),
            ),
          ),
        ],
      ),
      PageView(
        controller: pageController,
        physics: new NeverScrollableScrollPhysics(),
        children: [
          _buildWelcomePage(context),
          _buildCalendarPage(context),
          _buildSettingsPage(context),
        ],
      ),
    ]);
  }

  Widget _buildWelcomePage(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 120),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 300),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/icon.svg',
                      width: 80,
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Text(
                      'Benvenuto!',
                      style: TextStyle(
                        fontSize: 24,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Per iniziare seleziona il rito della messa. '
                      'Potrai cambiarlo in qualunque momento dalle impostazioni.',
                      style: TextStyle(height: 1.5, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    RadioSelector<Rite>(
                      direction: Axis.vertical,
                      selected: Preferences.of(context).rite,
                      onSelect: (value) => Preferences.of(context).rite = value,
                      valueIcons: {
                        Rite.roman: Container(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: Text('Romano'),
                        ),
                        Rite.ambrosian: Container(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: Text('Ambrosiano'),
                        ),
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                onPressed: () => pageController.nextPage(
                  curve: Curves.easeInOut,
                  duration: Configuration.defaultTransitionDuration,
                ),
                child: Text('Avanti'),
              ),
            ),
            padding: EdgeInsets.only(bottom: 40),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarPage(BuildContext context) {
    return SafeArea(
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: () => nextPage(),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              color: Colors.transparent,
              child: Center(
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(maxWidth: Configuration.maxReaderWidth),
                  child: Container(
                    padding: EdgeInsets.only(top: 45, left: 15, right: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: 34),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Icon(
                              Icons.arrow_upward,
                              size: 24,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 380),
                          child: Text(
                            'Aprendo l\'app troverai sempre le letture di oggi. '
                            'Per visualizzare le letture di un altro giorno tocca l\'icona del calendario'
                            'oppure tocca le frecce per scorrere tra i giorni.',
                            style: TextStyle(
                              height: 1.5,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                onPressed: () => nextPage(),
                child: Text('Avanti'),
              ),
            ),
            padding: EdgeInsets.only(bottom: 40),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsPage(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => close(),
            child: Container(
              color: Colors.transparent,
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Center(
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(maxWidth: Configuration.maxReaderWidth),
                  child: Container(
                    padding: EdgeInsets.only(top: 45, left: 15, right: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: Icon(
                            Icons.arrow_upward,
                            size: 24,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 500),
                          child: Text(
                            'Tocca l\'icona delle impostazioni per modificare '
                            'in qualunque momento la scelta del rito, '
                            'le dimensioni del testo e il tema',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              height: 1.5,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                onPressed: () => close(),
                child: Text('Avanti'),
              ),
            ),
            padding: EdgeInsets.only(bottom: 40),
          ),
        ],
      ),
    );
  }

  void nextPage() {
    pageController.nextPage(
      curve: Curves.easeInOut,
      duration: Configuration.defaultTransitionDuration,
    );
  }

  void close() {
    Preferences.of(context).firstTime = false;
  }
}
