import '../../../utils/generate_id.dart';
import 'ai_model.dart';
import 'chat_session_model.dart';
import 'message_model.dart';

typedef ChatSessions = List<ChatSession>;

class Chat {
  final String id;
  late AIModel? aiModel;
  final ChatSessions sessions;
  late String currentSessionId;

  Chat({
    required this.id,
    this.aiModel,
    required this.sessions,
    required this.currentSessionId,
  });

  factory Chat.init() {
    final chatId = generateShortId();
    final sessionId = generateShortId();

    return Chat(
      id: chatId,
      aiModel: null,
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
    AIModel? aiModel,
    ChatSessions? sessions,
    String? currentSessionId,
  }) {
    return Chat(
      id: id ?? this.id,
      aiModel: aiModel ?? this.aiModel,
      sessions: sessions ?? this.sessions,
      currentSessionId: currentSessionId ?? this.currentSessionId,
    );
  }

  Chat.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        aiModel =
            json['aiModel'] != null ? AIModel.fromJson(json['aiModel']) : null,
        sessions = List<ChatSession>.from(
            json['sessions']?.map((x) => ChatSession.fromJson(x)) ?? []),
        currentSessionId = json['currentSessionId'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'aiModel': aiModel != null ? AIModel.toJson(aiModel!) : null,
        'sessions': sessions.map((ChatSession x) => x.toJson()).toList(),
        'currentSessionId': currentSessionId,
      };
}
