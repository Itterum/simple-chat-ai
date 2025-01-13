class Message {
  final String sender;
  final String content;
  final DateTime timestamp;
  bool isTyping;

  Message({
    required this.sender,
    required this.content,
    required this.timestamp,
    this.isTyping = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'sender': sender,
      'content': content,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      sender: map['sender'],
      content: map['content'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
    );
  }
}

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
    return {
      'id': id,
      'messages': messages.map((x) => x.toMap()).toList(),
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

class Chat {
  final String id;
  final String userName;
  final String aiModel;
  final List<ChatSession> sessions;

  const Chat({
    required this.id,
    required this.userName,
    required this.aiModel,
    required this.sessions,
  });

  Chat copyWith({
    String? id,
    String? userName,
    String? aiModel,
    List<ChatSession>? sessions,
  }) {
    return Chat(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      aiModel: aiModel ?? this.aiModel,
      sessions: sessions ?? this.sessions,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userName': userName,
      'aiModel': aiModel,
      'sessions': sessions.map((x) => x.toMap()).toList(),
    };
  }

  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      id: map['id'],
      userName: map['userName'],
      aiModel: map['aiModel'],
      sessions: List<ChatSession>.from(
          map['sessions']?.map((x) => ChatSession.fromMap(x)) ?? []),
    );
  }
}
