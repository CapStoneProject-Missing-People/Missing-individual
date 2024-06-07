class ChatSession {
  final String id;
  final String userId1;
  final String userId2;
  final String message;
  final DateTime time;
  final bool read;

  ChatSession({
    required this.id,
    required this.userId1,
    required this.userId2,
    required this.message,
    required this.time,
    required this.read,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['_id'] ?? '',
      userId1: json['sender'] ?? '',
      userId2: json['receiver'] ?? '',
      message: json['message'] ?? '',
      time: json['time'] != null ? DateTime.parse(json['time']) : DateTime.now(),
      read: json['read'] ?? false,
    );
  }
}
