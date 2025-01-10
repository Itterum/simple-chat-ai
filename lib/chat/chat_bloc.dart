import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:simple_chat_ai/chat/chat_state.dart';
import 'package:simple_chat_ai/chat/message.dart';
import 'package:simple_chat_ai/logger.dart';

abstract class ChatEvent {}

class SendMessage extends ChatEvent {
  final String sender;
  final String content;

  SendMessage({required this.sender, required this.content});
}

class ClearMessages extends ChatEvent {}

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(const ChatState()) {
    on<SendMessage>((event, emit) async {
      try {
        emit(state.copyWith(isLoading: true, errorMessage: null));
        final List<Message> messages = List.from(state.messages);

        messages.add(Message(
          sender: event.sender,
          content: event.content,
          timestamp: DateTime.now(),
        ));

        emit(state.copyWith(
          isLoading: true,
          messages: messages,
        ));

        final response = await http.post(
          Uri.parse('http://localhost:11434/api/chat'),
          // Uri.parse('http://192.168.100.8:11434/api/chat'),
          // Uri.parse('http://10.0.2.2:11434/api/chat'),
          body: jsonEncode({
            'model': 'codeLlama:7b',
            'messages': [
              {'role': 'user', 'content': event.content},
            ],
          }),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode != 200 || response.body.isEmpty) {
          final error =
              'Error occurred while sending message: ${response.body} (${response.statusCode})';
          logger.warning(error);
          emit(state.copyWith(isLoading: false, errorMessage: error));
          return;
        }

        final responseLines = response.body.split('\n');
        final aiResponse = StringBuffer();

        for (var line in responseLines) {
          if (line.trim().isEmpty) continue;

          final data = jsonDecode(line);
          aiResponse.write(data['message']['content']);

          if (data['done'] == true) {
            messages.add(Message(
              sender: data['model'],
              content: aiResponse.toString().trim(),
              timestamp: DateTime.now(),
            ));
            break;
          }
        }

        emit(state.copyWith(
          isLoading: false,
          messages: messages,
        ));
      } catch (e) {
        final error = 'Error occurred while sending message: $e';
        logger.severe(error);
        emit(state.copyWith(isLoading: false, errorMessage: error));
      }
    });

    on<ClearMessages>((event, emit) {
      emit(state.copyWith(messages: []));
    });
  }
}
