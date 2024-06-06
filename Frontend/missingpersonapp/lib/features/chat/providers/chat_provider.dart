import 'package:flutter/material.dart';
import 'package:missingpersonapp/common/models/chat_session.dart';
import 'package:missingpersonapp/features/chat/services/chat_services.dart';

class ChatProvider extends ChangeNotifier {
  List<ChatSession> _chatSessions = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<ChatSession> get chatSessions => _chatSessions;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchChatSessions(String userId) async {
    _isLoading = true;
    _errorMessage = '';

    try {
      _chatSessions = await fetchChatSessionsFromApi(userId);
      print(_chatSessions);
    } catch (e) {
      _errorMessage = 'Failed to fetch chat sessions';
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
