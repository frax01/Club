// tabScorer.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TabScorer extends StatefulWidget {
  const TabScorer({Key? key}) : super(key: key);

  @override
  _TabScorerState createState() => _TabScorerState();
}

class _TabScorerState extends State<TabScorer> {
  late Stream<QuerySnapshot> _scorersStream;

  @override
  void initState() {
    super.initState();
    _scorersStream = FirebaseFirestore.instance.collection('football_scorer').orderBy('goal', descending: true).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scorers'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _scorersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          }

          List<QueryDocumentSnapshot> scorers = snapshot.data!.docs;

          return ListView.builder(
            itemCount: scorers.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> scorerData =
                  scorers[index].data() as Map<String, dynamic>;

              return Card(
                child: ListTile(
                  title: Text('${scorerData['name']} ${scorerData['surname']}'),
                  subtitle: Text('Team: ${scorerData['team']}, Goals: ${scorerData['goal']}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}