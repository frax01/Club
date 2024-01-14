import 'package:flutter/material.dart';

class Waiting extends StatelessWidget {
  const Waiting({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 130, 16, 8),
        centerTitle: true,
        //automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Text(
          'Attendi di essere accettato',
          style: TextStyle(fontSize: 18.0),
        ),
      ),
    );
  }
}