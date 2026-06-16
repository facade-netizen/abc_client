import 'package:flutter/material.dart';

import 'colors.dart';
import 'loader.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key, required this.message, this.messageColor});
  final String message;
  final Color? messageColor;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: white,
      extendBodyBehindAppBar: true,
      body: SafeArea(child: LoaderContainerWithMessage(message: message)),
    );
  }
}

class ExpandedLoader extends StatelessWidget {
  const ExpandedLoader({super.key, required this.message});
  final String message;
  @override
  Widget build(BuildContext context) {
    return Expanded(child: LoaderContainerWithMessage(message: message));
  }
}

//
class LinearProgress extends StatelessWidget {
  const LinearProgress({super.key, this.msg, this.value});
  final String? msg;
  final double? value;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Stack(
        children: [
          // Progress fill
          SizedBox(
            height: 50,
            child: LinearProgressIndicator(
              color: bgCktbet,
              backgroundColor: white,
              value: value,
            ),
          ),

          // Centered text
          Center(
            child: Text(
              msg ?? "Placing your bets, Please wait...",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: black),
            ),
          ),
        ],
      ),
    );
  }
}
