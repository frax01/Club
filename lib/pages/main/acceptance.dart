import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'codeGenerator.dart';

class AcceptancePage extends StatefulWidget {
  const AcceptancePage({super.key, required this.title});

  final String title;

  @override
  _AcceptancePageState createState() => _AcceptancePageState();
}

class _AcceptancePageState extends State<AcceptancePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 130, 16, 8),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: UserList(),
    );
  }
}

class UserList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('user').where('role', isEqualTo: '').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('Nessun utente da accettare'),
          );
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var userData = snapshot.data!.docs[index];
            var userEmail = userData['email'];
            return ListTile(
              title: Text(userEmail),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => UserDetailsPage(title: 'Tiber Club', userEmail: userEmail)));
              },
            );
          },
        );
      },
    );
  }
}
