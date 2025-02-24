class Message {
  String? role;
  String content;

  Message({
    required this.role,
    required this.content,
  });

  Message.fromJson(Map<String, dynamic> json)
      : role = json['role'],
        content = json['content'];

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
      };
}
