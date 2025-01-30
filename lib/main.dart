import 'dart:io' show Platform;

import 'app/app_desktop.dart' if (dart.library.io) './app/app_desktop.dart';

void main() {
  if (Platform.isWindows) {
    runDesktop();
  } else {
    throw UnsupportedError('This platform is not supported');
  }
}
