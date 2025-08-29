import 'dart:typed_data';
import 'package:flutter/material.dart';

class ImageDisplay extends StatelessWidget {
  final Uint8List imageBytes;
  final double? width;
  final double? height;
  final BoxFit fit;

  const ImageDisplay({
    super.key,
    required this.imageBytes,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return Image.memory(
      imageBytes,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey.shade800,
          child: const Center(
            child: Icon(
              Icons.broken_image,
              color: Colors.white54,
              size: 40,
            ),
          ),
        );
      },
      // Removed loadingBuilder as it is not supported by Image.memory
    );
  }
}