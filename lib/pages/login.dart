import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'signup.dart';

class Login extends StatefulWidget {
  const Login({super.key});

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
      print('Login successful: ${userCredential.user?.email}');

      setState(() {
        Navigator.pushNamed(context, '/homepage');
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
        title: const Text('Login'),
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
          ),
          SizedBox(height: 16.0),
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(labelText: 'Password'),
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
