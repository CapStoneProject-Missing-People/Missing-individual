import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:missingpersonapp/features/chat/models/chat_session.dart';
import 'package:missingpersonapp/features/chat/models/message.dart';
import 'package:missingpersonapp/features/authentication/utils/constants.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ChatServices {
  static final String _baseUrl = Constants.postUri;
  static const Duration _timeout = Duration(seconds: 15);
  static const Duration _cacheDuration = Duration(minutes: 5);
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Connectivity _connectivity = Connectivity();
  final Map<String, Tuple2<List<ChatSession>, DateTime>> _sessionCache = {};
  final Map<String, Tuple2<List<Message>, DateTime>> _messageCache = {};

  Future<Map<String, String>> _getHeaders() async {
    final token = await _secureStorage.read(key: Constants.accessTokenKey);
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<bool> _checkConnection() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<List<ChatSession>> fetchChatSessions(String userId, {bool forceRefresh = false}) async {
    try {
      // Check cache first
      if (!forceRefresh && 
          _sessionCache.containsKey(userId) && 
          DateTime.now().difference(_sessionCache[userId]!.item2) < _cacheDuration) {
        return _sessionCache[userId]!.item1;
      }

      if (!await _checkConnection()) {
        throw Exception('No internet connection');
      }

      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse('$_baseUrl/api/chat/sessions/$userId'),
            headers: headers,
          )
          .timeout(_timeout);

      final sessions = _handleResponse<List<ChatSession>>(
        response,
        parse: (data) {
          if (data['data'] == null) return [];
          return (data['data'] as List).map((json) {
            try {
              return ChatSession.fromJson(json);
            } catch (e) {
              print('Error parsing session: $e\nJSON: $json');
              return ChatSession(
                partnerId: json['partnerId']?.toString() ?? '',
                partnerName: json['partnerName']?.toString() ?? 'Error',
                lastMessage: json['lastMessage']?.toString() ?? '',
                timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
                isRead: json['isRead'] ?? false,
                unreadCount: json['unreadCount'] ?? 0,
                imageBase64: json['imageBase64']?.toString(),
              );
            }
          }).toList();
        },
        errorMessage: 'Failed to load chat sessions',
      );

      // Update cache
      _sessionCache[userId] = Tuple2(sessions, DateTime.now());
      return sessions;
    } catch (e) {
      // Return cached data if available
      if (_sessionCache.containsKey(userId)) {
        return _sessionCache[userId]!.item1;
      }
      throw _handleError(e, 'fetching chat sessions');
    }
  }

  Future<List<Message>> fetchMessages(
    String receiverId, {
    int limit = 50,
    int offset = 0,
    bool forceRefresh = false,
  }) async {
    final cacheKey = '$receiverId-$limit-$offset';
    
    try {
      // Check cache first
      if (!forceRefresh && 
          _messageCache.containsKey(cacheKey) && 
          DateTime.now().difference(_messageCache[cacheKey]!.item2) < _cacheDuration) {
        return _messageCache[cacheKey]!.item1;
      }

      if (!await _checkConnection()) {
        throw Exception('No internet connection');
      }

      final headers = await _getHeaders();
      final uri = Uri.parse(
        '${Constants.postUri}/api/chat/$receiverId?limit=$limit&offset=$offset',
      );

      final response = await http.get(uri, headers: headers).timeout(_timeout);

      if (response.statusCode == 401) {
        throw Exception('Session expired - please login again');
      }

      final messages = _handleResponse<List<Message>>(
        response,
        parse: (data) => (data['data'] as List)
            .map((json) {
              try {
                return Message.fromJson(json);
              } catch (e) {
                print('Error parsing message $e\nJSON: $json');
                return Message(
                  id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  senderId: json['senderId']?.toString() ?? '',
                  receiverId: json['receiverId']?.toString() ?? '',
                  content: json['content']?.toString() ?? 'Error loading message',
                  timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
                  status: _parseStatus(json['status']?.toString() ?? 'sent'),
                  read: json['read'] ?? false,
                  imageBase64: json['imageBase64']?.toString(),
                );
              }
            })
            .toList(),
        errorMessage: 'Failed to load messages',
      );

      // Update cache
      _messageCache[cacheKey] = Tuple2(messages, DateTime.now());
      return messages;
    } catch (e) {
      // Return cached data if available
      if (_messageCache.containsKey(cacheKey)) {
        return _messageCache[cacheKey]!.item1;
      }
      throw _handleError(e, 'loading messages');
    }
  }

  Future<Message> sendMessage(Message message) async {
    try {
      if (!await _checkConnection()) {
        throw Exception('No internet connection - message will send when online');
      }

      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/chat'),
            headers: headers,
            body: jsonEncode(message.toJson()),
          )
          .timeout(_timeout);

      // Clear relevant caches
      _messageCache.removeWhere((key, _) => key.startsWith(message.receiverId));
      _sessionCache.remove(message.senderId);
      _sessionCache.remove(message.receiverId);

      return _handleResponse<Message>(
        response,
        parse: (data) => Message.fromJson(data['data']),
        errorMessage: 'Failed to send message',
      );
    } catch (e) {
      throw _handleError(e, 'sending message');
    }
  }

  Future<void> deleteMessage(String messageId, {String? receiverId, String? senderId}) async {
    try {
      if (!await _checkConnection()) {
        throw Exception('No internet connection');
      }

      final headers = await _getHeaders();
      final response = await http
          .delete(
            Uri.parse('$_baseUrl/api/chat/$messageId'),
            headers: headers,
          )
          .timeout(_timeout);

      // Clear relevant caches
      if (receiverId != null) {
        _messageCache.removeWhere((key, _) => key.startsWith(receiverId));
        _sessionCache.remove(receiverId);
      }
      if (senderId != null) {
        _sessionCache.remove(senderId);
      }

      _handleResponse<void>(
        response,
        errorMessage: 'Failed to delete message',
      );
    } catch (e) {
      throw _handleError(e, 'deleting message');
    }
  }

  Future<void> updateMessageStatus(
    String messageId,
    MessageStatus status, {
    String? receiverId,
  }) async {
    try {
      if (!await _checkConnection()) {
        throw Exception('No internet connection');
      }

      final headers = await _getHeaders();
      final response = await http
          .patch(
            Uri.parse('$_baseUrl/api/chat/$messageId/status'),
            headers: headers,
            body: jsonEncode({'status': _statusToString(status)}),
          )
          .timeout(_timeout);

      // Clear cache if needed
      if (receiverId != null) {
        _sessionCache.remove(receiverId);
      }

      _handleResponse<void>(
        response,
        errorMessage: 'Failed to update message status',
      );
    } catch (e) {
      throw _handleError(e, 'updating message status');
    }
  }

  Future<List<Message>> searchMessages({required String userId, required String query}) async {
    try {
      if (!await _checkConnection()) {
        throw Exception('No internet connection');
      }

      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse('$_baseUrl/api/chat/search?userId=$userId&query=$query'),
            headers: headers,
          )
          .timeout(_timeout);

      return _handleResponse<List<Message>>(
        response,
        parse: (data) => (data['data'] as List)
            .map((json) => Message.fromJson(json))
            .toList(),
        errorMessage: 'Failed to search messages',
      );
    } catch (e) {
      throw _handleError(e, 'searching messages');
    }
  }

  static MessageStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return MessageStatus.delivered;
      case 'read':
        return MessageStatus.read;
      default:
        return MessageStatus.sent;
    }
  }

  static String _statusToString(MessageStatus status) {
    switch (status) {
      case MessageStatus.delivered:
        return 'delivered';
      case MessageStatus.read:
        return 'read';
      default:
        return 'sent';
    }
  }

  static T _handleResponse<T>(
    http.Response response, {
    T Function(dynamic)? parse,
    required String errorMessage,
  }) {
    try {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (parse != null) {
          return parse(body);
        }
        return body as T;
      } else {
        throw Exception(body['message']?.toString() ?? 
                      body['error']?.toString() ?? 
                      errorMessage);
      }
    } catch (e) {
      throw Exception('Failed to parse server response');
    }
  }

  static Exception _handleError(dynamic error, String operation) {
    if (error is http.ClientException) {
      return Exception('Network error while $operation. Please check your connection.');
    } else if (error is TimeoutException) {
      return Exception('Request timed out while $operation. Please try again.');
    } else if (error is FormatException) {
      return Exception('Data format error while $operation. Please contact support.');
    }
    return Exception('$error');
  }
}

// Simple tuple implementation
class Tuple2<T1, T2> {
  final T1 item1;
  final T2 item2;

  Tuple2(this.item1, this.item2);
}
