import 'package:flutter/material.dart';
import 'package:missingpersonapp/features/Notifications/models/notification_model.dart';

class NotificationProvider with ChangeNotifier {
  int _unreadCount = 0;

  int get unreadCount => _unreadCount;

  Future<void> fetchNotifications() async {
    // Simulate fetching notifications and counting unread ones
    // Replace this with your actual logic
    _unreadCount = await _getUnreadNotificationsCount();
    notifyListeners();
  }

  Future<int> _getUnreadNotificationsCount() async {
    // Replace with the actual API call to get unread notifications count
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    return 5; // Return the fetched unread notifications count
  }

  void markAllAsRead() {
    _unreadCount = 0;
    notifyListeners();
    // Implement API call to mark all notifications as read
  }

  void markAsRead(NotificationModel notification) {
    // Implement logic to mark the notification as read
    // This should ideally make an API call to update the read status in the backend
    _unreadCount--;
    notifyListeners();
  }
}
