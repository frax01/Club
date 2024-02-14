import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.id});

  final String id;

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _birthdateController = TextEditingController();
  final _emailController = TextEditingController();

  // Assuming you have a method to get the current user's email
  final _currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    getUserData().then((userData) {
      _nameController.text = userData['name'];
      _surnameController.text = userData['surname'];
      _birthdateController.text = userData['birthdate'];
      _emailController.text = userData['email'];
    });
  }

  Future<Map<String, dynamic>> getUserData() async {
    print(_currentUser!.uid);
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('user')
        .doc(widget.id)
        .get();
    return userDoc.data() as Map<String, dynamic>;
  }

  Future<void> updateUserData(Map<String, String> updatedData) async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(_currentUser!.uid)
        .update(updatedData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            _buildTextFieldWithUpdateButton('Name', _nameController),
            _buildTextFieldWithUpdateButton('Surname', _surnameController),
            _buildTextFieldWithUpdateButton('Birthdate', _birthdateController),
            _buildTextFieldWithUpdateButton('Email', _emailController),
            ElevatedButton(
              onPressed: () async {
                bool? confirm = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Conferma'),
                      content: const Text(
                          'Sei sicuro di voler eliminare definitivamente il tuo account?'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Annulla'),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        ),
                        TextButton(
                          child: const Text('Elimina'),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                        ),
                      ],
                    );
                  },
                );
                if (confirm == true) {
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    try {
                      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                      .collection('user')
                      .where('email', isEqualTo: user.email)
                      .get();

                      if (querySnapshot.docs.isNotEmpty) {
                        DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
                        DocumentReference userDoc = documentSnapshot.reference;
                        // Ora puoi utilizzare userDoc per eliminare il documento
                        await userDoc.delete();
                      }
                      // Elimina il documento dell'utente
                      await user.delete();
                      // Dopo l'eliminazione dell'account, reindirizza l'utente alla pagina di login
                      Navigator.of(context).pushReplacementNamed('/login');
                    } catch (e) {
                      print('Errore durante l\'eliminazione dell\'account: $e');
                    }
                  }
                }
              },
              child: const Text('Elimina account'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFieldWithUpdateButton(
      String label, TextEditingController controller) {
    return Row(
      children: [
        Expanded(
          child: label == 'Birthdate'
              ? _buildDateField(label, controller)
              : _buildTextField(label, controller),
        ),
        TextButton(
          child: const Text('Update'),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              updateUserData({label.toLowerCase(): controller.text});
            }
          },
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Enter your $label',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $label';
        }
        return null;
      },
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
      ),
      readOnly: true,
      onTap: () async {
        FocusScope.of(context).requestFocus(FocusNode());
        final String birthdate = _birthdateController.text;
        final DateTime initialDate = birthdate.isEmpty
            ? DateTime.now()
            : DateTime.parse(
                '${birthdate.substring(6, 10)}-${birthdate.substring(3, 5)}-${birthdate.substring(0, 2)}');
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          _birthdateController.text = picked.toIso8601String();
        }
      },
    );
  }
}
