import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:missingpersonapp/features/chat/models/message.dart';
import 'package:missingpersonapp/features/authentication/utils/constants.dart';

class SocketService {
  static final Map<String, io.Socket> _sockets = {};
  static final Map<String, void Function(Message)> _messageCallbacks = {};
  static final Map<String, void Function(String)> _deleteCallbacks = {};
  static final Map<String, void Function(String, bool)> _typingCallbacks = {};
  static final Map<String, void Function(String, String)> _statusCallbacks = {};
  static final Map<String, void Function(Message)> _globalMessageCallbacks = {};
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  io.Socket? _globalSocket;
  bool _isConnected = false;
  final StreamController<bool> _connectionController = StreamController<bool>.broadcast();

  Stream<bool> get connectionStream => _connectionController.stream;
  bool get isConnected => _isConnected;

  Future<io.Socket> _createSocket() async {
    final token = await _secureStorage.read(key: Constants.accessTokenKey);
    return io.io(
      Constants.wsUri,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(1000)
          .setTimeout(5000)
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .build(),
    );
  }

  Future<void> initializeGlobalSocket({
    required String userId,
    required void Function(Message) onNewMessage,
  }) async {
    try {
      if (_globalSocket != null && _globalSocket!.connected) return;

      _globalSocket = await _createSocket();
      _globalSocket!.connect();

      _globalSocket!.onConnect((_) {
        _isConnected = true;
        _connectionController.add(true);
        _globalSocket!.emit('registerUser', {'userId': userId});
      });

      _globalSocket!.on('newMessage', (data) {
        try {
          final message = Message.fromJson(data);
          onNewMessage(message);
          _globalMessageCallbacks.values.forEach((cb) => cb(message));
        } catch (e) {
          print('Error handling global message: $e');
        }
      });

      _globalSocket!.onDisconnect((_) {
        _isConnected = false;
        _connectionController.add(false);
        _globalSocket = null;
      });

      _globalSocket!.onError((err) {
        print('Socket error: $err');
        _isConnected = false;
        _connectionController.add(false);
      });

      // Add ping/pong for connection health
      _globalSocket!.on('ping', (_) => _globalSocket!.emit('pong'));
      _globalSocket!.on('pong', (_) => print('Connection healthy'));

    } catch (e) {
      print('Error initializing global socket: $e');
      rethrow;
    }
  }

  Future<void> initializeChatSocket({
    required String chatId,
    required String userId,
    required void Function(Message) onNewMessage,
    required void Function(String) onMessageDeleted,
    required void Function(String, bool) onTyping,
    required void Function(String, String) onStatusUpdate,
  }) async {
    try {
      if (_sockets.containsKey(chatId)) return;

      final socket = await _createSocket();
      socket.connect();

      socket.onConnect((_) {
        _isConnected = true;
        _connectionController.add(true);
        socket.emit('joinChat', {
          'userId': userId,
          'chatId': chatId,
        });

        socket.on('newMessage', (data) {
          try {
            if (data['chatId'] == chatId) {
              final message = Message.fromJson(data['message']);
              onNewMessage(message);
            }
          } catch (e) {
            print('Error handling new message: $e');
          }
        });

        socket.on('messageDeleted', (data) {
          try {
            if (data['chatId'] == chatId) {
              onMessageDeleted(data['messageId']);
            }
          } catch (e) {
            print('Error handling deleted message: $e');
          }
        });

        socket.on('typing', (data) {
          try {
            if (data['chatId'] == chatId) {
              onTyping(data['userId'], data['isTyping']);
            }
          } catch (e) {
            print('Error handling typing event: $e');
          }
        });

        socket.on('messageStatus', (data) {
          try {
            if (data['chatId'] == chatId) {
              onStatusUpdate(data['messageId'], data['status']);
            }
          } catch (e) {
            print('Error handling status update: $e');
          }
        });
      });

      socket.onDisconnect((_) {
        _isConnected = false;
        _connectionController.add(false);
        _cleanup(chatId);
      });
      
      socket.onError((err) {
        print('Socket error: $err');
        _isConnected = false;
        _connectionController.add(false);
      });

      _sockets[chatId] = socket;
      _messageCallbacks[chatId] = onNewMessage;
      _deleteCallbacks[chatId] = onMessageDeleted;
      _typingCallbacks[chatId] = onTyping;
      _statusCallbacks[chatId] = onStatusUpdate;
    } catch (e) {
      print('Error initializing chat socket: $e');
      rethrow;
    }
  }

  void sendMessage({
    required String chatId,
    required Message message,
  }) {
    _sockets[chatId]?.emit('sendMessage', {
      'chatId': chatId,
      'message': message.toJson(),
    });
  }

  void sendTyping({
    required String chatId,
    required String userId,
    required bool isTyping,
  }) {
    _sockets[chatId]?.emit('typing', {
      'chatId': chatId,
      'userId': userId,
      'isTyping': isTyping,
    });
  }

  void updateMessageStatus({
    required String chatId,
    required String messageId,
    required String status,
  }) {
    _sockets[chatId]?.emit('updateStatus', {
      'chatId': chatId,
      'messageId': messageId,
      'status': status,
    });
  }

  void _cleanup(String chatId) {
    _sockets[chatId]?.disconnect();
    _sockets.remove(chatId);
    _messageCallbacks.remove(chatId);
    _deleteCallbacks.remove(chatId);
    _typingCallbacks.remove(chatId);
    _statusCallbacks.remove(chatId);
  }


  void dispose() {
  _globalSocket?.disconnect();
  _globalSocket = null;
  
  // Clean up all chat sockets
  for (final socket in _sockets.values) {
    socket.disconnect();
  }
  _sockets.clear();
  
  _messageCallbacks.clear();
  _deleteCallbacks.clear();
  _typingCallbacks.clear();
  _statusCallbacks.clear();
  _connectionController.close();
}

void disposeChat(String chatId) {
  _cleanup(chatId);
  // Remove from active connections
  _sockets.remove(chatId)?.disconnect();
  _messageCallbacks.remove(chatId);
  _deleteCallbacks.remove(chatId);
  _typingCallbacks.remove(chatId);
  _statusCallbacks.remove(chatId);
}
}
