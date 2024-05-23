import 'package:flutter/material.dart';
import 'package:form_project/missing_person.dart';
import 'package:form_project/pages/missing_person_details.dart';

class MissingPersonCard extends StatelessWidget {
  final MissingPerson missingPerson;

  const MissingPersonCard({super.key, required this.missingPerson});

  @override
  Widget build(BuildContext context) {
    return Material(
        elevation: 5,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      MissingPersonDetails(missingPerson: missingPerson),
                ),
              );
            },
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                  child: Container(
                      child: SingleChildScrollView(
                          child: Column(
                    children: missingPerson.photos
                        .map((photo) => Image.network(
                              photo,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ))
                        .toList(),
                  )))),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Name: ${missingPerson.name}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Age: ${missingPerson.age}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Last Seen Place: ${missingPerson.lastSeenPlace}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Phone Number: ${missingPerson.phoneNumber}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.delete,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ])));
  }
}
