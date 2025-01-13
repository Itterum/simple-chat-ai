import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:simple_chat_ai/chat/bloc/chat_event.dart';
import 'package:simple_chat_ai/chat/bloc/chat_state.dart';
import 'package:simple_chat_ai/chat/models/chat_models.dart';
import 'package:simple_chat_ai/chat/services/chat_service.dart';

import 'package:simple_chat_ai/utils/logger.dart';

import 'dart:convert';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc(Chat initialChat) : super(ChatState(chat: initialChat)) {
    on<AddMessageEvent>(_onAddMessage);
    on<CreateSessionEvent>(_onCreateSession);
  }

  Future<void> _onAddMessage(
      AddMessageEvent event, Emitter<ChatState> emit) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));

      final Messages messages = List.from(
        state.chat.sessions
            .firstWhere((session) => session.id == event.sessionId)
            .messages,
      );

      final updateSessions = state.chat.sessions.map((session) {
        if (session.id == event.sessionId) {
          messages.add(Message(
            sender: event.message.sender,
            content: event.message.content,
            timestamp: DateTime.now(),
          ));
          return session.copyWith(messages: messages);
        }
        return session;
      }).toList();

      emit(state.copyWith(
        chat: state.chat.copyWith(sessions: updateSessions),
        isLoading: true,
      ));

      final response = await ChatService.sendMessage(event.message.content);

      final aiResponse = StringBuffer();

      for (var line in response) {
        if (line.trim().isEmpty) continue;

        final data = jsonDecode(line);
        aiResponse.write(data['message']['content']);

        if (data['done'] == true) {
          final aiMessage = Message(
            sender: data['model'],
            content: aiResponse.toString().trim(),
            timestamp: DateTime.now(),
          );

          final updatedSessionsWithAI = state.chat.sessions.map((session) {
            if (session.id == event.sessionId) {
              final updatedMessages = List<Message>.from(session.messages)
                ..add(aiMessage);
              return session.copyWith(messages: updatedMessages);
            }
            return session;
          }).toList();

          emit(state.copyWith(
            chat: state.chat.copyWith(sessions: updatedSessionsWithAI),
            isLoading: false,
          ));
          break;
        }
      }
    } catch (e) {
      final error = 'Error occurred while sending message: $e';
      logger.severe(error);
      emit(state.copyWith(isLoading: false, errorMessage: error));
    }
  }

  void _onCreateSession(CreateSessionEvent event, Emitter<ChatState> emit) {
    final newSession = ChatSession(id: event.sessionId, messages: []);

    if (state.chat.sessions.any((session) => session.id == event.sessionId)) {
      return;
    }

    emit(state.copyWith(
      chat: state.chat.copyWith(sessions: [...state.chat.sessions, newSession]),
    ));
  }
}
