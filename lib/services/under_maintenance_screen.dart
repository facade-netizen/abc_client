import 'package:flutter/material.dart';

class UnderMaintenanceScreen extends StatelessWidget {
  const UnderMaintenanceScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.build, size: 100, color: Colors.orange),
              const SizedBox(height: 20),
              const Text(
                "We'll be back soon!",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                "Our app is currently under maintenance. "
                "We're working hard to improve your experience. "
                "Please check back later.",
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
