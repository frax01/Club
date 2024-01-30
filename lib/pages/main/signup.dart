import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/classes/user.dart';
import 'package:intl/intl.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key, required this.title});

  final String title;

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUp> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmController =
      TextEditingController();
  final TextEditingController birthdateController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _handleSignUp() async {
    try {
      if (_formKey.currentState?.validate() ?? false) {
        String name = nameController.text;
        String surname = surnameController.text;
        String email = emailController.text;
        String password = passwordController.text;
        String birthdate = birthdateController.text;

        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        String confirmPassword = passwordConfirmController.text;
        if (password != confirmPassword) {
          print('Passwords do not match');
          return;
        }

        await _saveUserToDatabase(ClubUser(
            name: name,
            surname: surname,
            email: email,
            password: password,
            birthdate: birthdate,
            role: "",
            club_class: "",
            soccer_class: "",
            status: "",
            created_time: DateTime.now()));

        print('Sign Up successful: ${userCredential.user?.email}');
        setState(() {
          Navigator.pushNamed(context, '/waiting');
        });
      }
      // Puoi aggiungere qui la navigazione a una nuova schermata, se necessario
    } catch (e) {
      // Gestisci gli errori di registrazione qui
      print('Error during Sign Up: $e');
    }
  }

  Future<void> _saveUserToDatabase(ClubUser user) async {
    try {
      // Ottieni un riferimento al tuo database Firestore
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Aggiungi l'utente al database
      await firestore.collection('user').add({
        'name': user.name,
        'surname': user.surname,
        'email': user.email,
        'birthdate': user.birthdate,
        'role': user.role,
        'club_class': user.club_class,
        'soccer_class': user.soccer_class,
        'status': user.status,
        'created_time': user.created_time
      });
    } catch (e) {
      print('Error saving user to database: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.now()) {
      String formattedDate = DateFormat('dd-MM-yyyy').format(picked);
      setState(() {
        birthdateController.text = formattedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 130, 16, 8),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Name is required';
                }
                return null; // Il valore è valido
              },
            ),
            TextFormField(
              controller: surnameController,
              decoration: InputDecoration(labelText: 'Surname'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Surname is required';
                }
                return null; // Il valore è valido
              },
            ),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email is required';
                }
                return null; // Il valore è valido
              },
            ),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required';
                }
                return null; // Il valore è valido
              },
            ),
            TextFormField(
              controller: passwordConfirmController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password confirm'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password confirm is required';
                }
                return null; // Il valore è valido
              },
            ),
            InkWell(
              onTap: () => _selectDate(context),
              child: IgnorePointer(
                child: TextFormField(
                  controller: birthdateController,
                  decoration: InputDecoration(labelText: 'Birthdate'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Birthdate is required';
                    }
                    return null; // Il valore è valido
                  },
                ),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _handleSignUp,
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
