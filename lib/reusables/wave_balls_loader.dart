import 'package:flutter/material.dart';
import 'dart:math';

import 'colors.dart';

class WaveBallsLoader extends StatefulWidget {
  const WaveBallsLoader({super.key});

  @override
  State<WaveBallsLoader> createState() => _WaveBallsLoaderState();
}

class _WaveBallsLoaderState extends State<WaveBallsLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildBall(int index) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double value = sin((_controller.value * 2 * pi) + (index * pi / 3));
        return Transform.translate(offset: Offset(0, value * -1), child: child);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        width: 8,
        height: 8,
        decoration: const BoxDecoration(color: grey, shape: BoxShape.circle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (index) => _buildBall(index)));
  }
}
