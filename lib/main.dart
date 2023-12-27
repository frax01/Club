import 'package:flutter/material.dart';
//import 'route.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Club App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const HomePage(title: 'Club Demo Home Page'),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.title});

  final String title;

  //void _footballPage() {
  //  var x = 1;
  //}

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: Text(title),
              backgroundColor: Colors.red,
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
            )
        )
    );
  }
}

class ClubButton extends StatefulWidget {
  const ClubButton({super.key});

  @override
  State<ClubButton> createState() => ClubButtonState();
}

class ClubButtonState extends State<ClubButton> {
  //bool _active = false;
  void _clubPage() {
    setState(() {
      //_active = !_active;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _clubPage,
      child: Column(
        children: <Widget>[
          Image(
            image: AssetImage('images/CC.jpeg'),
            width: 200,
            height: 200,
          ),
        ],
      ),
    );
  }
}

class FootballButton extends StatefulWidget {
  const FootballButton({super.key});

  @override
  State<FootballButton> createState() => FootballButtonState();
}

class FootballButtonState extends State<FootballButton> {
  //bool _active = false;
  void _footballPage() {
    setState(() {
      //_active = !_active;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _footballPage,
      child: Column(
        children: <Widget>[
          Image(
            image: AssetImage('images/Tiber.jpg'),
            width: 200,
            height: 200,
          ),
        ],
      ),
    );
  }
}