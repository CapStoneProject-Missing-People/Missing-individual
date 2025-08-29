import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';
import 'package:missingpersonapp/features/chat/models/chat_session.dart';
import 'package:missingpersonapp/features/chat/models/message.dart';
import 'package:missingpersonapp/features/chat/repository/chat_repository.dart';

class ChatProvider with ChangeNotifier {
  final ChatRepository _chatRepository;
  List<ChatSession> _sessions = [];
  bool _isLoading = false;
  String? _error;
  String? _currentUserId;
  final Map<String, bool> _typingStatus = {};
  final Map<String, Timer> _typingTimers = {};
  final Map<String, DateTime> _lastSessionUpdates = {};
  final StreamController<Message> _messageStreamController = StreamController<Message>.broadcast();
  bool _isConnected = false;

  ChatProvider({required ChatRepository chatRepository}) 
      : _chatRepository = chatRepository;

  List<ChatSession> get sessions => _sessions;
  List<ChatSession> get sortedSessions => List.from(_sessions)
    ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isConnected => _isConnected;
  Stream<Message> get messageStream => _messageStreamController.stream;
  bool isTyping(String partnerId) => _typingStatus[partnerId] ?? false;

  Future<void> loadSessions(String userId) async {
    if (_currentUserId == userId && _sessions.isNotEmpty) return;

    _currentUserId = userId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final sessions = await _chatRepository.getChatSessions(userId);
      _sessions = sessions.where((s) => s.partnerId.isNotEmpty).toList();
      _error = null;
    } catch (e) {
      print('Error loading sessions: $e');
      _error = 'Failed to load conversations';
      _sessions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> initializeSocketListeners({
    required String userId,
    required void Function(Message) onNewMessage,
  }) async {
    try {
      if (_currentUserId == userId && _isConnected) return;
      
      _currentUserId = userId;
      
      await _chatRepository.initializeGlobalListeners(
        userId: userId,
        onNewMessage: (message) {
          final partnerId = message.senderId == userId 
              ? message.receiverId 
              : message.senderId;
          
          updateSessionLastMessage(
            partnerId: partnerId,
            message: message,
          );
          
          _messageStreamController.add(message);
          onNewMessage(message);
        },
      );
      
      _isConnected = true;
      notifyListeners();
      
      // Add periodic sync
      Timer.periodic(const Duration(minutes: 5), (_) => _syncSessions());
    } catch (e) {
      print('Error initializing socket listeners: $e');
      _isConnected = false;
      notifyListeners();
      
      // Retry with backoff
      await Future.delayed(const Duration(seconds: 5));
      await initializeSocketListeners(userId: userId, onNewMessage: onNewMessage);
    }
  }

  Future<void> _syncSessions() async {
    if (_currentUserId == null) return;
    
    try {
      final freshSessions = await _chatRepository.getChatSessions(_currentUserId!);
      if (!const DeepCollectionEquality().equals(_sessions, freshSessions)) {
        _sessions = freshSessions;
        notifyListeners();
      }
    } catch (e) {
      print('Error syncing sessions: $e');
    }
  }

  void updateSessionLastMessage({
    required String partnerId,
    required Message message,
  }) {
    try {
      final now = DateTime.now();
      if (_lastSessionUpdates[partnerId] != null && 
          now.difference(_lastSessionUpdates[partnerId]!) < const Duration(milliseconds: 500)) {
        return;
      }
      _lastSessionUpdates[partnerId] = now;

      final existingIndex = _sessions.indexWhere((s) => s.partnerId == partnerId);
      final isNewMessage = existingIndex == -1 || 
          _sessions[existingIndex].timestamp.isBefore(message.timestamp);

      if (isNewMessage) {
        final newSession = existingIndex != -1
            ? _sessions[existingIndex].copyWith(
                lastMessage: message.content,
                timestamp: message.timestamp,
                isRead: message.senderId == _currentUserId,
                unreadCount: message.senderId == _currentUserId
                    ? 0
                    : _sessions[existingIndex].unreadCount + 1,
                imageBase64: message.imageBase64,
              )
            : ChatSession(
                partnerId: partnerId,
                partnerName: message.receiverName ?? 'Unknown',
                lastMessage: message.content,
                timestamp: message.timestamp,
                isRead: message.senderId == _currentUserId,
                unreadCount: message.senderId == _currentUserId ? 0 : 1,
                imageBase64: message.imageBase64,
              );

        final newSessions = List<ChatSession>.from(_sessions);
        if (existingIndex != -1) {
          newSessions.removeAt(existingIndex);
        }
        newSessions.insert(0, newSession);

        if (_sessions.length != newSessions.length ||
            !const DeepCollectionEquality().equals(_sessions, newSessions)) {
          _sessions = newSessions;
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error updating session last message: $e');
    }
  }

  void markSessionAsRead(String partnerId) {
    final index = _sessions.indexWhere((s) => s.partnerId == partnerId);
    if (index != -1 && _sessions[index].unreadCount > 0) {
      _sessions[index] = _sessions[index].copyWith(unreadCount: 0);
      notifyListeners();
    }
  }

  void setTypingStatus(String partnerId, bool isTyping) {
    _typingTimers[partnerId]?.cancel();
    
    _typingStatus[partnerId] = isTyping;
    
    if (isTyping || _typingStatus.containsKey(partnerId)) {
      notifyListeners();
    }

    if (isTyping) {
      _typingTimers[partnerId] = Timer(const Duration(seconds: 3), () {
        if (_typingStatus[partnerId] == true) {
          _typingStatus.remove(partnerId);
          _typingTimers.remove(partnerId);
          notifyListeners();
        }
      });
    } else {
      _typingStatus.remove(partnerId);
      _typingTimers.remove(partnerId);
    }
  }

  Future<List<Message>> searchMessages(String query) async {
    if (_currentUserId == null) return [];
    return _chatRepository.searchMessages(_currentUserId!, query);
  }

  @override
void dispose() {
  // Close the message stream controller
  _messageStreamController.close();
  
  // Clean up typing timers
  for (var timer in _typingTimers.values) {
    timer.cancel();
  }
  _typingTimers.clear();
  
  // Dispose repository
  _chatRepository.dispose();
  
  super.dispose();
}

void disposeChatSession(String chatId) {
  // Clear session-specific data
  _typingStatus.remove(chatId);
  _typingTimers[chatId]?.cancel();
  _typingTimers.remove(chatId);
  
  // Notify repository to clean up socket connection
  _chatRepository.disposeChat(chatId);
}
}
