import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import 'package:simple_chat_ai/utils/logger.dart';

class ChatService {
  static Future<List<String>> sendMessage(String content) async {
    final response = await http.post(
      Platform.isAndroid
          ? Uri.parse('http://10.0.2.2:11434/api/chat')
          : Uri.parse('http://localhost:11434/api/chat'),
      // Uri.parse('http://192.168.100.8:11434/api/chat'),
      // Uri.parse('http://10.0.2.2:11434/api/chat'),
      body: jsonEncode({
        'model': 'codeLlama:7b',
        'messages': [
          {'role': 'user', 'content': content},
        ],
      }),
      headers: {'Content-Type': 'application/json'},
    );

    logger.info('Response status: ${response.statusCode}');
    logger.info('Response body: ${response.body}');

    if (response.statusCode != 200 || response.body.isEmpty) {
      throw Exception('Failed to send message');
    }

    final data = response.body.split('\n');

    return data;
  }
}
