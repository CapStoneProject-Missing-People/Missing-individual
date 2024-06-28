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
  switch (response.statusCode) {
    case 200:
    case 201:
      onSuccess();
      break;
    case 400:
    case 401:
    case 403:
    case 404:
    case 500:
      final errorMessage =
          jsonDecode(response.body)['errors'];
      showToast(context, errorMessage, Colors.red);
      break;
    default:
      showToast(
          context, 'Unexpected error: ${response.statusCode}', Colors.red);
  }
}
