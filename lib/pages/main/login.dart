import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Login extends StatefulWidget {
  const Login({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool rememberMe = false;

  Future<void> _handleLogin() async {
    try {
      String email = emailController.text;
      String password = passwordController.text;

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String userEmail = userCredential.user?.email ?? '';

      CollectionReference users = FirebaseFirestore.instance.collection('user');
      QuerySnapshot querySnapshot = await users.where('email', isEqualTo: userEmail).get();
      var role = querySnapshot.docs.first['role'];

      setState(() {
        if (role == "") {
          Navigator.pushNamed(context, '/waiting');
        } else {
          Navigator.pushNamed(context, '/homepage');
        }
      });
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
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
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
              borderRadius: BorderRadius.circular(5.0), // Regola il raggio per ottenere bordi arrotondati
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
                      Text('Log In', style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
                      Text('Complete the fields below', style: TextStyle(fontSize: 14.0)),
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
                Row(
                  children: [
                    Checkbox(
                      value: rememberMe,
                      onChanged: (value) {
                        setState(() {
                          rememberMe = value ?? false;
                        });
                      },
                    ),
                    Text('Ricordami'),
                  ],
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _handleLogin,
                  child: const Text('Login', style: TextStyle(color: Colors.black)),
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0), // Imposta il raggio per ottenere bordi arrotondati
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
                  child: const Text('Sign Up', style: TextStyle(color: Colors.black)),
                ),
                TextButton(
                  onPressed: _handleForgotPassword,
                  child: const Text('Password dimenticata?', style: TextStyle(color: Colors.black),),
                ),
              ],
            ),
          ),
        ),
      )
    );
  }
}
