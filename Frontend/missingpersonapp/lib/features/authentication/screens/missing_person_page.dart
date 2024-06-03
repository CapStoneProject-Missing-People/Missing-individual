import 'package:flutter/material.dart';
import 'package:missingpersonapp/features/authentication/provider/missing_person_provider.dart';
import 'package:missingpersonapp/features/authentication/screens/missing_person_card.dart';
import 'package:missingpersonapp/features/authentication/utils/utils.dart';
import 'package:provider/provider.dart';

class MissingPersonPage extends StatefulWidget {
  MissingPersonPage({super.key});

  @override
  State<MissingPersonPage> createState() => _MissingPersonPageState();
}

class _MissingPersonPageState extends State<MissingPersonPage> {
  @override
  void initState() {
    super.initState();
    // Fetch missing persons when the widget is first built
    fetchMissingPersons();
  }

  Future<void> fetchMissingPersons() async {
    try {
      await Provider.of<MissingPersonProvider>(context, listen: false)
          .fetchMissingPersons();
    } catch (e) {
      // Handle the exception, e.g., display an error message
      print('Error fetching missing persons: $e');
      /* ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching missing persons: $e'),
        ),
      ); */
      showToast(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text('Missing Persons'),
      ),
      body: Consumer<MissingPersonProvider>(
        builder: (context, provider, child) {
          if (provider.missingPersons.isEmpty) {
            return Center(
              child: Container(
                padding: EdgeInsets.all(16.0),
                margin: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  'No posts by user',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(10),
            child: GridView.builder(
              itemCount: provider.missingPersons.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                // childAspectRatio: (1 / 1.5),
                mainAxisSpacing: 12,
                mainAxisExtent: 410,
              ),
              itemBuilder: (context, index) {
                final missingPerson = provider.missingPersons[index];
                print(missingPerson);
                return MissingPersonCard(missingPerson: missingPerson);
              },
            ),
          );
        },
      ),
    );
  }
}
