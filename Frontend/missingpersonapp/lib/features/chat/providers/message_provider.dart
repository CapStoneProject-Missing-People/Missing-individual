import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:missingpersonapp/features/chat/models/message.dart';
import 'package:missingpersonapp/features/chat/repository/chat_repository.dart';

class MessageProvider with ChangeNotifier {
  Box<Message>? _messagesBox;
  bool _isLoading = false;
  String? _error;
  String? currentChatId;
  bool _hasMore = true;
  int _offset = 0;
  final int _limit = 50;
  final ChatRepository _chatRepository;
  final Map<String, bool> _typingStatus = {};

  List<Message> get messages =>
      _messagesBox?.values.toList().reversed.toList() ?? [];
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get error => _error;
  bool get isInitialized => _messagesBox != null;

  MessageProvider({required ChatRepository chatRepository})
      : _chatRepository = chatRepository;

  Future<void> initialize(String chatId, String userId) async {
    if (currentChatId == chatId && isInitialized) return;

    currentChatId = chatId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _messagesBox?.close();
      _messagesBox = await _openHiveBox<Message>('messages_$chatId');
      await _loadInitialMessages();
      
      // Initialize socket connection for this chat
      _chatRepository.joinChat(
        chatId, 
        userId,
        onNewMessage: handleNewMessage,
        onMessageDeleted: _handleMessageDeleted,
        onTyping: _handleTyping,
        onStatusUpdate: _handleStatusUpdate,
      );
      
      await _updateMessageStatuses();
    } catch (e) {
      _error = 'Failed to initialize chat: ${e.toString()}';
      _messagesBox = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    if (currentChatId != null) {
      _chatRepository.disposeChat(currentChatId!);
    }
    _messagesBox?.close();
    super.dispose();
  }

  void handleNewMessage(Message message) async {
    try {
      // Check if message already exists
      final exists = _messagesBox?.values.any((m) => m.id == message.id) ?? false;
      if (!exists) {
        await _messagesBox?.add(message);
        
        // Update status if message is for current user
        if (message.receiverId == currentChatId && !message.read) {
          await markAsRead(message.id);
        }
        
        notifyListeners();
      }
    } catch (e) {
      print('Error handling new message: $e');
    }
  }

  /// Enhanced message deletion handler
  void _handleMessageDeleted(String messageId) async {
    try {
      final index = _messagesBox?.values.toList().indexWhere((m) => m.id == messageId) ?? -1;
      if (index != -1) {
        await _messagesBox?.deleteAt(index);
        notifyListeners();
      }
    } catch (e) {
      print('Error handling deleted message: $e');
    }
  }

  void _handleTyping(String userId, bool isTyping) {
    // Update typing status
    _typingStatus[userId] = isTyping;
    notifyListeners();

    // Automatically clear typing status after 3 seconds
    if (isTyping) {
      Future.delayed(const Duration(seconds: 3), () {
        if (_typingStatus[userId] == true) {
          _typingStatus[userId] = false;
          notifyListeners();
        }
      });
    }
  }

  // Message status update handler
  void _handleStatusUpdate(String messageId, String status) async {
    try {
      final index = _messagesBox?.values.toList().indexWhere((m) => m.id == messageId) ?? -1;
      if (index != -1) {
        final message = _messagesBox?.getAt(index);
        if (message != null) {
          // Convert string status to enum
          final newStatus = _parseMessageStatus(status);
          
          // Only update if status is "higher" than current
          if (message.status.index < newStatus.index) {
            message.status = newStatus;
            
            // Update read status if needed
            if (newStatus == MessageStatus.read) {
              message.read = true;
            }
            
            await _messagesBox?.putAt(index, message);
            notifyListeners();
          }
        }
      }
    } catch (e) {
      print('Error handling status update: $e');
    }
  }

  // Getter for typing status
  bool isTyping(String userId) => _typingStatus[userId] ?? false;

  // Helper to parse status string to enum
  MessageStatus _parseMessageStatus(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return MessageStatus.delivered;
      case 'read':
        return MessageStatus.read;
      default:
        return MessageStatus.sent;
    }
  }

  Future<Box<T>> _openHiveBox<T>(String name) async {
    try {
      final box = await Hive.openBox<T>(name);
      
      // Prune old messages if over 500
      if (box.length > 500) {
        final keys = box.keys.toList();
        final toDelete = keys.sublist(0, keys.length - 500);
        await box.deleteAll(toDelete);
      }
      
      return box;
    } catch (e) {
      await Hive.deleteBoxFromDisk(name);
      return await Hive.openBox<T>(name);
    }
  }


  Future<void> _loadInitialMessages() async {
    try {
      final messages = await _chatRepository.getMessages(
        currentChatId!,
        limit: _limit,
        offset: _offset,
      );

      await _messagesBox?.clear();
      await _messagesBox?.addAll(messages);
      _offset += messages.length;
      _hasMore = messages.length == _limit;

      await _updateMessagesStatus(messages, MessageStatus.delivered);
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  Future<void> loadMoreMessages() async {
    if (!_hasMore || _isLoading || _messagesBox == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final messages = await _chatRepository.getMessages(
        currentChatId!,
        limit: _limit,
        offset: _offset,
      );

      await _messagesBox?.addAll(messages);
      _offset += messages.length;
      _hasMore = messages.length == _limit;
      _error = null;

      await _updateMessagesStatus(messages, MessageStatus.delivered);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(Message message) async {
    if (_messagesBox == null) return;

    await _messagesBox?.add(message);
    notifyListeners();

    try {
      final sentMessage = await _chatRepository.sendMessage(message);
      final index = _messagesBox?.values
              .toList()
              .lastIndexWhere((m) => m.id == message.id) ??
          -1;

      if (index != -1) {
        await _messagesBox?.putAt(index, sentMessage);
      }
    } catch (e) {
      final index = _messagesBox?.values
              .toList()
              .lastIndexWhere((m) => m.id == message.id) ??
          -1;
      if (index != -1) {
        message.status = MessageStatus.error;
        await _messagesBox?.putAt(index, message);
      }
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<void> deleteMessage(String messageId) async {
    if (_messagesBox == null) return;

    try {
      await _chatRepository.deleteMessage(messageId);
      final index =
          _messagesBox?.values.toList().indexWhere((m) => m.id == messageId) ??
              -1;
      if (index != -1) {
        await _messagesBox?.deleteAt(index);
      }
    } finally {
      notifyListeners();
    }
  }

  Future<void> markAsRead(String messageId) async {
    if (_messagesBox == null) return;

    final index = _messagesBox?.values
            .toList()
            .indexWhere((m) => m.id == messageId && !m.read) ??
        -1;
    if (index != -1) {
      final message = _messagesBox?.getAt(index);
      if (message != null) {
        message.read = true;
        message.status = MessageStatus.read;
        await _messagesBox?.putAt(index, message);
        await _chatRepository.updateMessageStatus(
            messageId, MessageStatus.read);
        notifyListeners();
      }
    }
  }

  Future<void> markAsUnread(String messageId) async {
    if (_messagesBox == null) return;

    final index = _messagesBox?.values
            .toList()
            .indexWhere((m) => m.id == messageId && m.read) ??
        -1;
    if (index != -1) {
      final message = _messagesBox?.getAt(index);
      if (message != null) {
        message.read = false;
        if (message.status == MessageStatus.read) {
          message.status = MessageStatus.delivered;
        }
        await _messagesBox?.putAt(index, message);
        notifyListeners();
      }
    }
  }

  Future<void> _updateMessagesStatus(
      List<Message> messages, MessageStatus status) async {
    if (_messagesBox == null) return;

    for (final message in messages) {
      try {
        if (message.status.index < status.index) {
          message.status = status;
          final index = _messagesBox?.values
                  .toList()
                  .indexWhere((m) => m.id == message.id) ??
              -1;
          if (index != -1) {
            await _messagesBox?.putAt(index, message);
          }
        }
      } catch (e) {
        print('Error updating message status: $e');
      }
    }
  }

  Future<void> _updateMessageStatuses() async {
    try {
      final unreadMessages = _messagesBox?.values
          .where((m) => !m.read && m.receiverId == currentChatId)
          .toList();

      if (unreadMessages != null && unreadMessages.isNotEmpty) {
        for (final message in unreadMessages) {
          await markAsRead(message.id);
        }
      }
    } catch (e) {
      print('Error updating message statuses: $e');
    }
  }

}
