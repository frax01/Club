import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateCalendarPage extends StatefulWidget {
  final String teamName;

  const UpdateCalendarPage({super.key, required this.teamName});

  @override
  _UpdateCalendarPageState createState() =>
      _UpdateCalendarPageState();
}

class _UpdateCalendarPageState extends State<UpdateCalendarPage> {
  List<Map<String, dynamic>> calendarData = [];

  List<TextEditingController> keyControllers = [];
  List<TextEditingController> valueControllers = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('football_calendar')
        .where('team', isEqualTo: widget.teamName)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      Map<String, dynamic> data =
          querySnapshot.docs.first.data() as Map<String, dynamic>;
      calendarData = List<Map<String, dynamic>>.from(data['matches']);
      for (Map<String, dynamic> row in calendarData) {
        String key = row.keys.first;
        String value = row.values.first.toString();
        keyControllers.add(TextEditingController(text: key));
        valueControllers.add(TextEditingController(text: value));
      }
      for (TextEditingController controller in keyControllers) {
        print(controller.text);
      }
      for (TextEditingController controller in valueControllers) {
        print(controller.text);
      }
      print(calendarData);
      setState(() {});
    }
  }

  void _addRow() {
    calendarData.add({'': ''});
    keyControllers.add(TextEditingController());
    valueControllers.add(TextEditingController());
    setState(() {});
  }

  void _deleteRow(int index) {
    calendarData.removeAt(index);
    keyControllers.removeAt(index);
    valueControllers.removeAt(index);
    print(calendarData);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Ranking - ${widget.teamName}'),
      ),
      body: ListView.builder(
        itemCount: calendarData.length,
        itemBuilder: (context, index) {
          return Row(
            children: [
              Expanded(
                child: TextField(
                  controller: keyControllers[index],
                  decoration: const InputDecoration(labelText: 'Key'),
                ),
              ),
              const SizedBox(width: 8.0),
              const Text('vs'),
              const SizedBox(width: 8.0),
              Expanded(
                child: TextField(
                  controller: valueControllers[index],
                  decoration: const InputDecoration(labelText: 'Value'),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteRow(index),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            onPressed: _addRow,
            heroTag: null,
            child: const Icon(Icons.add), // Needed to use multiple FABs.
          ),
          const SizedBox(height: 10), // Add some space between the FABs.
          FloatingActionButton(
            onPressed: _updateNewMatches,
            heroTag: null,
            child: const Icon(Icons.save), // Needed to use multiple FABs.
          ),
        ],
      ),
    );
  }

  Future<void> _updateNewMatches() async {
    if (keyControllers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aggiungi almeno una partita')));
      return;
    }

    bool hasEmptyField =
        keyControllers.any((controller) => controller.text.isEmpty) ||
            valueControllers.any((controller) => controller.text.isEmpty);

    if (hasEmptyField) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Errore: uno o più campi sono vuoti.')));
      return;
    }

    List<Map<String, String>> newMatches = [];
    for (int i = 0; i < keyControllers.length; i++) {
      newMatches.add({keyControllers[i].text: valueControllers[i].text});
    }

    print(newMatches);

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('football_calendar')
        .where('team', isEqualTo: widget.teamName)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot doc = querySnapshot.docs.first;
      await doc.reference.delete();
    }

    await FirebaseFirestore.instance.collection('football_calendar').doc().set({
      'team': widget.teamName,
      'matches': newMatches,
    });
  }
}

//import 'package:flutter/material.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
//
//class UpdateCalendarEventPage extends StatefulWidget {
//  final String teamName;
//
//  UpdateCalendarEventPage({required this.teamName});
//
//  @override
//  _UpdateCalendarEventPageState createState() =>
//      _UpdateCalendarEventPageState();
//}
//
//class _UpdateCalendarEventPageState extends State<UpdateCalendarEventPage> {
//  late Map<String, TextEditingController> _controllers = {};
//  late Map<String, TextEditingController> _valueControllers = {};
//  late Map<String, String> _matches = {};
//
//  @override
//  void initState() {
//    super.initState();
//    _loadMatches();
//  }
//
//  Future<void> _loadMatches() async {
//    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//        .collection('football_calendar')
//        .where('team', isEqualTo: widget.teamName)
//        .get();
//
//    if (querySnapshot.docs.isNotEmpty) {
//      DocumentSnapshot doc = querySnapshot.docs.first;
//      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//      _matches = Map<String, String>.from(data['matches']);
//      _matches.forEach((key, value) {
//        _controllers[key] = TextEditingController(text: key);
//        _valueControllers[key] = TextEditingController(text: value);
//      });
//      setState(() {});
//    }
//  }
//
//  void _addRow() {
//    String key = '';
//    _controllers[key] = TextEditingController();
//    _valueControllers[key] = TextEditingController();
//    _matches[key] = '';
//    setState(() {});
//  }
//
//  void _deleteRow(String key) {
//    _controllers.remove(key);
//    _valueControllers.remove(key);
//    _matches.remove(key);
//    setState(() {});
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(
//        title: Text(widget.teamName),
//      ),
//      body: ListView(
//        children: _controllers.keys.map((key) {
//          return Row(
//            children: [
//              Expanded(
//                child: TextField(
//                  controller: _controllers[key],
//                  decoration: InputDecoration(labelText: 'Chiave'),
//                ),
//              ),
//              const SizedBox(width: 8.0),
//              Text('vs'),
//              const SizedBox(width: 8.0),
//              Expanded(
//                child: TextField(
//                  controller: _valueControllers[key],
//                  decoration: InputDecoration(labelText: 'Valore'),
//                ),
//              ),
//              IconButton(
//                icon: Icon(Icons.delete),
//                onPressed: () => _deleteRow(key),
//              ),
//            ],
//          );
//        }).toList(),
//      ),
//      floatingActionButton: Column(
//        mainAxisAlignment: MainAxisAlignment.end,
//        children: <Widget>[
//          FloatingActionButton(
//            onPressed: _addRow,
//            child: Icon(Icons.add),
//            heroTag: null, // Needed to use multiple FABs.
//          ),
//          SizedBox(height: 10), // Add some space between the FABs.
//          FloatingActionButton(
//            onPressed: _updateNewMatches,
//            child: Icon(Icons.save),
//            heroTag: null, // Needed to use multiple FABs.
//          ),
//        ],
//      ),
//    );
//  }
//
//  Future<void> _updateNewMatches() async {
//    bool hasEmptyField = _controllers.values
//            .any((controller) => controller.text.isEmpty) ||
//        _valueControllers.values.any((controller) => controller.text.isEmpty);
//
//    if (hasEmptyField) {
//      ScaffoldMessenger.of(context).showSnackBar(
//          SnackBar(content: Text('Errore: uno o più campi sono vuoti.')));
//      return;
//    }
//
//    List<Map<String, String>> newMatches = [];
//_controllers.forEach((key, controller) {
//  newMatches.add({controller.text: _valueControllers[key]!.text});
//});
//
//    print(newMatches);
//
//    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//        .collection('football_calendar')
//        .where('team', isEqualTo: widget.teamName)
//        .get();
//
//    if (querySnapshot.docs.isNotEmpty) {
//      DocumentSnapshot doc = querySnapshot.docs.first;
//      await doc.reference.delete();
//    }
//
//    await FirebaseFirestore.instance.collection('football_calendar').doc().set({
//      'team': widget.teamName,
//      'matches': newMatches,
//    });
//  }
//}