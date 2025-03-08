import 'dart:typed_data';
import 'package:flutter/material.dart';

class ImageDisplay extends StatelessWidget {
  final Uint8List imageBytes;

  const ImageDisplay({super.key, required this.imageBytes});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: SizedBox(
        height: 200,
        width: double.infinity,
        child: Image.memory(
          imageBytes,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
