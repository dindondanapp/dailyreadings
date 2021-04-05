import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';

class PlatformIcons {
  static get calendar =>
      Platform.isIOS ? SFSymbols.calendar : Icons.calendar_today;
  static get settings => Platform.isIOS ? SFSymbols.gear : Icons.settings;
  static get moon => Platform.isIOS ? SFSymbols.moon : Icons.nightlight_round;
  static get sun => Platform.isIOS ? SFSymbols.sun_max : Icons.wb_sunny;
  static get minus => Platform.isIOS ? SFSymbols.minus : Icons.remove;
  static get plus => Platform.isIOS ? SFSymbols.plus : Icons.add;
  static get wait => Platform.isIOS ? SFSymbols.clock : Icons.access_time;
  static get error =>
      Platform.isIOS ? SFSymbols.exclamationmark_circle : Icons.error_outline;
  static get downloaad =>
      Platform.isIOS ? SFSymbols.cloud_download : Icons.cloud_download;
  static get info =>
      Platform.isIOS ? SFSymbols.info_circle : Icons.info_outline;
  static get mail => Platform.isIOS ? SFSymbols.envelope : Icons.mail;
  static get share => Platform.isIOS ? SFSymbols.square_arrow_up : Icons.share;
  static get donate => Platform.isIOS ? SFSymbols.heart : Icons.favorite;
  static get review => Platform.isIOS ? SFSymbols.star : Icons.star;
}
