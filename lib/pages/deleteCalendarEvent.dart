import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeleteCalendarEventPage extends StatefulWidget {
  const DeleteCalendarEventPage({Key? key}) : super(key: key);

  @override
  _DeleteCalendarEventPageState createState() =>
      _DeleteCalendarEventPageState();
}

class _DeleteCalendarEventPageState extends State<DeleteCalendarEventPage> {
  late Future<QuerySnapshot> _calendarEvents;

  @override
  void initState() {
    super.initState();
    _calendarEvents =
        FirebaseFirestore.instance.collection('football_calendar').get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delete Calendar Event'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: _calendarEvents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No calendar events found.'));
          } else {
            return ListView(
              children: snapshot.data!.docs.map((document) {
                final String teamName = document['team'];
                return ElevatedButton(
                  onPressed: () {
                    _showConfirmationDialog(context, teamName, document.id);
                  },
                  child: Text('Delete $teamName Calendar'),
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }

  Future<void> _showConfirmationDialog(
      BuildContext context, String teamName, String documentId) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Do you want to delete the calendar for $teamName?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _deleteCalendar(documentId);
                Navigator.of(context).pop();
                // Refresh the page after deletion.
                setState(() {
                  _calendarEvents =
                      FirebaseFirestore.instance.collection('football_calendar').get();
                });
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteCalendar(String documentId) async {
    await FirebaseFirestore.instance
        .collection('football_calendar')
        .doc(documentId)
        .delete();
  }
}
