import 'dart:io';

import 'package:missingpersonapp/features/chat/models/chat_session.dart';
import 'package:missingpersonapp/features/chat/models/message.dart';
import 'package:missingpersonapp/features/chat/services/chat_services.dart';
import 'package:missingpersonapp/features/chat/services/image_upload_service.dart';
import 'package:missingpersonapp/features/chat/services/socket_services.dart';

class ChatRepository {
  final ChatServices _chatServices;
  final SocketService _socketService;
  final ImageUploadService _imageUploadService;
  final Map<String, Tuple2<List<Message>, DateTime>> _messageCache = {};

  ChatRepository({
    required ChatServices chatServices,
    required SocketService socketService,
    required ImageUploadService imageUploadService,
  })  : _chatServices = chatServices,
        _socketService = socketService,
        _imageUploadService = imageUploadService;

  Future<List<Message>> getMessages(String receiverId,
      {int limit = 50, int offset = 0}) {
    return _chatServices.fetchMessages(receiverId,
        limit: limit, offset: offset);
  }

  Future<List<ChatSession>> getChatSessions(String userId) {
    return _chatServices.fetchChatSessions(userId);
  }

  Future<Message> sendMessage(Message message) async {
    // Send via Socket.IO for real-time
    _socketService.sendMessage(
      chatId: message.receiverId,
      message: message,
    );

    // Also send via HTTP for reliability
    return _chatServices.sendMessage(message);
  }

  Future<void> deleteMessage(String messageId) {
    return _chatServices.deleteMessage(messageId);
  }

  Future<void> updateMessageStatus(String messageId, MessageStatus status) {
    return _chatServices.updateMessageStatus(messageId, status);
  }

  Future<String?> uploadImage(File imageFile, String userId) {
    return _imageUploadService.uploadImage(imageFile);
  }

  Future<List<Message>> syncMessages(String chatId) async {
    try {
      final messages = await _chatServices.fetchMessages(chatId);
      return messages;
    } catch (e) {
      print('Sync error: $e');
      rethrow;
    }
  }

  Future<void> joinChat(
    String chatId,
    String userId, {
    required void Function(Message) onNewMessage,
    required void Function(String) onMessageDeleted,
    required void Function(String, bool) onTyping,
    required void Function(String, String) onStatusUpdate,
  }) async {
    try {
      await _socketService.initializeChatSocket(
        chatId: chatId,
        userId: userId,
        onNewMessage: (message) {
          // Add sequence checking if available
          onNewMessage(message);
        },
        onMessageDeleted: onMessageDeleted,
        onTyping: onTyping,
        onStatusUpdate: onStatusUpdate,
      );
    } catch (e) {
      print('Error joining chat: $e');
      rethrow;
    }
  }

  Future<void> initializeGlobalListeners({
    required String userId,
    required void Function(Message) onNewMessage,
  }) async {
    try {
      await _socketService.initializeGlobalSocket(
        userId: userId,
        onNewMessage: (message) {
          onNewMessage(message);
        },
      );
    } catch (e) {
      print('Error initializing global listeners: $e');
      rethrow;
    }
  }

  void dispose() {
    _socketService.dispose();
    _messageCache.clear();
  }

  void disposeChat(String chatId) {
    _socketService.disposeChat(chatId);
    _messageCache.removeWhere((key, _) => key.startsWith(chatId));
  }

  Future<List<Message>> searchMessages(String userId, String query) async {
    return _chatServices.searchMessages(userId: userId, query: query);
  }
}

class Tuple2<T1, T2> {
  final T1 item1;
  final T2  item2;

  Tuple2(this.item1, this.item2);
}
