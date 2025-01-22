import 'dart:io';

import 'package:logging/logging.dart';

final Logger logger = Logger('MyApp');

void setupLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord record) {
    stdout.writeln('${record.level.name}: ${record.time}: ${record.message}');
  });
}
