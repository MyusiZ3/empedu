import 'package:flutter/material.dart';

class DrawingScreen extends StatelessWidget {
  const DrawingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drawing Lessons'),
      ),
      body: const Center(
        child: Text(
          'Welcome to Drawing Lessons!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
