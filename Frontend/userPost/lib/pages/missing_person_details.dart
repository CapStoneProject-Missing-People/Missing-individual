import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:form_project/missing_person.dart';

class MissingPersonDetails extends StatelessWidget {
  final MissingPerson missingPerson;

  const MissingPersonDetails({super.key, required this.missingPerson});

  Future<void> editField(BuildContext context, field) async {
    String newValue = "";
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Colors.grey[800],
              title:
                  Text("Edit " + field, style: TextStyle(color: Colors.white)),
              content: TextField(
                autofocus: true,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Enter new $field",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                onChanged: (value) {
                  newValue = value;
                },
              ),
              actions: [
                TextButton(
                  child: Text("Cancel", style: TextStyle(color: Colors.white)),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                    child: Text(
                      "Save",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () => Navigator.of(context).pop(newValue))
              ],
            ));
  }

  Container buildContainer(
      String text1, String text2, IconData text3, BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(left: 15, top: 10, bottom: 10, right: 10),
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue[400],
                ),
                padding: EdgeInsets.all(10),
                child: Icon(text3, color: Colors.white)),
            SizedBox(width: 10), // Adjust the space between the icon and text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(text1,
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                  Text(text2,
                      textAlign: TextAlign.start,
                      style:
                          TextStyle(fontWeight: FontWeight.w400, fontSize: 14)),
                ],
              ),
            ),
            //Spacer(), // This will push the IconButton to the far right
            Container(
                child: IconButton(
                    onPressed: () => editField(context, text1),
                    icon: Icon(Icons.edit)))
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.background,
          title: Text('Missing Person Details'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              /*  mainAxisAlignment: MainAxisAlignment.start, */
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width - (40),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                          image: NetworkImage(missingPerson.photos.first),
                          fit: BoxFit.cover)),
                ),
                const SizedBox(
                  height: 20,
                ),
                buildContainer(
                    'Name', '${missingPerson.name}', Icons.person, context),
                SizedBox(
                  height: 5,
                ),
                buildContainer('Age', '${missingPerson.age}',
                    Icons.calendar_month, context),
                SizedBox(
                  height: 5,
                ),
                buildContainer(
                    "Last Seen Place",
                    '${missingPerson.lastSeenPlace}',
                    Icons.location_city,
                    context),
                SizedBox(
                  height: 5,
                ),
                buildContainer("Phone Number", '${missingPerson.phoneNumber}',
                    Icons.phone, context),
                SizedBox(
                  height: 5,
                ),
                buildContainer("Description", '${missingPerson.description}',
                    Icons.book, context),
              ],
            ),
          ),
        ));
  }
}
