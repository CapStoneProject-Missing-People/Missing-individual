import 'package:flutter/material.dart';
import 'package:missingpersonapp/common/screens/missing_person_detail1.dart';
import 'package:missingpersonapp/features/home/provider/matchcase.dart';
import 'package:provider/provider.dart';

class PersonDetailsScreen extends StatelessWidget {
  final String personId;

  const PersonDetailsScreen({Key? key, required this.personId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CaseMatchedProvider()..fetchCaseById(personId),
      child: Scaffold(
        body: Consumer<CaseMatchedProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.errorMessage.isNotEmpty) {
              return Center(child: Text(provider.errorMessage));
            }

            if (provider.theCase == null) {
              return const Center(
                  child: Text('No details available for this person.'));
            }

            return MissingPersonDetails(
                missingPerson: provider.theCase!,
                header: 'Matched Person Details');
          },
        ),
      ),
    );
  }
}
