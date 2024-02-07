import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewRankingPage extends StatefulWidget {
  final String level;

  const NewRankingPage({super.key, required this.level});

  @override
  _NewRankingPageState createState() => _NewRankingPageState();
}

class _NewRankingPageState extends State<NewRankingPage> {
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
                style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16.0),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Numero di squadre'),
              onChanged: (value) {
                setState(() {
                  numberOfTeams = int.tryParse(value) ?? 0;
                  teamsData = List.generate(
                      numberOfTeams, (index) => {'': 0});
                });
              },
            ),
            const SizedBox(height: 16.0),
            if (numberOfTeams > 0)
              Column(
                children: [
                  for (int i = 0; i < numberOfTeams; i++)
                    _buildTeamRow(i + 1, teamsData[i]),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _confirmChanges,
                    child: const Text('Conferma'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamRow(int teamNumber, Map<String, dynamic> teamData) {
    String teamName = teamData.keys.first;
    int teamScore = teamData.values.first;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text('$teamNumber.'),
          const SizedBox(width: 16.0),
          Expanded(
            child: TextField(
              onChanged: (value) {
                setState(() {
                  teamData.remove(teamName);
                  teamName = value;
                  teamData[teamName] = teamScore;
                });
              },
              decoration: const InputDecoration(labelText: 'Nome squadra'),
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  teamScore = int.tryParse(value) ?? 0;
                  teamData[teamName] = teamScore;
                });
              },
              decoration:
                  const InputDecoration(labelText: 'Punteggio', hintText: '0'),
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
    Navigator.of(context).pop();
    print('Changes confirmed');
  }
}
