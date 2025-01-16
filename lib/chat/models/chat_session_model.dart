import 'package:simple_chat_ai/chat/models/chat_message_model.dart';

typedef Messages = List<Message>;

class ChatSession {
  final String id;
  final Messages messages;

  const ChatSession({
    required this.id,
    required this.messages,
  });

  ChatSession copyWith({
    String? id,
    Messages? messages,
  }) {
    return ChatSession(
      id: id ?? this.id,
      messages: messages ?? this.messages,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'messages': messages.map((Message x) => x.toMap()).toList(),
    };
  }

  factory ChatSession.fromMap(Map<String, dynamic> map) {
    return ChatSession(
      id: map['id'],
      messages: List<Message>.from(
          map['messages']?.map((x) => Message.fromMap(x)) ?? []),
    );
  }
}
