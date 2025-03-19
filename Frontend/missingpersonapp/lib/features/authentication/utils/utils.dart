import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:fluttertoast/fluttertoast.dart';

void showToast(BuildContext context, String text, Color bgColor) {
  Fluttertoast.showToast(
    msg: text,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 10,
    backgroundColor: bgColor,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}

void httpErrorHandle({
  required http.Response response,
  required BuildContext context,
  required VoidCallback onSuccess,
}) {
  print("HTTP Response Status Code: ${response.statusCode}");
  print("HTTP Response Headers: ${response.headers}");
  print("HTTP Response Body: ${response.body}");

  switch (response.statusCode) {
    case 200:
      try {
        onSuccess();
      } catch (e, stackTrace) {
        print("Error in onSuccess callback: $e");
        print("Stack trace: $stackTrace");
        showToast(context, e.toString(), Colors.red);
      }
      break;
    case 400:
      showToast(context, jsonDecode(response.body)['msg'] ?? 'Bad Request',
          Colors.red);
      break;
    case 500:
      showToast(
          context,
          jsonDecode(response.body)['error'] ?? 'Internal Server Error',
          Colors.red);
      break;
    default:
      showToast(context, response.body ?? 'An error occurred', Colors.red);
  }
}

String? validateEmail(String? value) {
  if (value == null || value.isEmpty) return 'Email is required';
  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
    return 'Enter a valid email address';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) return 'Password is required';
  if (value.length < 6) return 'Password must be at least 6 characters';
  return null;
}

String? validateName(String? value) {
  if (value == null || value.isEmpty) return 'Name is required';
  return null;
}

String? validatePhone(String? value) {
  if (value == null || value.isEmpty) return 'Phone number is required';
  if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
    return 'Enter a valid 10-digit phone number';
  }
  return null;
}
