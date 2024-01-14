import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateCalendarEvent extends StatefulWidget {
  final String teamName;

  const UpdateCalendarEvent({Key? key, required this.teamName})
      : super(key: key);

  @override
  _UpdateCalendarEventState createState() => _UpdateCalendarEventState();
}

class _UpdateCalendarEventState extends State<UpdateCalendarEvent> {
  List<MapEntry<String, dynamic>> _matches = [];
  final List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    _fetchMatches();
  }

Future<void> _fetchMatches() async {
  // Fetch matches from Firebase
  final DocumentSnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance
          .collection('football_calendar')
          .doc(widget.teamName)
          .get();

  if (snapshot.exists) {
    final Map<String, dynamic> matches = snapshot.data()!['matches'];
    _matches = matches.entries.map((entry) {
      final controller = TextEditingController(text: entry.value);
      _controllers.add(controller);
      return MapEntry(entry.key, controller);
    }).toList();
  }

  setState(() {});
}


  void _deleteRow(int index) {
    setState(() {
      _matches.removeAt(index);
      _controllers.removeAt(index);
    });
  }

  void _addRow() {
    setState(() {
      _matches.add(MapEntry('', ''));
      _controllers.add(TextEditingController());
    });
  }

  Future<void> _confirmChanges() async {
    // Create a new map with updated values
    final Map<String, dynamic> newMatches = {};
    for (int i = 0; i < _matches.length; i++) {
      final String key = _controllers[i].text;
      final String value = _matches[i].value;

      if (key.isNotEmpty) {
        newMatches[key] = value;
      }
    }

    // Update the document in Firebase
    await FirebaseFirestore.instance
        .collection('football_calendar')
        .doc(widget.teamName)
        .set({
      'matches': newMatches,
      'team': widget.teamName,
    });

    // Navigate back or perform any other action
    // ...

    print('Changes confirmed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Calendar Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            for (int i = 0; i < _matches.length; i++) _buildRow(i),
            ElevatedButton(
              onPressed: _addRow,
              child: Text('Aggiungi riga'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _confirmChanges,
              child: Text('Conferma'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controllers[index],
              decoration: InputDecoration(labelText: 'Chiave'),
            ),
          ),
          const SizedBox(width: 8.0),
          Text('vs'),
          const SizedBox(width: 8.0),
          Expanded(
            child: TextField(
              onChanged: (value) =>
                  _matches[index] = MapEntry(_controllers[index].text, value),
              decoration: InputDecoration(labelText: 'Valore'),
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _deleteRow(index),
          ),
        ],
      ),
    );
  }
}
