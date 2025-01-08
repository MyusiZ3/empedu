import 'package:flutter/material.dart';

class MathScreen extends StatelessWidget {
  const MathScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Math Lessons'),
      ),
      body: const Center(
        child: Text(
          'Welcome to Math Lessons!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
