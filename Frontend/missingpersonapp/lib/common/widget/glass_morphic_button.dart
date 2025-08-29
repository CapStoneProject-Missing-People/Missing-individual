import 'package:flutter/material.dart';
import 'package:missingpersonapp/common/widget/glass_morphic_container.dart';

class GlassMorphicButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final List<Color> gradientColors;
  final double borderWidth;
  final double blur;

  const GlassMorphicButton({
    super.key,
    required this.child,
    this.onPressed,
    this.borderRadius = 15.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    this.gradientColors = const [
      Colors.white10,
      Colors.white30,
    ],
    this.borderWidth = 1.0,
    this.blur = 5.0,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(borderRadius),
      child: GlassMorphicContainer(
        borderRadius: borderRadius,
        blur: blur,
        padding: padding,
        borderWidth: borderWidth,
        gradientColors: gradientColors,
        child: child,
      ),
    );
  }
}