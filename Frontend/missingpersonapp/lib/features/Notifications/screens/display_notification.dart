import 'package:flutter/material.dart';
import 'package:missingpersonapp/common/models/missing_person.dart';
import 'package:missingpersonapp/features/Notifications/models/notification_model.dart';
import 'package:missingpersonapp/features/Notifications/services/fetch-notification.dart';
import 'package:provider/provider.dart';
import 'package:missingpersonapp/common/screens/missing_person_detail1.dart';
import 'package:missingpersonapp/features/Notifications/provider/missingcase-provider.dart';
import 'package:intl/intl.dart';
import 'dart:ui';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade900, Colors.grey.shade800],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<NotificationModel>>(
          future: futureNotifications,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No notifications found'));
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  NotificationModel notification = snapshot.data![index];
                  return Container(
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(
                        notification.title,
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: Text(
                        DateFormat('MMMM d, y h:mm a').format(notification.createdAt.toLocal()),
                        style: const TextStyle(color: Colors.white),
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
      ),
    );
  }
}

class NotificationDetailPage extends StatelessWidget {
  final NotificationModel notification;

  const NotificationDetailPage({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade900, Colors.grey.shade800],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 100,
              flexibleSpace: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 180, sigmaY: 80),
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                  ),
                ),
              ),
              title: const Text('Notification Detail', style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.transparent,
              pinned: true,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification.body.substring(0, notification.body.length - 23),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Received on: ${DateFormat('MMMM d, y h:mm a').format(notification.createdAt.toLocal())}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    if (notification.title.toString() == "New Missing Person")
                      ElevatedButton.icon(
                        icon: const Icon(Icons.person_search, color: Colors.white),
                        label: const Text('View Missing Person Details', style: TextStyle(color: Colors.white)),
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
                                          title: const Text('Loading...'),
                                        ),
                                        body: const Center(child: CircularProgressIndicator()),
                                      );
                                    }

                                    if (provider.errorMessage.isNotEmpty) {
                                      return Scaffold(
                                        appBar: AppBar(
                                          title: const Text('Error'),
                                        ),
                                        body: Center(child: Text(provider.errorMessage)),
                                      );
                                    }

                                    if (provider.theCase == null) {
                                      return Scaffold(
                                        appBar: AppBar(
                                          title: const Text('No Data'),
                                        ),
                                        body: const Center(child: Text('No missing person details found')),
                                      );
                                    }

                                    final MissingPerson theCase = provider.theCase!;
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
            ),
          ],
        ),
      ),
    );
  }
}
