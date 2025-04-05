import 'package:flutter/material.dart';
import 'package:missingpersonapp/common/utils/app_colors.dart';
import 'package:missingpersonapp/features/chat/models/chat_session.dart';
import 'package:missingpersonapp/features/chat/screens/chat_screen.dart';
import 'package:missingpersonapp/features/chat/widgets/chat_Item.dart';
import 'package:provider/provider.dart';
import 'package:missingpersonapp/features/chat/providers/chat_provider.dart';

class ChatListScreen extends StatefulWidget {
  final String userId;
  const ChatListScreen({super.key, required this.userId});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final FocusNode _searchFocusNode;
  String _searchQuery = '';
  bool _isSearching = false;
  bool _showSearchResults = false;

  // Update initState in ChatListScreen
  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChatSessions();
      context.read<ChatProvider>().initializeSocketListeners(
            userId: widget.userId,
            onNewMessage: (_) => _loadChatSessions(),
          );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadChatSessions() async {
    await context.read<ChatProvider>().loadSessions(widget.userId);
  }

  List<ChatSession> _filterChatSessions(List<ChatSession> sessions) {
    if (_searchQuery.isEmpty) return sessions;
    final query = _searchQuery.toLowerCase();
    return sessions.where((session) {
      return session.partnerName.toLowerCase().contains(query) ||
          session.lastMessage.toLowerCase().contains(query);
    }).toList();
  }

  void _handleSearch() {
    if (_searchController.text.isNotEmpty) {
      setState(() {
        _searchQuery = _searchController.text;
        _showSearchResults = true;
      });
    } else {
      setState(() {
        _searchQuery = '';
        _showSearchResults = false;
      });
    }
  }

  void _exitSearch() {
    setState(() {
      _isSearching = false;
      _showSearchResults = false;
      _searchQuery = '';
      _searchController.clear();
      _searchFocusNode.unfocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final filteredSessions = _filterChatSessions(chatProvider.sessions);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: _isSearching ? _buildSearchAppBar() : _buildNormalAppBar(),
      body: Column(
        children: [
          if (_showSearchResults && _searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  Text(
                    '${filteredSessions.length} ${filteredSessions.length == 1 ? 'chat' : 'chats'} found',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _buildChatList(chatProvider, filteredSessions),
          ),
        ],
      ),
      floatingActionButton: _isSearching
          ? null
          : FloatingActionButton(
              onPressed: () => _showNewChatDialog(context),
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.message, color: Colors.white),
            ),
    );
  }

  AppBar _buildNormalAppBar() {
    return AppBar(
      title: const Text(
        'Messages',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: AppColors.darkAppBar,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () {
            setState(() => _isSearching = true);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _searchFocusNode.requestFocus();
            });
          },
        ),
      ],
    );
  }

  AppBar _buildSearchAppBar() {
    return AppBar(
      backgroundColor: AppColors.darkAppBar,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: _exitSearch,
      ),
      title: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        autofocus: true,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Search messages or users...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          border: InputBorder.none,
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close, color: Colors.white.withOpacity(0.7)),
                  onPressed: () {
                    _searchController.clear();
                    _handleSearch();
                  },
                )
              : null,
        ),
        onChanged: (value) => _handleSearch(),
      ),
    );
  }

  Widget _buildChatList(ChatProvider provider, List<ChatSession> allSessions) {
    // Filter sessions based on search query
    final displaySessions = _showSearchResults && _searchQuery.isNotEmpty
        ? allSessions.where((session) {
            final query = _searchQuery.toLowerCase();
            return session.partnerName.toLowerCase().contains(query) ||
                session.lastMessage.toLowerCase().contains(query);
          }).toList()
        : allSessions;

    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              provider.error!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: _loadChatSessions,
              child: const Text(
                'Try Again',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    if (displaySessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.forum_outlined,
              size: 64,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? 'No conversations yet'
                  : 'No matches found',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            if (_searchQuery.isEmpty)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () => _showNewChatDialog(context),
                child: const Text(
                  'Start New Chat',
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: displaySessions.length,
      itemBuilder: (context, index) {
        final session = displaySessions[index];
        return _buildChatListItem(session);
      },
    );
  }

  Widget _buildChatListItem(ChatSession session) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.darkAppBar.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.2),
          child: Text(
            session.partnerName.isNotEmpty
                ? session.partnerName[0].toUpperCase()
                : '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          session.partnerName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          session.lastMessage,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              session.formattedTime,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
            if (session.unreadCount > 0)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  session.unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        onTap: () => _navigateToChatScreen(context, session),
      ),
    );
  }

  void _navigateToChatScreen(BuildContext context, ChatSession session) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          receiverId: session.partnerId,
          receiverName: session.partnerName,
        ),
      ),
    ).then((_) => _loadChatSessions());
  }

  void _showNewChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.darkAppBar,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'New Chat',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Feature coming soon!',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'OK',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
