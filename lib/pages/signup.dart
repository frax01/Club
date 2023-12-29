import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUp> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _handleSignUp() async {
    try {
      String email = emailController.text;
      String password = passwordController.text;

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Registrazione riuscita, puoi accedere alle informazioni sull'utente da userCredential.user

      print('Sign Up successful: ${userCredential.user?.email}');
      setState(() {
        Navigator.pushNamed(context, '/login');
      });

      // Puoi aggiungere qui la navigazione a una nuova schermata, se necessario
    } catch (e) {
      // Gestisci gli errori di registrazione qui
      print('Error during Sign Up: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
            onPressed: _handleSignUp,
            child: Text('Sign Up'),
          ),
        ],
      ),
    );
  }
}
