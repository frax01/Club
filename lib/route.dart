import 'package:flutter/material.dart';
import 'main.dart';

//qui ci va la clubPage

class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('First Route’),
      ),
      body: Center(
        child: ClubButton(
          child: const Text('Open route’),
          onPressed: () {
            Navigator.pushNamed(context, '/club’);
          }
        ),
      ),
    );
  }
}