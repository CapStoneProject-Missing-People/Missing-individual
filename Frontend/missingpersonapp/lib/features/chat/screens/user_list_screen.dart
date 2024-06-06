import 'package:flutter/material.dart';
import 'package:missingpersonapp/common/models/missing_person.dart';
import 'package:missingpersonapp/features/home/provider/allMissingperson.dart';
import 'package:missingpersonapp/features/chat/screens/chat_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

class chatterUser {
  final String id;
  final String chatterUserName;
  final String email;

  chatterUser({required this.id, required this.chatterUserName, required this.email});

  factory chatterUser.fromJson(Map<String, dynamic> json) {
    return chatterUser(
      id: json['id'],
      chatterUserName: json['chatterUsername'],
      email: json['email']
    );
  }
}

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<chatterUser> _users = [];

  @override
  void initState() {
    super.initState();
    _fetchChattedUsers();
  }

  Future<void> _fetchChattedUsers() async {
    final allMissingPeopleProvider = Provider.of<AllMissingPeopleProvider>(context, listen: false);
    await allMissingPeopleProvider.fetchMissingPersons();
    final missingPersons = allMissingPeopleProvider.missingPersons;

    setState(() {
      _users = missingPersons.map((missingPerson) => chatterUser(id: missingPerson.user_id, chatterUserName: missingPerson.userName, email: missingPerson.email)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chatted Users'),
      ),
      body: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return ListTile(
            title: Text(user.chatterUserName),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ChatScreen(receiverId: user.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
