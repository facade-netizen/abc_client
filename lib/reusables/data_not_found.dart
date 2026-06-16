import 'package:flutter/material.dart';

import 'colors.dart';

class DataNotFound extends StatelessWidget {
  const DataNotFound({
    super.key,
    required this.message,
  });
  final String message;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(color: black),
      ),
    );
  }
}
