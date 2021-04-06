/// Some app-wide useful constants
class Configuration {
  static String backendVersion = 'version-1';
  static Duration networkTimeout = Duration(seconds: 15);
  static Duration quickTransitionDuration = Duration(milliseconds: 200);
  static Duration defaultTransitionDuration = Duration(milliseconds: 500);
  static Duration slowTransitionDuration = Duration(seconds: 1);
  static double maxReaderWidth = 600;
}
