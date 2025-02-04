import '../../../utils/generate_id.dart';
import '../../domain/entities/ai_entity.dart';
import '../../domain/entities/chat_entity.dart';

abstract class ChatRepository {
  Future<ChatEntity> createChat(AIEntity aiEntity);

  Future<ChatEntity> getChat(String id);

  Future<List<ChatEntity>> getChats();

  Future<void> deleteChat();

  Future<void> deleteChats();
}

List<ChatEntity> chats = [];

class ChatRepositoryImpl implements ChatRepository {
  @override
  Future<ChatEntity> createChat(AIEntity aiEntity) async {
    final chat = ChatEntity(
      id: generateShortId(),
      aiEntity: aiEntity,
      messages: [],
    );

    chats.add(chat);

    return chat;
  }

  @override
  Future<ChatEntity> getChat(String id) async {
    return chats.where((chat) => chat.id == id).toList().first;
  }

  @override
  Future<List<ChatEntity>> getChats() async {
    return chats;
  }

  @override
  Future<void> deleteChat() {
    // TODO: implement deleteChat
    throw UnimplementedError();
  }

  @override
  Future<void> deleteChats() {
    // TODO: implement deleteChats
    throw UnimplementedError();
  }
}
