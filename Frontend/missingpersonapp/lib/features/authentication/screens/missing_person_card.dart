import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';

import 'package:missingpersonapp/features/authentication/models/missing_person_model.dart';
import 'package:missingpersonapp/features/authentication/provider/missing_person_provider.dart';
import 'package:missingpersonapp/features/authentication/screens/missing_person_detail.dart';
import 'package:missingpersonapp/features/authentication/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class MissingPersonCard extends StatelessWidget {
  final MissingPersonSpecific missingPerson;

  const MissingPersonCard({super.key, required this.missingPerson});

  Future<void> _shareMissingPerson(BuildContext context) async {
    final String shareContent = '''
Missing Person Details:
First Name: ${missingPerson.name.firstName}
Last Name: ${missingPerson.name.lastName}
Age: ${missingPerson.age}
Last Seen Location: ${missingPerson.lastSeenLocation}
Status: ${missingPerson.missingCase.status}
    ''';

    List<XFile> files = [];

    if (missingPerson.photos.isNotEmpty) {
      Uint8List imageBytes = missingPerson.photos.first;
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/missing_person.png').create();
      await file.writeAsBytes(imageBytes);
      files.add(XFile(file.path));
    }

    await Share.shareXFiles(files, text: shareContent);
  }

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
                child: missingPerson.photos.isNotEmpty
                    ? Image.memory(
                        missingPerson.photos.first,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.grey,
                        child: Icon(
                          Icons.image,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'First Name: ${missingPerson.name.firstName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Last Name: ${missingPerson.name.lastName}',
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
                      'Last Seen Location: ${missingPerson.lastSeenLocation}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Status: ${missingPerson.missingCase.status}',
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
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Confirm Delete'),
                                  content: Text(
                                    'Are you sure you want to delete this post?',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        try {
                                          await Provider.of<
                                                      MissingPersonProvider>(
                                                  context,
                                                  listen: false)
                                              .removeMissingPerson(
                                                  missingPerson);
                                          Navigator.of(context).pop();
                                        } catch (error) {
                                          print(
                                              'Failed to delete the missing person: $error');
                                          showToast(context, error.toString());
                                        }
                                      },
                                      child: Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          icon: Icon(
                            Icons.delete,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _shareMissingPerson(context),
                          icon: Icon(Icons.share),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ])));
  }
}