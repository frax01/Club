import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeleteRankingEventPage extends StatefulWidget {
  const DeleteRankingEventPage({Key? key}) : super(key: key);

  @override
  _DeleteRankingEventPageState createState() =>
      _DeleteRankingEventPageState();
}

class _DeleteRankingEventPageState extends State<DeleteRankingEventPage> {
  late Future<QuerySnapshot> _rankingEvents;

  @override
  void initState() {
    super.initState();
    _rankingEvents =
        FirebaseFirestore.instance.collection('football_ranking').get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delete ranking Event'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: _rankingEvents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No ranking events found.'));
          } else {
            return ListView(
              children: snapshot.data!.docs.map((document) {
                final String teamName = document['team'];
                return ElevatedButton(
                  onPressed: () {
                    _showConfirmationDialog(context, teamName, document.id);
                  },
                  child: Text('Delete $teamName ranking'),
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
          content: Text('Do you want to delete the ranking for $teamName?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _deleteRanking(documentId);
                Navigator.of(context).pop();
                // Refresh the page after deletion.
                setState(() {
                  _rankingEvents =
                      FirebaseFirestore.instance.collection('football_ranking').get();
                });
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteRanking(String documentId) async {
    await FirebaseFirestore.instance
        .collection('football_ranking')
        .doc(documentId)
        .delete();
  }
}
