import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import 'package:simple_chat_ai/logger.dart';

class Message {
  final String sender;
  final String content;
  final DateTime timestamp;

  const Message({
    required this.sender,
    required this.content,
    required this.timestamp,
  });
}

class Chat {
  final String id;
  final String title;
  final List<Message> _messages = [];
  final StreamController<List<Message>> _messageStreamController =
      StreamController.broadcast();

  Chat({
    required this.title,
  }) : id = const Uuid().v4().toString().replaceAll('-', '').substring(0, 8);

  List<Message> get messages => _messages;
  Stream<List<Message>> get messageStream => _messageStreamController.stream;

  Future<String?> sendRequest(String content) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.100.8:11434/api/chat'),
        body: jsonEncode({
          'model': 'codeLlama:7b',
          'messages': [
            {
              'role': 'user',
              'content': content,
            },
          ],
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200 || response.body.isEmpty) {
        logger.warning(
            'Error occurred while sending message: ${response.body} (${response.statusCode})');
        return null;
      }

      return response.body;
    } catch (e) {
      logger.severe('Error occurred while sending message: $e');
      return null;
    }
  }

  Future<void> addMessage(String sender, String content) async {
    try {
      StringBuffer aiResponse = StringBuffer();

      final response = await sendRequest(content);

      for (var line in response?.split('\n') ?? []) {
        final data = jsonDecode(line);

        aiResponse.write(data['message']['content']);

        if (data['done'] == true) {
          final message = Message(
            sender: data['model'],
            content: aiResponse.toString().trim(),
            timestamp: DateTime.now(),
          );

          addMessageToStream(message);
          logger.info('New message added: $message');
          break;
        }
      }
    } catch (e) {
      logger.severe('Error occurred while sending message: $e');
    }
  }

  void clearMessages() => _messages.clear();

  void addMessageToStream(Message message) {
    _messages.add(message);
    _messageStreamController.add(_messages);
  }

  void dispose() {
    _messageStreamController.close();
  }
}
