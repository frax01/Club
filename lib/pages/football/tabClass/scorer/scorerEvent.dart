import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScorerEventPage extends StatefulWidget {
  const ScorerEventPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _ScorerEventPageState createState() => _ScorerEventPageState();
}

class _ScorerEventPageState extends State<ScorerEventPage> {
  late CollectionReference<Map<String, dynamic>> _scorerCollection;
  late Stream<QuerySnapshot<Map<String, dynamic>>> _scorersStream;

  String name = '';
  String surname = '';
  String selectedTeam = 'beginner';
  int goalCount = 1;

  @override
  void initState() {
    super.initState();
    _scorerCollection = FirebaseFirestore.instance.collection('football_scorer');
    _scorersStream = _scorerCollection.snapshots();
  }

  Future<void> _showAddDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Aggiungi Scorer'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(labelText: 'Name'),
                    onChanged: (value) {
                      setState(() {
                        name = value;
                      });
                    },
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Surname'),
                    onChanged: (value) {
                      setState(() {
                        surname = value;
                      });
                    },
                  ),
                  DropdownButton<String>(
                    value: selectedTeam,
                    onChanged: (value) {
                      setState(() {
                        selectedTeam = value!;
                      });
                    },
                    items: ['beginner', 'intermediate', 'advanced']
                        .map<DropdownMenuItem<String>>((String team) {
                      return DropdownMenuItem<String>(
                        value: team,
                        child: Text(team),
                      );
                    }).toList(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            goalCount = goalCount + 1;
                          });
                        },
                        child: Icon(Icons.add),
                      ),
                      SizedBox(width: 8.0),
                      Text('$goalCount'),
                      SizedBox(width: 8.0),
                      ElevatedButton(
                        onPressed: () {
                          if (goalCount > 1) {
                            setState(() {
                              goalCount = goalCount - 1;
                            });
                          }
                        },
                        child: Icon(Icons.remove),
                      ),
                    ],
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Annulla'),
                ),
                TextButton(
                  onPressed: () async {
                    // Salvataggio nel Firebase
                    await FirebaseFirestore.instance.collection('football_scorer').add({
                      'name': name,
                      'surname': surname,
                      'team': selectedTeam,
                      'goal': goalCount,
                    });

                    // Torna alla pagina principale
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showDialog(
    String name,
    String surname,
    String selectedTeam,
    int goalCount,
    String scorerId,
  ) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        int localGoalCount = goalCount;
        return AlertDialog(
          title: Text('Modifica Scorer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Name: $name'),
              Text('Surname: $surname'),
              Text('Team: $selectedTeam'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        localGoalCount = localGoalCount + 1;
                      });
                    },
                    child: Icon(Icons.add),
                  ),
                  SizedBox(width: 8.0),
                  Text('$localGoalCount'),
                  SizedBox(width: 8.0),
                  ElevatedButton(
                    onPressed: () {
                      if (localGoalCount > 1) {
                        setState(() {
                          localGoalCount = localGoalCount - 1;
                        });
                      }
                    },
                    child: Icon(Icons.remove),
                  ),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annulla'),
            ),
            TextButton(
              onPressed: () async {
                // Aggiornamento nel Firebase
                await _scorerCollection.doc(scorerId).update({'goal': localGoalCount});

                // Chiudi il dialog
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteScorer(String scorerId) async {
    // Eliminazione nel Firebase
    await _scorerCollection.doc(scorerId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scorer Event Page'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _scorersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          }

          List<QueryDocumentSnapshot<Map<String, dynamic>>> scorers = snapshot.data!.docs;

          return ListView.builder(
            itemCount: scorers.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> scorerData = scorers[index].data();
              String scorerId = scorers[index].id;

              return ListTile(
                title: Text('${scorerData['name']} ${scorerData['surname']}'),
                subtitle: Text('Team: ${scorerData['team']} - Goal: ${scorerData['goal']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        _showDialog(
                          scorerData['name'],
                          scorerData['surname'],
                          scorerData['team'],
                          scorerData['goal'],
                          scorerId,
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _deleteScorer(scorerId);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddDialog();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
