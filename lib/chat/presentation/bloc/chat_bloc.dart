import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/ai_entity.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/use_cases/ai_use_case.dart';
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
  final AIEntity model;
  final String content;

  SendMessageEvent(this.model, this.content);
}

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final InitialChatUseCase initialChatUseCase;
  final GetChatsUseCase getChatsUseCase;
  final SendMessageToAIUseCase sendMessageToAIUseCase;

  ChatBloc(
    this.initialChatUseCase,
    this.getChatsUseCase,
    this.sendMessageToAIUseCase,
  ) : super(ChatInitial()) {
    on<InitialChatEvent>(_onInitialChatEvent);
    on<SendMessageEvent>(_onSendMessageToAIEvent);
  }

  Future<void> _onInitialChatEvent(
      InitialChatEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoading());

    try {
      initialChatUseCase.execute(event.aiEntity!);
      final List<ChatEntity> chats = await getChatsUseCase.execute();
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
          await sendMessageToAIUseCase.execute(event.model, event.content);
      if (state is ChatLoaded) {
        final currentChats = List<ChatEntity>.from((state as ChatLoaded).chats);
        emit(ChatLoaded(currentChats));
      }
      // emit(ChatLoaded(message));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }
}
