import 'package:club/pages/football.dart';
import 'package:club/pages/footballEvent.dart';
import 'package:club/pages/signup.dart';
import 'package:club/pages/weekend.dart';
import 'package:club/pages/trip.dart';
import 'package:club/pages/summer.dart';
import 'package:club/pages/extra.dart';
import 'package:club/pages/matchEvent.dart';
import 'package:flutter/material.dart';
import 'functions/button.dart';
import 'pages/club.dart';
import 'pages/login.dart';
import 'pages/waiting.dart';
import 'pages/acceptance.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/event.dart';
import 'config.dart';

//import 'package:firebase_auth/firebase_auth.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: Config.apiKey,
      authDomain: 'YOUR_AUTH_DOMAIN',
      projectId: 'club-60d94',
      storageBucket: 'club-60d94.appspot.com',
      messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
      appId: 'YOUR_APP_ID',
    ),
  );

  //CollectionReference users = FirebaseFirestore.instance.collection('user');
  //QuerySnapshot querySnapshot = await users.get();
  //querySnapshot.docs.forEach((doc) {
  //  var name = doc['name'];
  //  print('Nome: $name');
  //});

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Club App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const Login(title: 'Tiber Club'),
      initialRoute: '/',
      routes: {
        '/login': (context) => const Login(title: 'Tiber Club'),
        '/signup': (context) => const SignUp(title: 'Tiber Club'),
        '/waiting': (context) => const Waiting(title: 'Tiber Club'),
        '/homepage': (context) => const HomePage(title: 'Tiber Club'),
        '/club': (context) => const ClubPage(title: 'Tiber Club'),
        '/football': (context) => const FootballPage(title: 'ASD Tiber Club'),
        '/acceptance': (context) => const AcceptancePage(title: 'Tiber Club'),
        '/event': (context) => const EventPage(title: 'Tiber Club'),
        '/weekend': (context) => const WeekendPage(title: 'Tiber Club'),
        '/trip': (context) => const TripPage(title: 'Tiber Club'),
        '/summer': (context) => const SummerPage(title: 'Tiber Club'),
        '/extra': (context) => const ExtraPage(title: 'Tiber Club'),
        '/footballEvent': (context) =>
            const FootballEventPage(title: 'ASD Tiber Club'),
        '/matchEvent': (context) =>
            const MatchEventPage(title: 'ASD Tiber Club'),
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
          iconTheme: const IconThemeData(color: Colors.white),
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
