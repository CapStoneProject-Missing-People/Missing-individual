import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:missingpersonapp/common/utils/app_colors.dart';
import 'package:missingpersonapp/features/authentication/provider/user_provider.dart';
import 'package:missingpersonapp/features/chat/models/message.dart';
import 'package:missingpersonapp/features/chat/providers/chat_provider.dart';
import 'package:missingpersonapp/features/chat/providers/message_provider.dart';
import 'package:missingpersonapp/features/chat/widgets/message_bubble.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String? receiverName;
  final String? receiverImageUrl;

  const ChatScreen({
    super.key,
    required this.receiverId,
    this.receiverName,
    this.receiverImageUrl,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();
  bool _isTyping = false;
  bool _isSearchOpen = false;
  String _searchQuery = '';
  Timer? _typingTimer;
  Timer? _readReceiptTimer;
  final Connectivity _connectivity = Connectivity();
  final Set<String> _unreadMessages = {};
  int _currentSearchIndex = -1;
  final List<int> _searchMatches = [];
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  StreamSubscription<Message>? _messageSubscription;
  bool _isAtBottom = true;
  bool _showScrollToBottom = false;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen((result) {
        if (result != ConnectivityResult.none) {
          _initializeChat();
        }
      });
    });
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    context.read<ChatProvider>().disposeChatSession(widget.receiverId);
    _messageController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    _typingTimer?.cancel();
    _readReceiptTimer?.cancel();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  void _handleScroll() {
    final position = _scrollController.position;
    setState(() {
      _isAtBottom = position.pixels == position.minScrollExtent;
      _showScrollToBottom = !_isAtBottom && position.pixels < position.maxScrollExtent - 100;
    });

    // Load more messages when near the top
    if (position.pixels >= position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        context.read<MessageProvider>().hasMore) {
      _loadMoreMessages();
    }
  }

  Future<void> _initializeChat() async {
    final userId = context.read<UserProvider>().user.id;
    final messageProvider = context.read<MessageProvider>();
    final chatProvider = context.read<ChatProvider>();
    
    if (!messageProvider.isInitialized || messageProvider.currentChatId != widget.receiverId) {
      await messageProvider.initialize(widget.receiverId, userId);
    }

    // Initialize socket listeners if not already done
    if (!chatProvider.isConnected) {
      _messageSubscription = chatProvider.messageStream.listen((message) {
        if (message.receiverId == widget.receiverId || 
            message.senderId == widget.receiverId) {
          messageProvider.handleNewMessage(message);
          _scrollToBottomIfNeeded();
        }
      });
    }

    _setupReadReceipts();
    _scrollToBottom();
  }

  Future<void> _loadMoreMessages() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    try {
      await context.read<MessageProvider>().loadMoreMessages();
    } finally {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  void _setupReadReceipts() {
    _readReceiptTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (_unreadMessages.isNotEmpty) {
        for (final messageId in _unreadMessages) {
          context.read<MessageProvider>().markAsRead(messageId);
        }
        _unreadMessages.clear();
      }
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _scrollToBottomIfNeeded() {
    if (_isAtBottom && _scrollController.hasClients) {
      _scrollToBottom();
    }
  }

  Widget _buildScrollToBottomButton() {
    return AnimatedOpacity(
      opacity: _showScrollToBottom ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: FloatingActionButton(
        mini: true,
        backgroundColor: AppColors.primary,
        onPressed: _scrollToBottom,
        child: const Icon(Icons.arrow_downward, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBar(List<Message> messages) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.darkAppBar,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              setState(() {
                _isSearchOpen = false;
                _searchQuery = '';
                _searchMatches.clear();
                _currentSearchIndex = -1;
              });
            },
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search in conversation',
                hintStyle: const TextStyle(color: Colors.white54),
                border: InputBorder.none,
              ),
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
                _findSearchMatches(messages);
              },
            ),
          ),
          if (_searchQuery.isNotEmpty && _searchMatches.isNotEmpty) ...[
            Text(
              '${_currentSearchIndex + 1}/${_searchMatches.length}',
              style: const TextStyle(color: Colors.white54),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.arrow_upward, color: Colors.white),
              onPressed: () => _navigateSearch(false, messages),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_downward, color: Colors.white),
              onPressed: () => _navigateSearch(true, messages),
            ),
          ],
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              setState(() {
                _searchQuery = '';
                _searchController.clear();
                _searchMatches.clear();
                _currentSearchIndex = -1;
              });
            },
          ),
        ],
      ),
    );
  }

  void _findSearchMatches(List<Message> messages) {
    _searchMatches.clear();
    if (_searchQuery.isEmpty) {
      setState(() {
        _currentSearchIndex = -1;
      });
      return;
    }

    for (int i = 0; i < messages.length; i++) {
      if (messages[i].content.toLowerCase().contains(_searchQuery.toLowerCase())) {
        _searchMatches.add(i);
      }
    }

    setState(() {
      _currentSearchIndex = _searchMatches.isNotEmpty ? 0 : -1;
    });

    if (_currentSearchIndex != -1) {
      _scrollToMessage(_searchMatches[_currentSearchIndex], messages);
    }
  }

  void _scrollToMessage(int index, List<Message> messages) {
    if (_scrollController.hasClients && messages.isNotEmpty) {
      final reversedIndex = messages.length - 1 - index;
      final position = _scrollController.position.maxScrollExtent * 
          (reversedIndex / messages.length);
      _scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _navigateSearch(bool forward, List<Message> messages) {
    if (_searchMatches.isEmpty) return;

    setState(() {
      if (forward) {
        _currentSearchIndex = (_currentSearchIndex + 1) % _searchMatches.length;
      } else {
        _currentSearchIndex = (_currentSearchIndex - 1) % _searchMatches.length;
      }
    });

    _scrollToMessage(_searchMatches[_currentSearchIndex], messages);
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final userId = context.read<UserProvider>().user.id;
    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: userId,
      receiverId: widget.receiverId,
      content: text,
      timestamp: DateTime.now(),
    );

    try {
      await context.read<MessageProvider>().sendMessage(message);
      _messageController.clear();
      _handleTyping(false);
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: ${e.toString()}')),
        );
      }
    }
  }

  void _handleTyping(bool isTyping) {
    _typingTimer?.cancel();
    if (isTyping) {
      _typingTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) setState(() => _isTyping = false);
      });
    }
    if (mounted) setState(() => _isTyping = isTyping);
    
    // Notify other user
    context.read<ChatProvider>().setTypingStatus(
      widget.receiverId,
      isTyping,
    );
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (pickedFile == null) return;

      final file = File(pickedFile.path);
      final size = await file.length();

      if (size > 2 * 1024 * 1024) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image must be less than 2MB')),
        );
        return;
      }

      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);

      final message = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: context.read<UserProvider>().user.id,
        receiverId: widget.receiverId,
        content: '',
        imageBase64: base64Image,
        timestamp: DateTime.now(),
        status: MessageStatus.sending,
      );

      await context.read<MessageProvider>().sendMessage(message);
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send image: ${e.toString()}')),
      );
    }
  }

  void _showFullScreenImage(String base64Image) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.memory(
                base64Decode(base64Image),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageList(MessageProvider provider, String currentUserId) {
    final messages = provider.messages;

    if (provider.isLoading && messages.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    if (provider.error != null && messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(provider.error!, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              onPressed: _initializeChat,
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        ListView.builder(
          controller: _scrollController,
          reverse: true,
          padding: const EdgeInsets.only(bottom: 80, top: 8),
          itemCount: messages.length + (_isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == messages.length && _isLoadingMore) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              );
            }

            final messageIndex = messages.length - 1 - index;
            final message = messages[messageIndex];
            final isMe = message.senderId == currentUserId;
            final isSearchMatch = _searchQuery.isNotEmpty &&
                message.content.toLowerCase().contains(_searchQuery.toLowerCase());

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_isMessageVisible(messageIndex, messages.length)) {
                _onMessageViewed(message);
              }
            });

            return Container(
              decoration: BoxDecoration(
                color: isSearchMatch ? AppColors.primary.withOpacity(0.2) : null,
              ),
              child: MessageBubble(
                key: ValueKey(message.id),  // Ensure proper animations
                message: message,
                isMe: isMe,
                onImageTap: () => message.imageBase64 != null
                    ? _showFullScreenImage(message.imageBase64!)
                    : null,
                onLongPress: () => _showMessageOptions(context, message),
              ),
            );
          },
        ),
        Positioned(
          bottom: 80,
          right: 16,
          child: _buildScrollToBottomButton(),
        ),
      ],
    );
  }

  bool _isMessageVisible(int index, int totalMessages) {
    if (!_scrollController.hasClients) return false;
    final itemPosition = (totalMessages - 1 - index) * 100.0;
    final scrollPosition = _scrollController.position.pixels;
    final viewportHeight = _scrollController.position.viewportDimension;
    return itemPosition >= scrollPosition && 
           itemPosition <= scrollPosition + viewportHeight;
  }

  void _onMessageViewed(Message message) {
    if (!message.read && 
        message.receiverId == context.read<UserProvider>().user.id &&
        message.status != MessageStatus.read) {
      _unreadMessages.add(message.id);
    }
  }

  void _showMessageOptions(BuildContext context, Message message) {
    final isMe = message.senderId == context.read<UserProvider>().user.id;
    final isUnread = !message.read && 
                    message.receiverId == context.read<UserProvider>().user.id;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkAppBar,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isUnread)
              ListTile(
                leading: const Icon(Icons.mark_as_unread, color: Colors.white),
                title: const Text('Mark as unread', 
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  context.read<MessageProvider>().markAsUnread(message.id);
                  Navigator.pop(context);
                },
              ),
            if (isMe)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteDialog(context, message);
                },
              ),
            if (message.imageBase64 != null)
              ListTile(
                leading: const Icon(Icons.image, color: Colors.white),
                title: const Text('View Image', 
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _showFullScreenImage(message.imageBase64!);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Message message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkAppBar,
        title: const Text('Delete Message', 
            style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to delete this message?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            child: const Text('Cancel', 
                style: TextStyle(color: Colors.white70)),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () {
              context.read<MessageProvider>().deleteMessage(message.id);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.darkAppBar,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.image, color: Colors.white),
            onPressed: _pickImage,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      focusNode: _messageFocusNode,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: const TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (text) {
                        if (text.isNotEmpty && !_isTyping) {
                          _handleTyping(true);
                        } else if (text.isEmpty && _isTyping) {
                          _handleTyping(false);
                        }
                      },
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            mini: true,
            backgroundColor: AppColors.primary,
            onPressed: _sendMessage,
            child: const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messageProvider = context.watch<MessageProvider>();
    final chatProvider = context.watch<ChatProvider>();
    final currentUserId = context.read<UserProvider>().user.id;

    if (!messageProvider.isInitialized && !messageProvider.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeChat();
      });
    }

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: _isSearchOpen
            ? null
            : Row(
                children: [
                  if (widget.receiverImageUrl != null)
                    CircleAvatar(
                      backgroundImage: NetworkImage(widget.receiverImageUrl!),
                      radius: 16,
                    )
                  else
                    const CircleAvatar(
                      radius: 16,
                      child: Icon(Icons.person, size: 16),
                    ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.receiverName ?? 'Chat',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      if (chatProvider.isTyping(widget.receiverId))
                        const Text(
                          'typing...',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
        backgroundColor: AppColors.darkAppBar,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isSearchOpen)
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {
                setState(() {
                  _isSearchOpen = true;
                  _messageFocusNode.unfocus();
                });
              },
            ),
        ],
      ),
      body: Column(
        children: [
          if (_isSearchOpen) _buildSearchBar(messageProvider.messages),
          StreamBuilder<ConnectivityResult>(
            stream: _connectivity.onConnectivityChanged.asyncExpand((results) => Stream.fromIterable(results)),
            builder: (context, snapshot) {
              final isConnected = snapshot.data != ConnectivityResult.none;
              if (snapshot.hasData && !isConnected) {
                return Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.orange,
                  child: const Text(
                    'Offline - messages will send when connected',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.darkAppBar.withOpacity(0.3),
                    AppColors.darkBackground,
                  ],
                ),
              ),
              child: messageProvider.isInitialized
                  ? _buildMessageList(messageProvider, currentUserId)
                  : const Center(
                      child: CircularProgressIndicator(
                        valueColor: 
                            AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }
}
