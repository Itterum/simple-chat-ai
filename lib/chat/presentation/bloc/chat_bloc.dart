import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/ai_entity.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/use_cases/chat_use_case.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatEntity> chats;

  ChatLoaded(this.chats);
}

class ChatError extends ChatState {
  final String message;

  ChatError(this.message);
}

abstract class ChatEvent {}

class InitialChatEvent extends ChatEvent {
  final AIEntity? aiEntity;

  InitialChatEvent(this.aiEntity);
}

class SendMessageEvent extends ChatEvent {
  final String chatId;
  final AIEntity model;
  final String content;

  SendMessageEvent(this.chatId, this.model, this.content);
}

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatUseCase chatUseCase;

  ChatBloc(
    this.chatUseCase,
  ) : super(ChatInitial()) {
    on<InitialChatEvent>(_onInitialChatEvent);
    on<SendMessageEvent>(_onSendMessageToAIEvent);
  }

  Future<void> _onInitialChatEvent(
      InitialChatEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoading());

    try {
      chatUseCase.init(event.aiEntity!);
      final List<ChatEntity> chats = await chatUseCase.getChats();
      emit(ChatLoaded(chats));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onSendMessageToAIEvent(
      SendMessageEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoading());

    try {
      final message =
          await chatUseCase.sendMessageToAI(event.model, event.content);
      await chatUseCase.addMessage(event.chatId, message);

      final List<ChatEntity> chats = await chatUseCase.getChats();
      emit(ChatLoaded(chats));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }
}
