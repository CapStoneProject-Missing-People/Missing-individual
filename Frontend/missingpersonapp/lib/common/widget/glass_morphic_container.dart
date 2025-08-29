import 'dart:ui';

import 'package:flutter/material.dart';

class GlassMorphicContainer extends StatelessWidget {
  final Widget? child;
  final double borderRadius;
  final double blur;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderWidth;
  final List<Color> gradientColors;
  final double width;
  final double height;
  final AlignmentGeometry alignment;

  const GlassMorphicContainer({
    super.key,
    this.child,
    this.borderRadius = 20.0,
    this.blur = 10.0,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.borderWidth = 1.0,
    this.gradientColors = const [
      Colors.white10,
      Colors.white30,
    ],
    this.width = double.infinity,
    this.height = double.infinity,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      width: width,
      height: height,
      alignment: alignment,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          width: borderWidth,
          color: Colors.white.withOpacity(0.2),
        ),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: blur,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blur / 2,
            sigmaY: blur / 2,
          ),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}