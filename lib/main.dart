import 'dart:io' show Platform;

// Conditional imports
import 'app/app_desktop.dart' if (dart.library.io) './app/app_desktop.dart';
import 'app/app_mobile.dart' if (dart.library.io) './app/app_mobile.dart';

void main() {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    runDesktop(); // Runs the desktop version
  } else if (Platform.isAndroid || Platform.isIOS) {
    runMobile(); // Runs the mobile version
  } else {
    throw UnsupportedError('This platform is not supported');
  }
}
