import 'package:club/pages/football.dart';
import 'package:club/pages/signup.dart';
import 'package:flutter/material.dart';
import 'functions/button.dart';
import 'pages/club.dart';
import 'pages/login.dart';
import 'package:firebase_core/firebase_core.dart';

//import 'package:firebase_auth/firebase_auth.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyAkmPm2DpVcfIg6uXMUuj7uLIxGd371qqM',
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
      home: const Login(),
      initialRoute: '/',
      routes: {
        '/login': (context) => const Login(),
        '/signup': (context) => const SignUp(),
        '/homepage': (context) => const HomePage(title: 'Tiber Club'),
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
