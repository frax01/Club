import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateCalendarEventPage extends StatefulWidget {
  final String teamName;

  UpdateCalendarEventPage({required this.teamName});

  @override
  _UpdateCalendarEventPageState createState() =>
      _UpdateCalendarEventPageState();
}

class _UpdateCalendarEventPageState extends State<UpdateCalendarEventPage> {
  late Map<String, TextEditingController> _controllers = {};
  late Map<String, String> _matches = {};

  @override
  void initState() {
    super.initState();
    _fetchMatches();
  }

  Future<void> _fetchMatches() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('football_calendar')
        .where('team', isEqualTo: widget.teamName)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot doc = querySnapshot.docs.first;

      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      if (data?.containsKey('matches') ?? false) {
        print(doc['matches']);
        Map<String, dynamic> matches = doc['matches'];
        _controllers = matches.map(
            (key, value) => MapEntry(key, TextEditingController(text: value)));
        _matches = matches.cast<String, String>();
      } else {
        // Handle the case where the document does not have a 'matches' field
      }
    } else {
      // Handle the case where no documents with team=teamName were found
    }
  }

  void _addRow() {
    String key = '';
    _controllers[key] = TextEditingController();
    _matches[key] = '';
  }

  void _deleteRow(String key) {
    setState(() {
      _controllers.remove(key);
      _matches.remove(key);
    });
  }

  Future<void> _updateMatches() async {
    await FirebaseFirestore.instance
        .collection('football_calendar')
        .doc(widget.teamName)
        .update({'matches': _matches});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  appBar: AppBar(
    title: Text(widget.teamName),
  ),
  body: FutureBuilder(
    future: _fetchMatches(),
    builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      } else {
        return ListView(
          children: _controllers.keys.map((key) {
            return Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controllers[key],
                    decoration: InputDecoration(labelText: 'Chiave'),
                    onChanged: (value) {
                      _matches[value] = _matches.remove(key)!;
                    },
                  ),
                ),
                const SizedBox(width: 8.0),
                Text('vs'),
                const SizedBox(width: 8.0),
                Expanded(
                  child: TextField(
                    // Rest of your code...
                  ),
                ),
              ],
            );
          }).toList(),
        );
      }
    },
  ),
);
  }
}
