import 'package:flutter/material.dart';
import 'package:missingpersonapp/common/models/missing_person.dart';
import 'package:missingpersonapp/features/Notifications/models/notification_model.dart';
import 'package:missingpersonapp/features/Notifications/services/fetch-notification.dart';
import 'package:provider/provider.dart';
import 'package:missingpersonapp/common/screens/missing_person_detail1.dart';
import 'package:missingpersonapp/features/Notifications/provider/missingcase-provider.dart';
import 'package:intl/intl.dart';

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
                return Container(
                  margin: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10), // Border radius
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.1), // Shadow color
                        spreadRadius: 1, // Spread radius
                        blurRadius: 2, // Blur radius
                        offset: Offset(0, 1), // Offset
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text(
                      notification.title,
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: Text(
                      DateFormat('MMMM d, y h:mm a').format(notification.createdAt.toLocal()),
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotificationDetailPage(
                            notification: notification,
                          ),
                        ),
                      );
                    },
                  ),
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
            Text(notification.body.substring(0, notification.body.length - 23)),
            
            SizedBox(height: 8),
            Text("Received on: ${DateFormat('MMMM d, y h:mm a').format(notification.createdAt.toLocal())}"),
            SizedBox(height: 16),
            if (notification.title.toString() == "New Missing Person")
              ElevatedButton.icon(
                icon: Icon(Icons.person_search),
                label: Text('View Missing Person Details'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangeNotifierProvider(
                        create: (_) => CaseProvider()..fetchCaseById(notification.caseID),
                        child: Consumer<CaseProvider>(
                          builder: (context, provider, child) {
                            if (provider.isLoading) {
                              return Scaffold(
                                appBar: AppBar(
                                  title: Text('Loading...'),
                                ),
                                body: Center(child: CircularProgressIndicator()),
                              );
                            }

                            if (provider.errorMessage.isNotEmpty) {
                              return Scaffold(
                                appBar: AppBar(
                                  title: Text('Error'),
                                ),
                                body: Center(child: Text(provider.errorMessage)),
                              );
                            }

                            if (provider.theCase == null) {
                              return Scaffold(
                                appBar: AppBar(
                                  title: Text('No Data'),
                                ),
                                body: Center(child: Text('No missing person details found')),
                              );
                            }

                            final MissingPerson theCase = provider.theCase!;
                            print(theCase);
                            return MissingPersonDetails(
                              missingPerson: theCase,
                              header: "Missing Person Notification",
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
