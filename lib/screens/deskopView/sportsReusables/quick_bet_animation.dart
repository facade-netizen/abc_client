import 'dart:math';

import 'package:flutter/material.dart';

import '../../../reusables/colors.dart';

class QuickBetAnimation extends StatefulWidget {
  final Widget child;
  final bool isBackClicked;
  final double shakeIntensity;

  const QuickBetAnimation({
    super.key,
    required this.child,
    this.isBackClicked = true,
    this.shakeIntensity = 0.5,
  });

  @override
  State<QuickBetAnimation> createState() => _QuickBetAnimationState();
}

class _QuickBetAnimationState extends State<QuickBetAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Color?> _highlightAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: -widget.shakeIntensity), weight: 10),
      TweenSequenceItem(tween: Tween<double>(begin: -widget.shakeIntensity, end: widget.shakeIntensity), weight: 20),
      TweenSequenceItem(tween: Tween<double>(begin: widget.shakeIntensity, end: -widget.shakeIntensity * 0.5), weight: 20),
      TweenSequenceItem(tween: Tween<double>(begin: -widget.shakeIntensity * 0.5, end: 0.0), weight: 50),
    ]).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.98, end: 1.03), weight: 40),
      TweenSequenceItem(tween: Tween<double>(begin: 1.03, end: 1.0), weight: 60),
    ]).animate(_controller);

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _highlightAnimation = ColorTween(
      begin: white.withValues(alpha: 0.3),
      end: none,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Widget> _buildParticles() {
    final particles = <Widget>[];
    final count = 8;

    for (var i = 0; i < count; i++) {
      final angle = 2 * pi * i / count;
      final distance = 30.0;

      particles.add(
        Positioned(
          left: 50 + cos(angle) * distance * _particleAnimation.value,
          top: 25 + sin(angle) * distance * _particleAnimation.value,
          child: Opacity(
            opacity: 1 - _particleAnimation.value,
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: highlightHeader, //widget.isBackClicked ? oddsBackBtn : pinkButtonClr;
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      );
    }

    return particles;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            Transform.translate(
              offset: Offset(_shakeAnimation.value, 0),
              child: Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0),
                    color: _highlightAnimation.value,
                  ),
                  child: Opacity(
                    opacity: _opacityAnimation.value,
                    child: child,
                  ),
                ),
              ),
            ),
            ..._buildParticles(),
          ],
        );
      },
      child: widget.child,
    );
  }
}
