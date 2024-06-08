import 'package:flutter/material.dart';
import 'package:missingpersonapp/common/models/chat_session.dart';
import 'package:missingpersonapp/features/chat/services/chat_services.dart';

class ChatProvider extends ChangeNotifier {
  List<ChatSession> _chatSessions = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _userId = '';

  List<ChatSession> get chatSessions => _chatSessions;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchChatSessions(String userId) async {
    if (_userId == userId && _chatSessions.isNotEmpty) {
      // If the user ID hasn't changed and we already have sessions, avoid refetching.
      return;
    }

    _isLoading = true;
    _errorMessage = '';
    _userId = userId;
    notifyListeners();

    try {
      _chatSessions = await fetchChatSessionsFromApi(userId);
      _errorMessage = ''; // Clear error message if fetch is successful
    } catch (e) {
      _errorMessage = 'Failed to fetch chat sessions: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Group chat sessions by user
  Map<String, ChatSession> get groupedChatSessions {
    Map<String, ChatSession> groupedSessions = {};

    for (var session in _chatSessions) {
      String otherUserId = session.userId1 == _userId ? session.userId2 : session.userId1;

      if (!groupedSessions.containsKey(otherUserId)) {
        groupedSessions[otherUserId] = session;
      } else {
        if (session.time.isAfter(groupedSessions[otherUserId]!.time)) {
          groupedSessions[otherUserId] = session;
        }
      }
    }

    return groupedSessions;
  }
}
