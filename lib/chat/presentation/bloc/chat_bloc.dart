import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/ai_entity.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/use_cases/ai_use_case.dart';
import '../../domain/use_cases/chat_use_case.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final ChatEntity chat;

  ChatLoaded(this.chat);
}

class ChatError extends ChatState {
  final String message;

  ChatError(this.message);
}

abstract class ChatEvent {}

class InitialChatEvent extends ChatEvent {
  final AIEntity aiEntity;

  InitialChatEvent(this.aiEntity);
}

class SendMessageEvent extends ChatEvent {
  final String model;
  final String content;

  SendMessageEvent(this.model, this.content);
}

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final InitialChatUseCase initialChatUseCase;
  final SendMessageToAIUseCase sendMessageToAIUseCase;

  ChatBloc(this.initialChatUseCase,
      this.sendMessageToAIUseCase,) : super(ChatInitial()) {
    on<InitialChatEvent>(_onInitialChatEvent);
    on<SendMessageEvent>(_onSendMessageToAIEvent);
  }

  Future<void> _onInitialChatEvent(InitialChatEvent event,
      Emitter<ChatState> emit) async {
    emit(ChatLoading());

    try {
      final chat = initialChatUseCase.execute(event.aiEntity);

      emit(ChatLoaded(chat));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onSendMessageToAIEvent(SendMessageEvent event,
      Emitter<ChatState> emit) async {
    emit(ChatLoading());

    try {
      final message = await sendMessageToAIUseCase.execute(
          event.model, event.content);
      // emit()
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }
}
// class ChatState {
//   final Chat chat;
//   final bool isLoading;
//   final List<AIModel>? models;
//   final AIModel? currentAIModel;
//   final String? errorMessage;
//
//   const ChatState({
//     required this.chat,
//     this.isLoading = false,
//     this.models,
//     this.currentAIModel,
//     this.errorMessage,
//   });
//
//   ChatState copyWith({
//     Chat? chat,
//     bool? isLoading,
//     List<AIModel>? models,
//     AIModel? currentAIModel,
//     String? errorMessage,
//   }) {
//     return ChatState(
//       chat: chat ?? this.chat,
//       isLoading: isLoading ?? this.isLoading,
//       models: models ?? this.models,
//       currentAIModel: currentAIModel ?? this.currentAIModel,
//       errorMessage: errorMessage ?? this.errorMessage,
//     );
//   }
// }

//
// class InitialSessionEvent extends AIEvent {
//   final AIModel? model;
//   final String sessionId;
//
//   InitialSessionEvent({required this.sessionId, this.model});
// }
//
// class AddMessageEvent extends AIEvent {
//   final String sessionId;
//   final String? model;
//   final Message message;
//
//   AddMessageEvent({
//     required this.sessionId,
//     required this.model,
//     required this.message,
//   });
// }
//
// class GetModelsEvent extends AIEvent {}
//
// class SetCurrentModelEvent extends AIEvent {
//   final AIModel? model;
//
//   SetCurrentModelEvent({required this.model});
// }

//
// Future<void> _onAddMessage(
//     AddMessageEvent event, Emitter<ChatState> emit) async {
//   try {
//     emit(state.copyWith(isLoading: true, errorMessage: null));
//
//     final Messages messages = List.from(
//       state.chat.sessions
//           .firstWhere((ChatSession session) => session.id == event.sessionId)
//           .messages,
//     );
//
//     final List<ChatSession> updateSessions =
//         state.chat.sessions.map((ChatSession session) {
//       if (session.id == event.sessionId) {
//         messages.add(Message(
//           role: 'user',
//           content: event.message.content,
//         ));
//         return session.copyWith(messages: messages);
//       }
//       return session;
//     }).toList();
//
//     emit(state.copyWith(
//       chat: state.chat.copyWith(sessions: updateSessions),
//       isLoading: true,
//     ));
//
//     final AIResponse response =
//         await ChatService.sendMessage(event.model, event.message.content);
//
//     final Message aiMessage = Message(
//       role: response.message.role,
//       content: response.message.content,
//     );
//
//     final List<ChatSession> updatedSessionsWithAI =
//         state.chat.sessions.map((ChatSession session) {
//       if (session.id == event.sessionId) {
//         final List<Message> updatedMessages =
//             List<Message>.from(session.messages)..add(aiMessage);
//         return session.copyWith(messages: updatedMessages);
//       }
//       return session;
//     }).toList();
//
//     emit(state.copyWith(
//       chat: state.chat.copyWith(sessions: updatedSessionsWithAI),
//       isLoading: false,
//     ));
//   } catch (e) {
//     final String error = 'Error occurred while sending message: $e';
//     logger.severe(error);
//     emit(state.copyWith(isLoading: false, errorMessage: error));
//   }
// }
//
// void _onGetModels(GetModelsEvent event, Emitter<ChatState> emit) async {
//   final List<AIModel> models = await ChatService.getModels();
//
//   emit(state.copyWith(models: models));
// }
//
// void _onSetCurrentModel(
//     SetCurrentModelEvent event, Emitter<ChatState> emit) async {
//   emit(state.copyWith(currentAIModel: event.model));
// }
