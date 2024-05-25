
import 'package:flutter/material.dart';

class ShowPushNotificationTap extends StatelessWidget {
  final String caseId;

  const ShowPushNotificationTap({Key? key, required this.caseId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification')),
      body: Center(
          child: caseId.length == 0
              ? Text("No notification found")
              : Text('Case ID: $caseId')), // Example display
    );
  }
}


// import 'dart:convert';
// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:missingpersonapp/common/models/missing_person.dart';
// import 'package:missingpersonapp/features/home/utils/missingPeopleDisplayCard.dart';

// class NotificationPage extends StatefulWidget {
//   final String caseId;

//   const NotificationPage({super.key, required this.caseId});

//   @override
//   _NotificationPageState createState() => _NotificationPageState();
// }

// class _NotificationPageState extends State<NotificationPage> {
//   late Future<MissingPerson> futureMissingPerson;

//   get http => null;

//   @override
//   void initState() {
//     super.initState();
//     futureMissingPerson = fetchMissingPerson(widget.caseId);
//   }

//   Future<MissingPerson> fetchMissingPerson(String caseId) async {
//     final response = await http.get(Uri.parse(
//         '${Constants.postUri}/api/features/getSingle/$caseId'));

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       // Assuming the data from the response can be directly used to create a MissingPerson object
//       return MissingPerson.fromJson(data);
//     } else {
//       throw Exception('Failed to load missing person');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('New Missing Person Case')),
//       body: FutureBuilder<MissingPerson>(
//         future: futureMissingPerson,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (!snapshot.hasData) {
//             return Center(child: Text('Missing person not found'));
//           } else {
//             final missingPerson = snapshot.data!;
//             return MissingPeopleDisplay(missingPerson: missingPerson);
//           }
//         },
//       ),
//     );
//   }
// }
