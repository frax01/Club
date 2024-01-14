import 'package:club/pages/newCalendarEvent.dart';
import 'package:club/pages/football.dart';
import 'package:club/pages/footballEvent.dart';
import 'package:club/pages/rankingEvent.dart';
import 'package:club/pages/signup.dart';
import 'package:club/pages/weekend.dart';
import 'package:club/pages/trip.dart';
import 'package:club/pages/summer.dart';
import 'package:club/pages/extra.dart';
import 'package:club/pages/matchEvent.dart';
import 'package:club/pages/calendarEvent.dart';
import 'package:club/pages/updateEvent.dart';
import 'package:club/pages/deleteCalendarEvent.dart';
import 'package:club/pages/deleteRankingEvent.dart';
import 'package:club/pages/newRankingEvent.dart';
import 'package:club/pages/scorerEvent.dart';
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.transparent),
        useMaterial3: true,
      ),
      home: const Login(title: 'Phoenix United'),
      initialRoute: '/',
      routes: {
        '/login': (context) => const Login(title: 'Phoenix United'),
        '/signup': (context) => const SignUp(title: 'Phoenix United'),
        '/waiting': (context) => const Waiting(title: 'Phoenix United'),
        '/homepage': (context) => const HomePage(title: 'Phoenix United'),
        '/club': (context) => const ClubPage(title: 'Phoenix Club'),
        '/football': (context) => const FootballPage(title: 'Phoenix United'),
        '/acceptance': (context) => const AcceptancePage(title: 'Phoenix United'),
        '/event': (context) => const EventPage(title: 'Phoenix Club'),
        '/weekend': (context) => const WeekendPage(title: 'Phoenix Club'),
        '/trip': (context) => const TripPage(title: 'Phoenix Club'),
        '/summer': (context) => const SummerPage(title: 'Phoenix Club'),
        '/extra': (context) => const ExtraPage(title: 'Phoenix Club'),
        //'/football_extra': (context) => const ExtraPage(title: 'Tiber Club'),
        '/footballEvent': (context) => const FootballEventPage(title: 'Phoenix United'),
        '/matchEvent': (context) => const MatchEventPage(title: 'Phoenix United'),
        '/calendarEvent': (context) => const CalendarEventPage(title: 'Phoenix United'),
        '/newCalendarEvent': (context) => const NewCalendarEventPage(title: 'Phoenix United'),
        '/updateEvent': (context) => const UpdateEvent(),
        '/deleteEvent': (context) => const DeleteCalendarEventPage(),
        '/deleteRankingEvent': (context) => const DeleteRankingEventPage(),
        '/newRankingEvent': (context) => const NewRankingEventPage(title: 'Phoenix United'),
        '/rankingEvent': (context) => const RankingEventPage(title: 'Phoenix United'),
        '/scorerEvent': (context) => const ScorerEventPage(title: 'Phoenix United'),
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
