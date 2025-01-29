import 'dart:io' show Platform;

import 'app/app_desktop.dart' if (dart.library.io) './app/app_desktop.dart';
import 'app/app_mobile.dart' if (dart.library.io) './app/app_mobile.dart';

void main() {
  // if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    runDesktop();
  // } else if (Platform.isAndroid || Platform.isIOS) {
  //   runMobile();
  // } else {
  //   throw UnsupportedError('This platform is not supported');
  // }
}
