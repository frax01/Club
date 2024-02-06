import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:club/pages/football/football.dart';
import 'package:club/pages/club/club.dart';

class Login extends StatefulWidget {
  const Login({Key? key, required this.title, required this.logout})
      : super(key: key);

  final String title;
  final bool logout;

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? status;

  bool rememberMe = false;
  List<String> emailSuggestions = [];
  Map<String, String> savedCredentials = {};
  Map<String, dynamic> document = {};

  @override
  void initState() {
    super.initState();
    if (widget.logout == true) {
      emailController.text = '';
      passwordController.text = '';
      rememberMe = false;
      //emailController.addListener(_fillPassword);
    } else {
      _loadLoginInfo().then((_) {
        if (rememberMe &&
            emailController.text.isNotEmpty &&
            passwordController.text.isNotEmpty) {
          _handleLogin();
        }
      });
    }
  }

  _loadLoginInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      emailController.text = (prefs.getString('email') ?? '');
      passwordController.text = (prefs.getString('password') ?? '');
      rememberMe = (prefs.getBool('rememberMe') ?? false);
      emailSuggestions = (prefs.getStringList('emailSuggestions') ?? []);
    });
  }

  //_fillPassword() {
  //  if (savedCredentials.containsKey(emailController.text)) {
  //    passwordController.text = savedCredentials[emailController.text]!;
  //  }
  //}

  _saveLoginInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('email', emailController.text);
    prefs.setString('password', passwordController.text);
    prefs.setBool('rememberMe', rememberMe);
    if (!emailSuggestions.contains(emailController.text)) {
      emailSuggestions.add(emailController.text);
      prefs.setStringList('emailSuggestions', emailSuggestions);
    }
  }

  _loadLastPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String lastPage = (prefs.getString('lastPage') ?? 'FootballPage');

    if (lastPage == 'ClubPage') {
      loadClubPage(status);
    } else if (lastPage == 'FootballPage') {
      print(emailController.text);
      loadFootballPage(status);
    }
  }

  loadClubPage(status) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ClubPage(
                title: "Phoenix United",
                document: document)));
  }

  loadFootballPage(status) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => FootballPage(
                title: "Phoenix United",
                document: document)));
  }

  _saveLastPage(String page) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('lastPage', page);
  }

  Future<void> _handleLogin() async {
    try {
      String email = emailController.text;
      String password = passwordController.text;

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String userEmail = userCredential.user?.email ?? '';
      CollectionReference user = FirebaseFirestore.instance.collection('user');
      QuerySnapshot querySnapshot1 = await user.where('email', isEqualTo: userEmail).get();

      document = {
        'name': querySnapshot1.docs.first['name'],
        'surname': querySnapshot1.docs.first['surname'],
        'email': querySnapshot1.docs.first['email'],
        'role': querySnapshot1.docs.first['role'],
        'club_class': querySnapshot1.docs.first['club_class'],
        'soccer_class': querySnapshot1.docs.first['soccer_class'],
        'status': querySnapshot1.docs.first['status'],
        'birthdate': querySnapshot1.docs.first['birthdate'],
        'token': querySnapshot1.docs.first['token'],
      };

      setState(() {
        if (document['role'] == "") {
          Navigator.pushNamed(context, '/waiting');
        } else {
          if (document['club_class'] == "") {
            Navigator.pushNamed(context, '/football');
          } else if (document['soccer_class'] == "") {
            Navigator.pushNamed(context, '/club');
          } else {
            _loadLastPage();
          }
        }
      });
      if (rememberMe) {
        _saveLoginInfo();
      }
    } catch (e) {
      print('Error during login: $e');
    }
  }

  Future<void> _handleSignUp() async {
    setState(() {
      Navigator.pushNamed(context, '/signup');
    });
  }

  void _handleForgotPassword() {
    // Implementa la logica per il ripristino della password qui
    print('Forgot Password tapped');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title:
              Text(widget.title, style: const TextStyle(color: Colors.white)),
          backgroundColor: const Color.fromARGB(255, 130, 16, 8),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Card(
            color: Colors.white,
            elevation: 30.0,
            shadowColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  5.0), // Regola il raggio per ottenere bordi arrotondati
              //side: BorderSide(
              //  color: Colors.black,
              //  width: 0.5,
              //),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Text('Log In',
                            style: TextStyle(
                                fontSize: 24.0, fontWeight: FontWeight.bold)),
                        Text('Complete the fields below',
                            style: TextStyle(fontSize: 14.0)),
                      ],
                    ),
                  ),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    onSubmitted: (_) => _handleLogin(),
                  ),
                  SizedBox(height: 16.0),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                    onSubmitted: (_) => _handleLogin(),
                  ),
                  SizedBox(height: 16.0),
                  CheckboxListTile(
                    title: Text('Remember me'),
                    value: rememberMe,
                    onChanged: (bool? value) {
                      setState(() {
                        rememberMe = value!;
                      });
                    },
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _handleLogin,
                    child: const Text('Login',
                        style: TextStyle(color: Colors.black)),
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              5.0), // Imposta il raggio per ottenere bordi arrotondati
                          //side: BorderSide(color: Colors.black, width: 1.0), // Imposta il colore e lo spessore del bordo
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  ElevatedButton(
                    onPressed: _handleSignUp,
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                    ),
                    child: const Text('Sign Up',
                        style: TextStyle(color: Colors.black)),
                  ),
                  SizedBox(height: 16.0),
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          TextEditingController resetEmailController =
                              TextEditingController();
                          return AlertDialog(
                            title: Text('Recupero password'),
                            content: TextField(
                              controller: resetEmailController,
                              decoration:
                                  const InputDecoration(labelText: 'Email'),
                            ),
                            actions: [
                              TextButton(
                                child: Text('Annulla'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: Text('Invia'),
                                onPressed: () async {
                                  if (resetEmailController.text.isNotEmpty) {
                                    try {
                                      await FirebaseAuth.instance
                                          .sendPasswordResetEmail(
                                              email: resetEmailController.text);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Email di recupero password inviata.')),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Errore durante l\'invio dell\'email di recupero password.')),
                                      );
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text('Inserisci un\'email.')),
                                    );
                                  }
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text(
                      'Password dimenticata?',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
