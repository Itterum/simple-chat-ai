import 'package:flutter/material.dart';
import 'package:simple_chat_ai/chat/views/chat_view.dart';
import 'package:simple_chat_ai/utils/logger.dart';

void main() {
  setupLogging();
  runApp(const MainApp());
  logger.info('Application started');
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: ChatPage(),
        ),
      ),
    );
  }
}
