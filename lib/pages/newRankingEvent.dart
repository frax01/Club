import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'rankingDetails.dart';

class NewRankingEventPage extends StatefulWidget {
  const NewRankingEventPage({super.key, required this.title});

  final String title;

  @override
  _NewRankingEventPageState createState() => _NewRankingEventPageState();
}

class _NewRankingEventPageState extends State<NewRankingEventPage> {
  bool beginnerVisible = true;
  bool intermediateVisible = true;
  bool advancedVisible = true;

  @override
  void initState() {
    super.initState();
    _updateButtonVisibility();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ranking Events'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (beginnerVisible)
              ElevatedButton(
                onPressed: () => _navigateToEventPage(context, 'beginner'),
                child: Text('Beginner'),
              ),
            if (intermediateVisible)
              ElevatedButton(
                onPressed: () => _navigateToEventPage(context, 'intermediate'),
                child: Text('Intermediate'),
              ),
            if (advancedVisible)
              ElevatedButton(
                onPressed: () => _navigateToEventPage(context, 'advanced'),
                child: Text('Advanced'),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToEventPage(BuildContext context, String level) async {
    // Naviga a un'altra pagina passando il livello come parametro.
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RankingDetailsPage(level),
      ),
    );

    // Aggiorna la visibilità dei bottoni quando si torna indietro.
    _updateButtonVisibility();
  }

  Future<void> _updateButtonVisibility() async {
    final beginnerExists = await _checkDocumentExists('beginner');
    final intermediateExists = await _checkDocumentExists('intermediate');
    final advancedExists = await _checkDocumentExists('advanced');

    setState(() {
      beginnerVisible = !beginnerExists;
      intermediateVisible = !intermediateExists;
      advancedVisible = !advancedExists;
    });
  }

  Future<bool> _checkDocumentExists(String level) async {
    // Controlla se esiste un documento con il campo "team" uguale al livello.
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('football_ranking')
        .where('team', isEqualTo: level)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }
}