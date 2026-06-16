import 'package:flutter/material.dart';

import '../../../reusables/colors.dart';

class LiveBadge extends StatefulWidget {
  final int count;
  const LiveBadge({super.key, required this.count});

  @override
  State<LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<LiveBadge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 700), vsync: this)..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(4)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.only(topLeft: const Radius.circular(4), bottomLeft: const Radius.circular(4)),
            ),
            child: FadeTransition(
              opacity: _controller,
              child: const Icon(Icons.sensors, size: 12, color: red),
            ),
          ),
          const SizedBox(width: 2),
          Container(
            decoration: BoxDecoration(
              color: red,
              borderRadius: BorderRadius.only(topRight: const Radius.circular(4), bottomRight: const Radius.circular(4)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            child: Text(
              widget.count.toString(),
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class LiveBadgeWithTitle extends StatefulWidget {
  final String liveTitle;
  const LiveBadgeWithTitle({super.key, required this.liveTitle});

  @override
  State<LiveBadgeWithTitle> createState() => _LiveBadgeWithTitleState();
}

class _LiveBadgeWithTitleState extends State<LiveBadgeWithTitle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 700), vsync: this)..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(4)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.only(topLeft: const Radius.circular(4), bottomLeft: const Radius.circular(4)),
            ),
            child: FadeTransition(
              opacity: _controller,
              child: const Icon(Icons.sensors, size: 14, color: red),
            ),
          ),
          const SizedBox(width: 2),
          Container(
            decoration: BoxDecoration(
              color: red,
              borderRadius: BorderRadius.only(topRight: const Radius.circular(4), bottomRight: const Radius.circular(4)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            child: Text(
              widget.liveTitle,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
