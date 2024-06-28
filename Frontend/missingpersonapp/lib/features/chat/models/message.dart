import 'package:hive/hive.dart';

part 'message.g.dart';

@HiveType(typeId: 0)
class Message {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String senderId;

  @HiveField(2)
  final String receiverId;

  @HiveField(3)
  final String content;

  @HiveField(4)
  final DateTime timestamp;

  @HiveField(5)
  final String? imageUrl;

  @HiveField(6)
  final bool read;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    this.imageUrl,
    this.read = false,
  });

  // Define the fromJson method
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'] as String,
      senderId: json['sender'] as String,
      receiverId: json['receiver'] as String,
      content: json['message'] as String,
      timestamp: DateTime.parse(json['time'] as String),
      imageUrl: json['imageUrl'] as String?,
      read: json['read'] as bool,
    );
  }

  // Optionally, define the toJson method for serialization
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'sender': senderId,
      'receiver': receiverId,
      'message': content,
      'time': timestamp.toIso8601String(),
      'imageUrl': imageUrl,
      'read': read,
    };
  }
}
