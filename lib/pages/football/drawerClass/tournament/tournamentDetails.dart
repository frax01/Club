import 'package:club/pages/football/updateFootballEvent/updateEvent.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/pages/club/addClubEvent/event.dart';
import 'package:club/pages/football/addFootballEvent/event.dart';

class TournamentUpdatePage extends StatefulWidget {
  const TournamentUpdatePage({Key? key, required this.level}) : super(key: key);

  final String level;

  @override
  _TournamentUpdatePageState createState() => _TournamentUpdatePageState();
}

class _TournamentUpdatePageState extends State<TournamentUpdatePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> deleteDocument(String collection, String docId) async {
    await _firestore.collection(collection).doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar Update Event'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('football_tournament').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length + 1, // +1 for the add button
            itemBuilder: (context, index) {
              if (index == snapshot.data!.docs.length) {
                // The last item is the add button
                return IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => NewEventPage(title: 'Phoenix Club', level: widget.level)));
                  },
                );
              }

              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              
              String documentId = doc.id;
              String Option = data['selectedOption'];

              return Card(
                child: ListTile(
                  title: Text(data['title']),
                  subtitle: Text(data['selectedClass']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UpdateEventPage(
                                        documentId: documentId,
                                        Option: Option,
                                      )));
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                              bool? shouldDelete = await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Confirm'),
                                    content: Text('Are you sure you want to delete this item?'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text('Cancel'),
                                        onPressed: () {
                                          Navigator.of(context).pop(false);
                                        },
                                      ),
                                      TextButton(
                                        child: Text('Delete'),
                                        onPressed: () {
                                          Navigator.of(context).pop(true);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                              if (shouldDelete == true) {
                                deleteDocument('football_tournament', documentId);
                              }
                            },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
