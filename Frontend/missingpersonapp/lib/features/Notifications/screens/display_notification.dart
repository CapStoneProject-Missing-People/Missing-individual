import 'package:flutter/material.dart';
import 'package:missingpersonapp/features/Notifications/models/notification_model.dart';
import 'package:missingpersonapp/features/Notifications/services/fetch-notification.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late Future<List<NotificationModel>> futureNotifications;

  @override
  void initState() {
    super.initState();
    futureNotifications = NotificationService().fetchNotifications();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: FutureBuilder<List<NotificationModel>>(
        future: futureNotifications,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No notifications found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                NotificationModel notification = snapshot.data![index];
                return ListTile(
                  title: Text(notification.title),
                  subtitle: Text(notification.body),
                  trailing: Text(
                    notification.createdAt.toLocal().toString(),
                    style: TextStyle(color: Colors.grey),
                  ),
                  onTap: () {
                    // Handle notification tap
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationDetailPage(
                          notification: notification,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

class NotificationDetailPage extends StatelessWidget {
  final NotificationModel notification;

  NotificationDetailPage({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(notification.body),
            SizedBox(height: 16),
            Text('Case ID: ${notification.caseID}'),
            SizedBox(height: 8),
            Text('Received on: ${notification.createdAt.toLocal()}'),
          ],
        ),
      ),
    );
  }
}