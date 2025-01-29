import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/logger.dart';
import '../application/chat_service.dart';
import '../domain/ai_model.dart';
import '../domain/ai_response.dart';
import '../domain/chat_model.dart';
import '../domain/chat_session_model.dart';
import '../domain/message_model.dart';

class ChatState {
  final Chat chat;
  final bool isLoading;
  final List<AIModel>? models;
  final AIModel? currentAIModel;
  final String? errorMessage;

  const ChatState({
    required this.chat,
    this.isLoading = false,
    this.models,
    this.currentAIModel,
    this.errorMessage,
  });

  ChatState copyWith({
    Chat? chat,
    bool? isLoading,
    List<AIModel>? models,
    AIModel? currentAIModel,
    String? errorMessage,
  }) {
    return ChatState(
      chat: chat ?? this.chat,
      isLoading: isLoading ?? this.isLoading,
      models: models ?? this.models,
      currentAIModel: currentAIModel ?? this.currentAIModel,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

abstract class ChatEvent {}

class InitialSessionEvent extends ChatEvent {
  final AIModel? model;
  final String sessionId;

  InitialSessionEvent({required this.sessionId, this.model});
}

class AddMessageEvent extends ChatEvent {
  final String sessionId;
  final String? model;
  final Message message;

  AddMessageEvent({
    required this.sessionId,
    required this.model,
    required this.message,
  });
}

class GetModelsEvent extends ChatEvent {}

class SetCurrentModelEvent extends ChatEvent {
  final AIModel? model;

  SetCurrentModelEvent({required this.model});
}

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc(Chat initialChat) : super(ChatState(chat: initialChat)) {
    on<AddMessageEvent>(_onAddMessage);
    on<GetModelsEvent>(_onGetModels);
    on<SetCurrentModelEvent>(_onSetCurrentModel);
  }

  Future<void> _onAddMessage(
      AddMessageEvent event, Emitter<ChatState> emit) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));

      final Messages messages = List.from(
        state.chat.sessions
            .firstWhere((ChatSession session) => session.id == event.sessionId)
            .messages,
      );

      final List<ChatSession> updateSessions =
          state.chat.sessions.map((ChatSession session) {
        if (session.id == event.sessionId) {
          messages.add(Message(
            role: 'user',
            content: event.message.content,
          ));
          return session.copyWith(messages: messages);
        }
        return session;
      }).toList();

      emit(state.copyWith(
        chat: state.chat.copyWith(sessions: updateSessions),
        isLoading: true,
      ));

      final AIResponse response =
          await ChatService.sendMessage(event.model, event.message.content);

      final Message aiMessage = Message(
        role: response.message.role,
        content: response.message.content,
      );

      final List<ChatSession> updatedSessionsWithAI =
          state.chat.sessions.map((ChatSession session) {
        if (session.id == event.sessionId) {
          final List<Message> updatedMessages =
              List<Message>.from(session.messages)..add(aiMessage);
          return session.copyWith(messages: updatedMessages);
        }
        return session;
      }).toList();

      emit(state.copyWith(
        chat: state.chat.copyWith(sessions: updatedSessionsWithAI),
        isLoading: false,
      ));
    } catch (e) {
      final String error = 'Error occurred while sending message: $e';
      logger.severe(error);
      emit(state.copyWith(isLoading: false, errorMessage: error));
    }
  }

  void _onGetModels(GetModelsEvent event, Emitter<ChatState> emit) async {
    final List<AIModel> models = await ChatService.getModels();

    emit(state.copyWith(models: models));
  }

  void _onSetCurrentModel(
      SetCurrentModelEvent event, Emitter<ChatState> emit) async {
    emit(state.copyWith(currentAIModel: event.model));
  }
}
