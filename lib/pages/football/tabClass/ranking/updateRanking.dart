import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateRankingPage extends StatefulWidget {
  final String teamName;

  const UpdateRankingPage({Key? key, required this.teamName}) : super(key: key);

  @override
  _UpdateRankingPageState createState() => _UpdateRankingPageState();
}

class _UpdateRankingPageState extends State<UpdateRankingPage> {
  List<Map<String, dynamic>> rankingData = [];

  List<TextEditingController> keyControllers = [];
  List<TextEditingController> valueControllers = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('football_ranking')
        .where('team', isEqualTo: widget.teamName)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      Map<String, dynamic> data =
          querySnapshot.docs.first.data() as Map<String, dynamic>;
      rankingData = List<Map<String, dynamic>>.from(data['ranking']);
      for (Map<String, dynamic> row in rankingData) {
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
      print(rankingData);
      setState(() {});
    }
  }

  void _addRow() {
    rankingData.add({'': ''});
    keyControllers.add(TextEditingController());
    valueControllers.add(TextEditingController());
    setState(() {});
  }

  void _deleteRow(int index) {
    rankingData.removeAt(index);
    keyControllers.removeAt(index);
    valueControllers.removeAt(index);
    print(rankingData);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Ranking - ${widget.teamName}'),
      ),
      body: ListView.builder(
        itemCount: rankingData.length,
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

    List<Map<String, String>> newRankings = [];
    for (int i = 0; i < keyControllers.length; i++) {
      newRankings.add({keyControllers[i].text: valueControllers[i].text});
    }

    print(newRankings);

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('football_ranking')
        .where('team', isEqualTo: widget.teamName)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot doc = querySnapshot.docs.first;
      await doc.reference.delete();
    }

    await FirebaseFirestore.instance.collection('football_ranking').doc().set({
      'team': widget.teamName,
      'ranking': newRankings,
    });
  }
}
