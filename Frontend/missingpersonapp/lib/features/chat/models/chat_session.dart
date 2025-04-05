import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

part 'chat_session.g.dart';

@HiveType(typeId: 5)
class ChatSession {
  @HiveField(0)
  final String partnerId;

  @HiveField(1)
  final String partnerName; // Add this field

  @HiveField(2)
  final String lastMessage;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  final bool isRead;

  @HiveField(5)
  final int unreadCount;

  @HiveField(6)
  final String? imageBase64;

  ChatSession({
    required this.partnerId,
    required this.partnerName, // Initialize this field
    required this.lastMessage,
    required this.timestamp,
    this.isRead = true,
    this.unreadCount = 0,
    this.imageBase64,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    // Handle both direct fields and nested lastMessage/partnerDetails
    final lastMessage = json['lastMessage'] is Map ? json['lastMessage'] : {};
    final partnerDetails =
        json['partnerDetails'] is Map ? json['partnerDetails'] : {};

    return ChatSession(
      partnerId: (json['_id'] ?? json['partnerId'] ?? '').toString(),
      partnerName: json['partnerName'] ?? // Check direct field first
          partnerDetails['name'] ??
          partnerDetails['username'] ??
          'Unknown',
      lastMessage: lastMessage['message'] ??
          json['lastMessage'] ??
          '', // Also check direct lastMessage
      timestamp: (lastMessage['time'] ?? json['timestamp']) != null
          ? DateTime.parse(
              (lastMessage['time'] ?? json['timestamp']).toString())
          : DateTime.now(),
      isRead: json['isRead'] ?? lastMessage['read'] ?? true,
      unreadCount: json['unreadCount'] ?? 0,
      imageBase64: lastMessage['imageBase64'],
    );
  }

  Map<String, dynamic> toJson() => {
        'partnerId': partnerId,
        'lastMessage': lastMessage,
        'timestamp': timestamp.toIso8601String(),
        'isRead': isRead,
        'unreadCount': unreadCount,
        'imageBase64': imageBase64,
      };

  ChatSession copyWith({
    String? partnerId,
    String? partnerName, // Add this parameter
    String? lastMessage,
    DateTime? timestamp,
    bool? isRead,
    int? unreadCount,
    String? imageBase64,
  }) {
    return ChatSession(
      partnerId: partnerId ?? this.partnerId,
      partnerName: this.partnerName, // Keep the original partnerName
      lastMessage: lastMessage ?? this.lastMessage,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      unreadCount: unreadCount ?? this.unreadCount,
      imageBase64: imageBase64 ?? this.imageBase64,
    );
  }

  String get formattedTime {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (timestamp.isAfter(today)) {
      return DateFormat('h:mm a').format(timestamp);
    } else if (timestamp.isAfter(yesterday)) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }
}
