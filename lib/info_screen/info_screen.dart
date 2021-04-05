import 'dart:io';

import 'package:dailyreadings/common/platform_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:package_info/package_info.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

/// A screen with basic information on this app
class InfoScreen extends StatefulWidget {
  @override
  _InfoScreenState createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  final GlobalKey _shareButtonKey = GlobalKey();

  String get _storeLink => Platform.isAndroid
      ? 'https://play.google.com/store/apps/details?id=app.dindondan.dailyreadings'
      : 'https://apps.apple.com/it/app/letture-del-giorno/id1546878499';

  String get _feedbackEmail => 'feedback@dindondan.app';

  String get _donateLink => 'https://dindondan.app/donate.php';

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 400),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 50,
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 60),
                        child: SvgPicture.asset(
                          Theme.of(context).brightness == Brightness.light
                              ? 'assets/logo.svg'
                              : 'assets/logo_dark.svg',
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      FutureBuilder<PackageInfo>(
                        future: PackageInfo.fromPlatform(),
                        builder: (context, snapshot) => Text(
                            'Versione ' +
                                (snapshot.hasData
                                    ? snapshot.data.version
                                    : '0.0.0'),
                            style: Theme.of(context).textTheme.caption),
                      ),
                      SizedBox(height: 20),
                      TextButton.icon(
                        icon: Icon(PlatformIcons.review),
                        label: Text('Lascia una recensione'),
                        onPressed: () => launch(_storeLink),
                      ),
                      ...(kIsWeb || Platform.isAndroid
                          ? [
                              TextButton.icon(
                                icon: Icon(PlatformIcons.donate),
                                label: Text('Sostienici con una donazione'),
                                onPressed: () => launch(_donateLink),
                              ),
                            ]
                          : []),
                      TextButton.icon(
                        icon: Icon(PlatformIcons.share),
                        label: Text('Condividi'),
                        onPressed: _share,
                        key: _shareButtonKey,
                      ),
                      TextButton.icon(
                        icon: Icon(PlatformIcons.mail),
                        label: Text('Feedback'),
                        onPressed: () => launch('mailto:$_feedbackEmail'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: _close,
              ),
              top: 10,
              left: 10,
            ),
          ],
        ),
      ),
    );
  }

  void _share() {
    final RenderBox box = _shareButtonKey.currentContext.findRenderObject();
    Share.share('Scarica Letture del giorno! $_storeLink',
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

  void _close() {
    Navigator.of(context).pop();
  }
}
