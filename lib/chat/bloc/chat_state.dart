import 'package:simple_chat_ai/chat/models/chat_models.dart';

class ChatState {
  final Chat chat;
  final bool isLoading;
  final String? errorMessage;

  const ChatState({
    required this.chat,
    this.isLoading = false,
    this.errorMessage,
  });

  ChatState copyWith({
    Chat? chat,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ChatState(
      chat: chat ?? this.chat,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
