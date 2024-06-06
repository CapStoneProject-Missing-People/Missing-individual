class ChatSession {
  final String id;
  final String userId1;
  final String userId2;
  final String lastMessage;
  final DateTime lastMessageTime;

  ChatSession({
    required this.id,
    required this.userId1,
    required this.userId2,
    required this.lastMessage,
    required this.lastMessageTime,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'],
      userId1: json['userId1'],
      userId2: json['userId2'],
      lastMessage: json['lastMessage'],
      lastMessageTime: DateTime.parse(json['lastMessageTime']),
    );
  }
}
