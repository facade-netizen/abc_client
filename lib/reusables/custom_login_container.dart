import 'package:flutter/material.dart';

class CustomLoginContainer extends StatelessWidget {
  const CustomLoginContainer({super.key, required this.width, required this.height, this.child, required this.borderRadius, this.color});
  final double width;
  final double height;
  final double borderRadius;
  final Widget? child;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: color ?? Color.fromRGBO(255, 255, 255, .6), borderRadius: BorderRadius.circular(borderRadius)),
      child: child,
    );
  }
}
