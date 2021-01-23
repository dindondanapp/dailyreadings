/// Some app-wide useful constants
class Configuration {
  static Duration networkTimeout = Duration(seconds: 15);
  static Duration quickTransitionDuration = Duration(milliseconds: 200);
  static Duration defaultTransitionDuration = Duration(milliseconds: 500);
  static Duration slowTransitionDuration = Duration(seconds: 1);
  static double maxReaderWidth = 600;
}
