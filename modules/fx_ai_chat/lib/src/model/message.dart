enum ChatRole { assistant, system, user }

class Message {
  final String content;
  final ChatRole role;

  Message({required this.content, this.role = ChatRole.user});

  Message.ai(this.content) : role = ChatRole.assistant;

  Message.system(this.content) : role = ChatRole.system;

  Message.user(this.content) : role = ChatRole.user;

  factory Message.fromMap(dynamic map) {
    String roleString = map['role'];
    int roleIndex = ChatRole.values.indexWhere((e) => e.name == roleString);
    ChatRole role = ChatRole.user;
    if (roleIndex != -1) {
      role = ChatRole.values[roleIndex];
    }
    return Message(
      content: map['content'] ?? '',
      role: role,
    );
  }

  Map<String, dynamic> toJson() => {
        'role': role.name,
        'content': content,
      };
}
