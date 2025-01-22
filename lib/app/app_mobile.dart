import 'package:flutter/material.dart';
import 'package:simple_chat_ai/chat/views/chat_view_material.dart';

void runMobile() {
  runApp(const MaterialApp(
    home: Scaffold(
      body: Center(
        child: ChatPageMaterial(),
      ),
    ),
  ));
}
