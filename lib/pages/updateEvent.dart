import 'package:club/pages/updateCalendarEvent.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateEvent extends StatefulWidget {
  const UpdateEvent({super.key});

  @override
  _UpdateEventState createState() => _UpdateEventState();
}

class _UpdateEventState extends State<UpdateEvent> {
  List<String> teamNames = [];

  @override
  void initState() {
    super.initState();
    _fetchTeamNames();
  }

  Future<void> _fetchTeamNames() async {
    final QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('football_calendar').get();

    setState(() {
      teamNames = querySnapshot.docs
          .map((DocumentSnapshot document) => document['team'] as String)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aggiorna Evento'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (String teamName in teamNames)
              ElevatedButton(
                onPressed: () {
                  // Implementa la logica per aggiornare l'evento associato a teamName.
                  Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateCalendarEvent(teamName: teamName),
                  ),
                );
                },
                child: Text(teamName),
              ),
          ],
        ),
      ),
    );
  }
}
