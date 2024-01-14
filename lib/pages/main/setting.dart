import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _birthdateController = TextEditingController();

  // Assuming you have a method to get the current user's email
  final _currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    getUserData().then((userData) {
      _nameController.text = userData['name'];
      _surnameController.text = userData['surname'];
      _birthdateController.text = userData['birthdate'];
    });
  }

  Future<Map<String, dynamic>> getUserData() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('user').doc(_currentUser!.uid).get();
    return userDoc.data() as Map<String, dynamic>;
  }

  Future<void> updateUserData(Map<String, String> updatedData) async {
  await FirebaseFirestore.instance.collection('user').doc(_currentUser!.uid).update(updatedData);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: <Widget>[
            _buildTextFieldWithUpdateButton('Name', _nameController),
            _buildTextFieldWithUpdateButton('Surname', _surnameController),
            _buildTextFieldWithUpdateButton('Birthdate', _birthdateController),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFieldWithUpdateButton(String label, TextEditingController controller) {
  return Row(
    children: [
      Expanded(
        child: label == 'Birthdate' ? _buildDateField(label, controller) : _buildTextField(label, controller),
      ),
      TextButton(
        child: Text('Update'),
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
      FocusScope.of(context).requestFocus(new FocusNode());
      final String birthdate = _birthdateController.text;
final DateTime initialDate = birthdate.isEmpty 
  ? DateTime.now() 
  : DateTime.parse('${birthdate.substring(6,10)}-${birthdate.substring(3,5)}-${birthdate.substring(0,2)}');
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