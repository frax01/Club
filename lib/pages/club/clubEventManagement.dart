import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/pages/club/clubEvent.dart';

class ClubNewEventPage extends StatefulWidget {
  const ClubNewEventPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _ClubEventPageState createState() => _ClubEventPageState();
}

class _ClubEventPageState extends State<ClubNewEventPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<String> collections = ['club_extra', 'club_summer', 'club_trip', 'club_weekend'];

  Future<void> deleteDocument(String collection, String docId) async {
    await _firestore.collection(collection).doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: collections.length,
        itemBuilder: (context, index) {
          return StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection(collections[index]).snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text("Loading");
              }

              return Column(
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                  String documentId = document.id;
                  String Option = data['selectedOption'];
                  return Card(
                    child: ListTile(
                      title: Text(data['title']),
                      subtitle: Text('Class: ${data['selectedClass']}, Option: ${data['selectedOption']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClubEventPage(documentId: documentId, Option: Option,),
                              ),
                            );
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
                                deleteDocument(collections[index], document.id);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/event');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}