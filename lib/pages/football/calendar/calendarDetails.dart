import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventDetailsPage extends StatefulWidget {
  EventDetailsPage({super.key, required this.title, required this.level});
  final String level;
  final String title;

  @override
  _EventDetailsPageState createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  int numberOfMatches = 0;
  Map<int, Map<String, String>> matchDetails = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dettagli Evento - ${widget.level}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  numberOfMatches = int.tryParse(value) ?? 1;
                  matchDetails = Map.fromEntries(
                    List.generate(
                        numberOfMatches, (index) => MapEntry(index, {})),
                  );
                });
              },
              decoration: InputDecoration(
                labelText: 'Numero di partite',
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: numberOfMatches,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              matchDetails[index]?['team1'] = value;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Team 1',
                          ),
                        ),
                      ),
                      Text('vs'),
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              matchDetails[index]?['team2'] = value;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Team 2',
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _addMatchesToCalendar();
              },
              child: Text('Aggiungi al calendario'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addMatchesToCalendar() async {
    // Aggiungi i dettagli delle partite a football_calendar.
    await FirebaseFirestore.instance.collection('football_calendar').add({
      'team': widget.level,
      'matches': matchDetails.map((key, match) {
        return MapEntry('${match['team1']}', '${match['team2']}');
      }),
    });

    // Torna alla pagina precedente.
    Navigator.pop(context);
  }
}
