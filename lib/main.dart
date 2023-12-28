import 'package:club/pages/football.dart';
import 'package:flutter/material.dart';
import 'functions/button.dart';
import 'pages/club.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Club App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const HomePage(title: 'Home Page'),
      initialRoute: '/',
      routes: {
        '/club': (context) => const ClubPage(title: 'Tiber Club'),
        '/football': (context) => const FootballPage(title: 'ASD Tiber Club'),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(
              title: Text(title, style: const TextStyle(color: Colors.white)),
              backgroundColor: const Color.fromARGB(255, 130, 16, 8),
              centerTitle: true,
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClubButton(),
                  FootballButton(),
                ],
              ),
            ));
  }
}