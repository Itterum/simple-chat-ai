class MessageEntity {
  final String? role;
  final String content;
  final DateTime? createdAt;

  MessageEntity({
    required this.role,
    required this.content,
    required this.createdAt,
  });
}
