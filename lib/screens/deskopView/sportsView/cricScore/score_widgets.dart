import 'package:flutter/material.dart';

class LivePulseBadge extends StatefulWidget {
  const LivePulseBadge({super.key, required this.child, required this.alignEnd});

  final Widget child;
  final bool alignEnd;

  @override
  State<LivePulseBadge> createState() => LivePulseBadgeState();
}

class LivePulseBadgeState extends State<LivePulseBadge> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.45, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: widget.child,
    );
  }
}

class ScoreboardBackdropPainter extends CustomPainter {
  ScoreboardBackdropPainter({required this.leftAccent, required this.rightAccent});

  final Color leftAccent;
  final Color rightAccent;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;

    final Paint basePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0F2A45),
          Color(0xFF294E72),
          Color(0xFF10263C),
        ],
        stops: [0, 0.52, 1],
      ).createShader(rect);
    canvas.drawRect(rect, basePaint);

    // Center glow disabled for now to keep the backdrop softer and reduce eye strain.
    // final Paint centerGlow = Paint()
    //   ..shader = RadialGradient(
    //     colors: [
    //       const Color(0xB0F7FBFF),
    //       const Color(0x75D8EDFF),
    //       const Color(0x18A5D2FF),
    //       Colors.transparent,
    //     ],
    //     stops: const [0, 0.14, 0.34, 1],
    //   ).createShader(Rect.fromCircle(center: Offset(size.width / 2, size.height * 0.45), radius: size.width * 0.36));
    // canvas.drawCircle(Offset(size.width / 2, size.height * 0.45), size.width * 0.36, centerGlow);

    final Paint leftGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xAAF7FBFF),
          leftAccent.withValues(alpha: 0.15),
          Colors.transparent,
        ],
        stops: const [0, 0.24, 1],
      ).createShader(Rect.fromCircle(center: Offset(size.width * 0.26, size.height * 0.35), radius: size.width * 0.30));
    canvas.drawCircle(Offset(size.width * 0.26, size.height * 0.35), size.width * 0.30, leftGlow);

    final Paint rightGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xAAF7FBFF),
          rightAccent.withValues(alpha: 0.14),
          Colors.transparent,
        ],
        stops: const [0, 0.24, 1],
      ).createShader(Rect.fromCircle(center: Offset(size.width * 0.74, size.height * 0.35), radius: size.width * 0.30));
    canvas.drawCircle(Offset(size.width * 0.74, size.height * 0.35), size.width * 0.30, rightGlow);

    final Paint bandPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0x00FFFFFF),
          Color(0x183E7CAA),
          Color(0x70F8FCFF),
          Color(0x183E7CAA),
          Color(0x00FFFFFF),
        ],
        stops: [0, 0.2, 0.5, 0.8, 1],
      ).createShader(Rect.fromLTWH(size.width * 0.18, size.height * 0.25, size.width * 0.64, size.height * 0.13));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.18, size.height * 0.25, size.width * 0.64, size.height * 0.13),
        const Radius.circular(120),
      ),
      bandPaint,
    );

    final Paint linePaint = Paint()
      ..color = const Color(0x66BFE0FF)
      ..strokeWidth = 1;

    canvas.drawLine(Offset(size.width * 0.08, size.height * 0.30), Offset(size.width * 0.40, size.height * 0.50), linePaint);
    canvas.drawLine(Offset(size.width * 0.92, size.height * 0.30), Offset(size.width * 0.60, size.height * 0.50), linePaint);
    canvas.drawLine(Offset(size.width * 0.18, size.height * 0.86), Offset(size.width * 0.50, size.height * 0.71), linePaint);
    canvas.drawLine(Offset(size.width * 0.82, size.height * 0.86), Offset(size.width * 0.50, size.height * 0.71), linePaint);

    final Paint vignette = Paint()
      ..shader = const RadialGradient(
        center: Alignment.topCenter,
        radius: 1.1,
        colors: [
          Color(0x00112B46),
          Color(0x603A6A96),
          Color(0xCC122940),
        ],
        stops: [0.25, 0.72, 1],
      ).createShader(rect)
      ..blendMode = BlendMode.multiply;
    canvas.drawRect(rect, vignette);

    final Paint rimPaint = Paint()
      ..color = const Color(0x55CFE8FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.10, size.height * 0.04, size.width * 0.80, size.height * 0.58),
        const Radius.circular(26),
      ),
      rimPaint,
    );

    final Paint floorGlow = Paint()
      ..shader = const RadialGradient(
        center: Alignment.bottomCenter,
        radius: 1.0,
        colors: [
          Color(0x003C6C96),
          Color(0x0C6FB0E8),
          Colors.transparent,
        ],
        stops: [0, 0.34, 1],
      ).createShader(Rect.fromLTWH(0, size.height * 0.56, size.width, size.height * 0.44));
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.56, size.width, size.height * 0.44), floorGlow);
  }

  @override
  bool shouldRepaint(covariant ScoreboardBackdropPainter oldDelegate) {
    return oldDelegate.leftAccent != leftAccent || oldDelegate.rightAccent != rightAccent;
  }
}
