import 'package:flutter/material.dart';

import '../constants/app_asset_constants.dart';
import 'colors.dart';
import 'sized_box_hw.dart';

class LoaderWithScaffold extends StatelessWidget {
  const LoaderWithScaffold({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: SafeArea(child: LoaderContainerWithMessage(message: message)),
    );
  }
}

class LoaderContainerWithMessage extends StatelessWidget {
  final String? message;
  const LoaderContainerWithMessage({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 200,
        height: 120,
        child: Container(
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), offset: const Offset(0, 4), blurRadius: 15)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(AppAssetConstants.loading40),
              hb10,
              Text(
                message ?? "Loading...",
                style: TextStyle(color: black, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OverlappingLoader extends StatefulWidget {
  const OverlappingLoader({super.key});

  @override
  State<OverlappingLoader> createState() => _OverlappingLoaderState();
}

class _OverlappingLoaderState extends State<OverlappingLoader> with TickerProviderStateMixin {
  late AnimationController controller1;
  late AnimationController controller2;
  late Animation<double> animation1;
  late Animation<double> animation2;

  @override
  void initState() {
    super.initState();
    controller1 = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);
    controller2 = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    Future.delayed(const Duration(milliseconds: 750), () {
      if (!mounted) return;
      controller2.repeat(reverse: true);
    });
    animation1 = Tween<double>(begin: 0, end: 30).animate(CurvedAnimation(parent: controller1, curve: Curves.easeInOut));
    animation2 = Tween<double>(begin: 0, end: 30).animate(CurvedAnimation(parent: controller2, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    controller1.dispose();
    controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 50,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedBuilder(
            animation: animation2,
            builder: (context, child) {
              return Positioned(left: animation2.value, top: 5, child: _buildBall(Colors.blue));
            },
          ),
          AnimatedBuilder(
            animation: animation1,
            builder: (context, child) {
              return Positioned(left: animation1.value, top: 5, child: _buildBall(Colors.yellow));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBall(Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
