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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            backgroundColor: Colors.red,
            appBar: AppBar(
              title: Text(title),
            ),
            body: const Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: { 
                      Navigator.pushNamed(context, '/first');
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image(
                          image: AssetImage('assets/CC.jpeg'),
                          width: 50.0,
                          height: 50.0,
                        ),
                        SizedBox(height: 8.0),
                        Text('Premi il pulsante'),
                      ],
                    ),
                  )
                ],
              ),
            )
          )
        );
  }
}
