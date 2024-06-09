import 'package:flutter/material.dart';

class ChatItem extends StatelessWidget {
  final String username;
  final String messagePreview;
  final String time;
  final bool isRead;
  final bool isChatWithSelf;
  final VoidCallback onTap;

  const ChatItem({
    Key? key,
    required this.username,
    required this.messagePreview,
    required this.time,
    required this.isRead,
    required this.isChatWithSelf,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isChatWithSelf ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Replace with your image URL
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    messagePreview,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 10),
            if (!isChatWithSelf)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    time,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 4),
                  Icon(
                    isRead ? Icons.check_circle : Icons.check_circle_outline,
                    color: isRead ? Colors.blue : Colors.grey,
                    size: 16,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
