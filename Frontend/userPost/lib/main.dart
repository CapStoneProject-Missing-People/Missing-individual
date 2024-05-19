import 'package:flutter/material.dart';
import 'package:form_project/pages/missing_person_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            colorScheme: ColorScheme.light(
                background: Colors.grey.shade200,
                onBackground: Colors.black,
                primary: Colors.blue,
                onPrimary: Colors.white)),
        home: MissingPersonPage());
  }
}
