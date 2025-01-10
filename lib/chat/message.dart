class Message {
  final String sender;
  final String content;
  final DateTime timestamp;

  const Message({
    required this.sender,
    required this.content,
    required this.timestamp,
  });
}
