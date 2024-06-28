import 'package:flutter/material.dart';
import 'dart:convert';

class FullScreenImage extends StatelessWidget {
  final String base64Image;

  FullScreenImage({required this.base64Image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.memory(
            base64Decode(base64Image),
            width: MediaQuery.of(context).size.width, // Make the image fill the screen width
            height: MediaQuery.of(context).size.height, // Make the image fill the screen height
            fit: BoxFit.contain,
          ),
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}
