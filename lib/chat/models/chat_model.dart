import 'package:simple_chat_ai/chat/models/chat_message_model.dart';
import 'package:simple_chat_ai/chat/models/chat_session_model.dart';
import 'package:simple_chat_ai/utils/generate_id.dart';

typedef ChatSessions = List<ChatSession>;

class Chat {
  final String id;
  final String userName;
  final String aiModel;
  final ChatSessions sessions;
  late String currentSessionId;

  Chat({
    required this.id,
    required this.userName,
    required this.aiModel,
    required this.sessions,
    required this.currentSessionId,
  });

  factory Chat.init() {
    final chatId = generateShortId();
    final sessionId = generateShortId();

    return Chat(
      id: chatId,
      userName: 'Ryan Gosling',
      aiModel: 'codeLlama:7b',
      sessions: <ChatSession>[
        ChatSession(
          id: sessionId,
          messages: <Message>[],
        ),
      ],
      currentSessionId: sessionId,
    );
  }

  Chat copyWith({
    String? id,
    String? userName,
    String? aiModel,
    ChatSessions? sessions,
    String? currentSessionId,
  }) {
    return Chat(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      aiModel: aiModel ?? this.aiModel,
      sessions: sessions ?? this.sessions,
      currentSessionId: currentSessionId ?? this.currentSessionId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userName': userName,
      'aiModel': aiModel,
      'sessions': sessions.map((ChatSession x) => x.toMap()).toList(),
    };
  }

  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      id: map['id'],
      userName: map['userName'],
      aiModel: map['aiModel'],
      sessions: List<ChatSession>.from(
          map['sessions']?.map((x) => ChatSession.fromMap(x)) ?? []),
      currentSessionId: map['currentSessionId'],
    );
  }

  Stream<String> simulateMessageTyping(String fullMessage) async* {
    for (int i = 1; i <= fullMessage.length; i++) {
      await Future.delayed(const Duration(milliseconds: 50));
      yield fullMessage.substring(0, i);
    }
  }
}
