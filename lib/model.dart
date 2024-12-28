import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:simple_chat_ai/logger.dart';

class Chat {
  final String? name;
  final String? message;
  final String time;

  const Chat({
    required this.name,
    required this.message,
    required this.time,
  });

  @override
  String toString() {
    return '$message at $time';
  }
}

class ChatProvide {
  final List<Chat> _chats = [];
  final StreamController<Chat> _chatStreamController =
      StreamController<Chat>.broadcast();

  List<Chat> get chats => _chats;
  Stream<Chat> get chatStream => _chatStreamController.stream;

  Future<void> sendMessage(String name, String message) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.100.8:11434/api/chat'),
        body: jsonEncode({
          'model': 'codeLlama:7b',
          'messages': [
            {'role': 'user', 'content': message},
          ],
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      _chatStreamController.add(Chat(
        name: name,
        message: message,
        time: DateFormat('HH:mm').format(DateTime.now()),
      ));

      if (response.statusCode == 200) {
        StringBuffer aiResponse = StringBuffer();

        for (var line in response.body.split('\n')) {
          if (line.isNotEmpty) {
            final data = jsonDecode(line);
            if (data['done'] == false) {
              aiResponse.write(data['message']['content']);
            } else {
              final chatMessage = Chat(
                name: data['model'],
                message: aiResponse.toString().trim(),
                time: DateFormat('HH:mm:ss').format(DateTime.now()),
              );
              _chats.add(chatMessage);
              _chatStreamController.add(chatMessage);
              logger.info('New message added: $chatMessage');
              break;
            }
          }
        }
      } else {
        logger.warning(
            'Request failed with status: ${response.statusCode}. Response body: ${response.body}');
      }
    } catch (e) {
      logger.severe('Error occurred while sending message: $e');
    }
  }

  void dispose() {
    _chatStreamController.close();
  }
}
