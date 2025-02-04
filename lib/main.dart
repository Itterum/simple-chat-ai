import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:system_theme/system_theme.dart';
import 'package:window_manager/window_manager.dart';

import 'chat/presentation/material/chat_page_material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemTheme.accentColor.load();

  if (Platform.isWindows) {
    await flutter_acrylic.Window.initialize();

    await WindowManager.instance.ensureInitialized();

    windowManager.waitUntilReadyToShow().then((_) async {
      await windowManager.setMinimumSize(const Size(1024, 800));
      await windowManager.center();
      await windowManager.show();
      await windowManager.setPreventClose(true);
      await windowManager.setSkipTaskbar(false);
    });

    final Color accentColor = SystemTheme.accentColor.accent;

    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSeed(
            seedColor: accentColor,
            brightness: Brightness.light,
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: accentColor,
            brightness: Brightness.dark,
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        themeMode: ThemeMode.system,
        home: const Chat(),
      ),
    );
  } else if (Platform.isAndroid) {
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        themeMode: ThemeMode.system,
        home: const Chat(),
      ),
    );
  } else {
    throw UnsupportedError('This platform is not supported');
  }
}
