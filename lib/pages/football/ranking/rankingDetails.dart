import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RankingDetailsPage extends StatefulWidget {
  final String level;

  RankingDetailsPage({super.key, required this.level});

  @override
  _RankingDetailsPageState createState() => _RankingDetailsPageState();
}

class _RankingDetailsPageState extends State<RankingDetailsPage> {
  int numberOfTeams = 0;
  List<Map<String, dynamic>> teamsData = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ranking Details - ${widget.level}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Team: ${widget.level}',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
            SizedBox(height: 16.0),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Numero di squadre'),
              onChanged: (value) {
                setState(() {
                  numberOfTeams = int.tryParse(value) ?? 0;
                  teamsData = List.generate(
                      numberOfTeams, (index) => {'name': '', 'score': 0});
                });
              },
            ),
            SizedBox(height: 16.0),
            if (numberOfTeams > 0)
              Column(
                children: [
                  for (int i = 0; i < numberOfTeams; i++)
                    _buildTeamRow(i + 1, teamsData[i]),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _confirmChanges,
                    child: Text('Conferma'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamRow(int teamNumber, Map<String, dynamic> teamData) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text('$teamNumber.'),
          SizedBox(width: 16.0),
          Expanded(
            child: TextField(
              onChanged: (value) {
                setState(() {
                  teamData['name'] = value;
                });
              },
              decoration: InputDecoration(labelText: 'Nome squadra'),
            ),
          ),
          SizedBox(width: 16.0),
          Expanded(
            child: TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  teamData['score'] = int.tryParse(value) ?? 0;
                });
              },
              decoration:
                  InputDecoration(labelText: 'Punteggio', hintText: '0'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmChanges() async {
    // Update the document in Firebase
    await FirebaseFirestore.instance
        .collection('football_ranking')
        .doc(widget.level)
        .set({
      'team': widget.level,
      'ranking': teamsData,
    });

    // Navigate back or perform any other action
    // ...

    print('Changes confirmed');
  }
}
