import 'ai_entity.dart';
import 'message_entity.dart';

class ChatEntity {
  final String id;
  late AIEntity? aiEntity;
  late List<MessageEntity> messages;

  ChatEntity({
    required this.id,
    required this.aiEntity,
    required this.messages,
  });
}
