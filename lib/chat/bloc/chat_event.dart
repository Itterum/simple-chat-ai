import 'package:simple_chat_ai/chat/models/chat_models.dart';

abstract class ChatEvent {}

class AddMessageEvent extends ChatEvent {
  final String sessionId;
  final Message message;

  AddMessageEvent({
    required this.sessionId,
    required this.message,
  });
}

class CreateSessionEvent extends ChatEvent {
  final String sessionId;

  CreateSessionEvent({required this.sessionId});
}

class ClearSessionMessagesEvent extends ChatEvent {
  final String sessionId;

  ClearSessionMessagesEvent({required this.sessionId});
}