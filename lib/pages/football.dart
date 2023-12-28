import 'package:flutter/material.dart';

class FootballPage extends StatefulWidget {
  const FootballPage({super.key, required this.title});

  final String title;

  @override
  State<FootballPage> createState() => _FootballPageState();
}

class _FootballPageState extends State<FootballPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title, style: const TextStyle(color: Colors.white)),
          backgroundColor: const Color.fromARGB(255, 130, 16, 8),
          centerTitle: true,
        ),
      );
  }
}
