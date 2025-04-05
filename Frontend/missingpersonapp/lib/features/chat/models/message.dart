import 'package:hive/hive.dart';

part 'message.g.dart';

@HiveType(typeId: 0)
enum MessageStatus {
  @HiveField(0) sent,
  @HiveField(1) delivered,
  @HiveField(2) read,
  @HiveField(3) sending,
  @HiveField(4) error,
  @HiveField(5) unknown;

  factory MessageStatus.fromString(String status) {
    switch (status) {
      case 'sent': return MessageStatus.sent;
      case 'delivered': return MessageStatus.delivered;
      case 'read': return MessageStatus.read;
      case 'sending': return MessageStatus.sending;
      case 'error': return MessageStatus.error;
      default: return MessageStatus.unknown;
    }
  }

  String toStringValue() {
    switch (this) {
      case MessageStatus.sent: return 'sent';
      case MessageStatus.delivered: return 'delivered';
      case MessageStatus.read: return 'read';
      case MessageStatus.sending: return 'sending';
      case MessageStatus.error: return 'error';
      default: return 'unknown';
    }
  }
}

@HiveType(typeId: 1)
class Message {
  @HiveField(0) final String id;
  @HiveField(1) final String senderId;
  @HiveField(2) final String receiverId;
  @HiveField(8) final String? senderName;
  @HiveField(9) final String? receiverName;
  @HiveField(3) final String content;
  @HiveField(4) final DateTime timestamp;
  @HiveField(5) final String? imageBase64;
  @HiveField(6) MessageStatus status;
  @HiveField(7) bool read;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    this.imageBase64,
    this.status = MessageStatus.sending,
    this.read = false,
    this.senderName,
    this.receiverName,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: json['sender'],
      receiverId: json['receiver'],
      content: json['message'] ?? '',
      timestamp: DateTime.parse(json['time'] ?? DateTime.now().toIso8601String()),
      imageBase64: json['imageBase64'],
      status: MessageStatus.fromString(json['status'] ?? 'sent'),
      read: json['read'] ?? false,
      senderName: json['senderName'] ?? json['senderDetails']?['username'],
      receiverName: json['receiverName'] ?? json['receiverDetails']?['username'],
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'sender': senderId,
    'receiver': receiverId,
    'message': content,
    'time': timestamp.toIso8601String(),
    'imageBase64': imageBase64,
    'status': status.toStringValue(),
    'read': read,
    'senderName': senderName,
    'receiverName': receiverName,
  };

  bool get isImageMessage => imageBase64 != null && imageBase64!.isNotEmpty;
}
