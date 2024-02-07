import 'package:club/pages/football/updateFootballEvent/footballModifier.dart';
import 'package:club/pages/football/tabClass/ranking/rankingEvent.dart';
import 'package:club/pages/main/signup.dart';
import 'package:club/pages/football/tabClass/match/matchEvent.dart';
import 'package:club/pages/football/tabClass/calendar/calendarEvent.dart';
import 'package:flutter/material.dart';
import 'pages/main/login.dart';
import 'pages/main/waiting.dart';
import 'pages/main/acceptance.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: Config.apiKey,
      authDomain: Config.authDomain,
      projectId: Config.projectId,
      storageBucket: Config.storageBucket,
      messagingSenderId: Config.messagingSenderId,
      appId: Config.appId,
    ),
  );

  deleteOldDocuments();
  
  firebaseMessaging();

  FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  _firebaseMessaging.requestPermission();
  //FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //  print('Got a message whilst in the foreground!');
  //  print('1');
  //  print('Message data: ${message.data}');
  //});

  runApp(const MyApp());
}

Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  print('Got a message whilst in the background!');
  print('0');
  print('Message data: ${message.data}');
}

void deleteOldDocuments() async {
  final firestore = FirebaseFirestore.instance;
  final today = DateTime.now();

  final oneDateCollections = [
    'club_extra',
    'club_weekend',
    'football_extra',
  ];
  for (final collection in oneDateCollections) {
    final querySnapshot = await firestore.collection(collection).get();
    for (final document in querySnapshot.docs) {
      final startDateString = document.data()['startDate'] as String;
      final startDate =
          DateTime.parse(startDateString.split('-').reversed.join('-'));
      if (startDate.isBefore(today)) {
        await document.reference.delete();
      }
    }
  }

  final twoDateCollections = [
    'club_summer',
    'club_trip',
    'football_tournament',
  ];
  for (final collection in twoDateCollections) {
    final querySnapshot = await firestore.collection(collection).get();
    for (final document in querySnapshot.docs) {
      final startDateString = document.data()['endDate'] as String;
      final startDate =
          DateTime.parse(startDateString.split('-').reversed.join('-'));
      if (startDate.isBefore(today)) {
        await document.reference.delete();
      }
    }
  }
}

void firebaseMessaging() {

  FirebaseMessaging.instance.getToken().then((String? token) {
    assert(token != null);
    print('FCM Token: $token');
  });
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
      home: const Login(
        title: 'Phoenix United',
        logout: false,
      ),
      initialRoute: '/homepage',
      routes: {
        '/homepage': (context) => HomePage(),
        '/login': (context) => const Login(
              title: 'Phoenix United',
              logout: false,
            ),
        '/signup': (context) => const SignUp(title: 'Phoenix United'),
        '/waiting': (context) => const Waiting(title: 'Phoenix United'),
        //'/homepage': (context) => const HomePage(title: 'Phoenix United'),
        //'/settings': (context) => const SettingsPage(),
        //'/club': (context) => const ClubPage(title: 'Phoenix Club'),
        //'/football': (context) => const FootballPage(title: 'Phoenix United'),
        '/acceptance': (context) =>
            const AcceptancePage(title: 'Phoenix United'),
        '/football_modifier': (context) =>
            const FootballModifier(title: 'Phoenix United'),
        '/matchEvent': (context) =>
            const MatchEventPage(title: 'Phoenix United'),
        '/calendarEvent': (context) =>
            const CalendarEventPage(title: 'Phoenix United'),
        '/rankingEvent': (context) =>
            const RankingEventPage(title: 'Phoenix United'),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> loadData() async {
    // Simula il caricamento dei dati dal database
    await Future.delayed(Duration(seconds: 5));

    // Una volta che i dati sono stati caricati, naviga alla pagina di login
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('images/logo.png'),
            SizedBox(height: 20.0),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}