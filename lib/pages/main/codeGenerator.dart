import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserDetailsPage extends StatefulWidget {
  const UserDetailsPage({super.key, required this.title, required this.userEmail});

  final String userEmail;
  final String title;

  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  String selectedRole = "";
  String selectedClubClass = "";
  String selectedSoccerClass = "";
  String selectedStatus = "";

  final List<String> roleOptions = ["", "Boy", "Parent", "Tutor", "Coach"];
  final List<String> clubClassOptions = [
    "",
    "1° media",
    "2° media",
    "3° media"
  ];
  final List<String> soccerClassOptions = [
    "",
    "Beginner",
    "Intermediate",
    "Advanced",
  ];
  final List<String> statusOptions = ["", "User", "Admin"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 130, 16, 8),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User Email: ${widget.userEmail}'),
            SizedBox(height: 16.0),
            buildDropdown("Role", roleOptions, (value) {
              setState(() {
                selectedRole = value.toString();
              });
            }),
            buildDropdown("Club Class", clubClassOptions, (value) {
              setState(() {
                selectedClubClass = value.toString();
              });
            }),
            buildDropdown("Soccer Class", soccerClassOptions, (value) {
              setState(() {
                selectedSoccerClass = value.toString();
              });
            }),
            buildDropdown("Status", statusOptions, (value) {
              setState(() {
                selectedStatus = value.toString();
              });
            }),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                updateUserDetails();
              },
              child: Text('Accept'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDropdown(
      String label, List<String> options, void Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        DropdownButton<String>(
          value: label == "Role"
              ? selectedRole
              : label == "Club Class"
                  ? selectedClubClass
                  : label == "Soccer Class"
                      ? selectedSoccerClass
                      : selectedStatus,
          items: options.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: onChanged,
        ),
        SizedBox(height: 8.0),
      ],
    );
  }

  void updateUserDetails() async {
    try {
      if (selectedRole == "") {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a role')));
        return;
      }
      if (selectedClubClass == "" && selectedSoccerClass == "") {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Please select a club or soccer class')));
        return;
      }
      if (selectedStatus == "") {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a status')));
        return;
      }

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot querySnapshot = await firestore
          .collection('user')
          .where('email', isEqualTo: widget.userEmail)
          .get();
      String documentId = querySnapshot.docs.first.id;

      await FirebaseFirestore.instance
          .collection('user')
          .doc(documentId)
          .update({
        'role': selectedRole,
        'club_class': selectedClubClass,
        'soccer_class': selectedSoccerClass,
        'status': selectedStatus,
      });
      Navigator.pop(context);
    } catch (e) {
      print('Error updating user details: $e');
    }
  }
}
