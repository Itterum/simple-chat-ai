import 'message_model.dart';

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

  ChatSession.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        messages = List<Message>.from(
            json['messages']?.map((x) => Message.fromJson(x)) ?? []);

  Map<String, dynamic> toJson() => {
        'id': id,
        'messages': messages.map((Message x) => x.toJson()).toList(),
      };
}
