import 'dart:io' show Platform;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:system_theme/system_theme.dart';
import 'package:window_manager/window_manager.dart';

import '../chat/presentation/fluent/chat_page_fluent.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemTheme.accentColor.load();

  if (Platform.isWindows) {
    await flutter_acrylic.Window.initialize();

    await WindowManager.instance.ensureInitialized();

    windowManager.waitUntilReadyToShow().then((_) async {
      await windowManager.setMinimumSize(const Size(1024, 600));
      await windowManager.center();
      await windowManager.show();
      await windowManager.setPreventClose(true);
      await windowManager.setSkipTaskbar(false);
    });

    runApp(
      FluentApp(
        debugShowCheckedModeBanner: false,
        theme: FluentThemeData(
          brightness: Brightness.light,
          visualDensity: VisualDensity.standard,
          accentColor: SystemTheme.accentColor.accent.toAccentColor(),
        ),
        darkTheme: FluentThemeData(
          brightness: Brightness.dark,
          visualDensity: VisualDensity.standard,
          accentColor: SystemTheme.accentColor.accent.toAccentColor(),
        ),
        themeMode: ThemeMode.system,
        home: const ChatPageFluent(),
      ),
    );
  } else {
    throw UnsupportedError('This platform is not supported');
  }
}
