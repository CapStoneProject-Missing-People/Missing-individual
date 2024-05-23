import 'package:flutter/material.dart';
import 'package:form_project/missing_person.dart';
import 'package:form_project/pages/missing_person_card.dart';

class MissingPersonPage extends StatelessWidget {
  final List<MissingPerson> missingPersons = [
    MissingPerson(
        name: 'John Doe',
        age: 30,
        lastSeenPlace: 'New York',
        photos: [
          "https://images.unsplash.com/photo-1564564321837-a57b7070ac4f?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OHx8bWFufGVufDB8fDB8fHww"
        ],
        phoneNumber: '123-456-7890',
        description:
            "This is the description of the missing person's details about the time and place and situation of the missing person"),
    MissingPerson(
        name: 'Jane Doe',
        age: 25,
        lastSeenPlace: 'Los Angeles',
        photos: [
          "https://plus.unsplash.com/premium_photo-1664533227571-cb18551cac82?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTN8fG1hbnxlbnwwfHwwfHx8MA%3D%3D"
        ],
        phoneNumber: '987-654-3210',
        description:
            "This is the description of the missing person's details about the time and place and situation of the missing person"),
    MissingPerson(
        name: 'John Doe',
        age: 30,
        lastSeenPlace: 'New York',
        photos: [
          "https://plus.unsplash.com/premium_photo-1689551670902-19b441a6afde?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTN8fHdvbWFufGVufDB8fDB8fHww"
        ],
        phoneNumber: '123-456-7890',
        description:
            "This is the description of the missing person's details about the time and place and situation of the missing person"),
    MissingPerson(
        name: 'John Doe',
        age: 30,
        lastSeenPlace: 'New York',
        photos: [
          "https://images.unsplash.com/photo-1592621385612-4d7129426394?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MzV8fHdvbWFufGVufDB8fDB8fHww"
        ],
        phoneNumber: '123-456-7890',
        description:
            "This is the description of the missing person's details about the time and place and situation of the missing person"),
    MissingPerson(
        name: 'John Doe',
        age: 30,
        lastSeenPlace: 'New York',
        photos: [
          "https://plus.unsplash.com/premium_photo-1664533227571-cb18551cac82?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTN8fG1hbnxlbnwwfHwwfHx8MA%3D%3D"
        ],
        phoneNumber: '123-456-7890',
        description:
            "This is the description of the missing person's details about the time and place and situation of the missing person"),
    MissingPerson(
        name: 'John Doe',
        age: 30,
        lastSeenPlace: 'New York',
        photos: [
          "https://images.unsplash.com/photo-1564564321837-a57b7070ac4f?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OHx8bWFufGVufDB8fDB8fHww"
        ],
        phoneNumber: '123-456-7890',
        description:
            "This is the description of the missing person's details about the time and place and situation of the missing person"),

    // Add more MissingPerson objects as needed
  ];
  MissingPersonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text('Missing Persons'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: GridView.builder(
          itemCount: missingPersons.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              // childAspectRatio: (1 / 1.5),
              mainAxisSpacing: 12,
              mainAxisExtent: 410),
          itemBuilder: (context, index) {
            final missingPerson = missingPersons[index];
            return MissingPersonCard(missingPerson: missingPerson);
          },
        ),
      ),
    );
  }
}
