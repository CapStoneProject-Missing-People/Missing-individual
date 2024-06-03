import 'package:flutter/material.dart';
import 'package:missingpersonapp/common/models/missing_person.dart';
import 'package:missingpersonapp/common/screens/missing_person_detail1.dart';
import 'package:missingpersonapp/features/Notifications/provider/missingcase-provider.dart';
import 'package:provider/provider.dart';

class ShowPushNotificationTap extends StatelessWidget {
  final String theCase;

  const ShowPushNotificationTap({Key? key, required this.theCase})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CaseProvider()..fetchCaseById(theCase),
      child: Consumer<CaseProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage.isNotEmpty) {
            return Center(child: Text(provider.errorMessage));
          }

          if (provider.theCase == null) {
            return const Center(child: Text("No notification found"));
          }

          final MissingPerson theCase = provider.theCase!;

          return MissingPersonDetails(
              missingPerson: theCase, header: "Notification");
        },
      ),
    );
  }
}





// import 'dart:convert';
// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:missingpersonapp/common/models/missing_person.dart';
// import 'package:missingpersonapp/features/home/utils/missingPeopleDisplayCard.dart';

// class ShowPushNotificationTap extends StatefulWidget {
//   final String caseId;

//   const ShowPushNotificationTap({super.key, required this.caseId});

//   @override
//   _ShowPushNotificationTapState createState() => _ShowPushNotificationTapState();
// }

// class _ShowPushNotificationTapState extends State<ShowPushNotificationTap> {
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
