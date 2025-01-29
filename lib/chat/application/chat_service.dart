import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../utils/logger.dart';
import '../domain/ai_model.dart';
import '../domain/ai_response.dart';

class ChatService {
  static Future<AIResponse> sendMessage(String? model, String content) async {
    final http.Response response = await http.post(
      Uri.parse('http://localhost:11434/api/chat'),
      body: jsonEncode(<String, Object>{
        'model': model ?? 'codeLlama:7b',
        'messages': <Map<String, String>>[
          <String, String>{'role': 'user', 'content': content},
        ],
      }),
      headers: <String, String>{'Content-Type': 'application/json'},
    );

    logger.info('Response status: ${response.statusCode}');
    logger.info('Response body: ${response.body}');

    if (response.statusCode != 200 || response.body.isEmpty) {
      throw Exception('Failed to send message');
    }

    final AIResponse aiResponse = response.body
        .trim()
        .split('\n')
        .map((String message) => AIResponse.fromJson(jsonDecode(message)))
        .toList()
        .reduce(
      (AIResponse prev, AIResponse current) {
        current.message.content =
            prev.message.content + current.message.content;
        return current;
      },
    );

    return aiResponse;
  }

  static Future<List<AIModel>> getModels() async {
    final http.Response response = await http.get(
      Uri.parse('http://localhost:11434/api/tags'),
      headers: <String, String>{'Content-Type': 'application/json'},
    );

    logger.info('Response status: ${response.statusCode}');
    logger.info('Response body: ${response.body}');

    if (response.statusCode != 200 || response.body.isEmpty) {
      throw Exception('Failed get models');
    }

    final Map<String, dynamic> responseData = jsonDecode(response.body);

    if (responseData['models'] == null || responseData['models'] is! List) {
      throw Exception('Invalid response format: expected a list of models');
    }

    final List<AIModel> models = (responseData['models'] as List)
        .map((modelJson) => AIModel.fromJson(modelJson))
        .toList();

    return models;
  }
}
