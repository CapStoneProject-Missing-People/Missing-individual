import 'package:flutter/material.dart';
import 'package:missingpersonapp/features/chat/models/message.dart';

class MessageProvider with ChangeNotifier {
  List<Message> _messages = [];

  List<Message> get messages => _messages;

  void setMessages(List<Message> messages) {
    _messages = messages;
    notifyListeners();
  }

  void addMessage(Message message) {
    _messages.add(message);
    notifyListeners();
  }

  void removeMessage(String id) {
    _messages.removeWhere((msg) => msg.id == id);
    notifyListeners();
  }
}
