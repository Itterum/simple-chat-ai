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
    return <String, >{
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
