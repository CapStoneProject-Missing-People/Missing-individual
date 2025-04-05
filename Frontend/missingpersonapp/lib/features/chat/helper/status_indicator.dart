import 'package:flutter/material.dart';
import 'package:missingpersonapp/common/utils/app_colors.dart';

class TypingIndicator extends StatefulWidget {
  final bool isActive;
  final Color dotColor;

  const TypingIndicator({
    super.key,
    required this.isActive,
    this.dotColor = AppColors.primary,
  });

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation1;
  late Animation<double> _animation2;
  late Animation<double> _animation3;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _animation1 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeInOut),
      ),
    );

    _animation2 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.5, curve: Curves.easeInOut),
      ),
    );

    _animation3 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.7, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) return const SizedBox();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _AnimatedDot(animation: _animation1, color: widget.dotColor),
        const SizedBox(width: 4),
        _AnimatedDot(animation: _animation2, color: widget.dotColor),
        const SizedBox(width: 4),
        _AnimatedDot(animation: _animation3, color: widget.dotColor),
      ],
    );
  }
}

class _AnimatedDot extends StatelessWidget {
  final Animation<double> animation;
  final Color color;

  const _AnimatedDot({
    required this.animation,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -animation.value * 5),
          child: Opacity(
            opacity: animation.value,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}