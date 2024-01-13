import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Login extends StatefulWidget {
  const Login({super.key, required this.title});

  final String title;

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

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

      print('Login successful: ${userCredential.user?.email}, Role: $role');

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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
              onSubmitted: (_) => _handleLogin(),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
              onSubmitted: (_) => _handleLogin(),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _handleLogin,
              child: Text('Login'),
            ),
            SizedBox(height: 8.0), // Aggiunto spazio tra i pulsanti
            TextButton(
              onPressed: _handleSignUp,
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
