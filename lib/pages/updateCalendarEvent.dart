import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateCalendarEvent extends StatefulWidget {
  const UpdateCalendarEvent({super.key, required this.teamName});

  final String teamName;

  @override
  _UpdateCalendarEventState createState() => _UpdateCalendarEventState();
}

class _UpdateCalendarEventState extends State<UpdateCalendarEvent> {
  List<MapEntry<String, String>> matchDetails = [];

  @override
  void initState() {
    super.initState();
    // Esempio: Recupera il documento associato al team dalla tabella 'football_calendar'.
    FirebaseFirestore.instance
        .collection('football_calendar')
        .where('team', isEqualTo: widget.teamName)
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.size > 0) {
        // Estrai le informazioni sulla partita dal documento.
        Map<String, dynamic>? data =
            querySnapshot.docs.first.data() as Map<String, dynamic>?;
        List<MapEntry<String, dynamic>> matches =
            (data?['matches'] as Map<String, dynamic>).entries.toList();

        // Inizializza la lista di matchDetails con le informazioni estratte.
        matchDetails = matches
            .map((entry) => MapEntry(entry.key, entry.value.toString()))
            .toList();

        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Event - ${widget.teamName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Visualizza le informazioni sulla partita.
            if (matchDetails.isNotEmpty)
              Column(
                children: [
                  for (var match in matchDetails)
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: TextEditingController(text: match.key),
                            decoration: InputDecoration(labelText: 'Team 1'),
                          ),
                        ),
                        Text('vs'),
                        Expanded(
                          child: TextField(
                            controller:
                                TextEditingController(text: match.value),
                            onChanged: (value) {
                              // Aggiorna il valore nella lista matchDetails.
                              matchDetails[matchDetails.indexOf(match)] =
                                  MapEntry(match.key, value);
                            },
                            decoration: InputDecoration(labelText: 'Team 2'),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            // Bottone '+' per aggiungere una nuova riga.
            ElevatedButton(
              onPressed: () {
                setState(() {
                  matchDetails.add(MapEntry('', ''));
                });
              },
              child: Text('Aggiungi riga'),
            ),
            // Bottone 'Update' per aggiornare la partita nel database.
            ElevatedButton(
              onPressed: () {
                _updateEvent();
              },
              child: Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

Future<void> _updateEvent() async {
  // Ottieni un riferimento al documento associato al team dalla tabella 'football_calendar'.
  final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('football_calendar')
      .where('team', isEqualTo: widget.teamName)
      .get();

  // Verifica che ci sia almeno un documento.
  if (querySnapshot.size > 0) {
    final DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
    
    // Ottieni l'ID del documento.
    final String documentId = documentSnapshot.id;

    // Crea una nuova mappa 'matches' da matchDetails.
    Map<String, dynamic> newMatches = {};
    matchDetails.forEach((entry) {
      newMatches[entry.key] = entry.value;
    });

    // Aggiorna le informazioni sulla partita nel database.
    await FirebaseFirestore.instance
        .collection('football_calendar')
        .doc(documentId)
        .update({'matches': newMatches});
  }
}


  Map<String, dynamic> _convertMapToMatches() {
    // Converte la lista di matchDetails in una mappa adatta per il database.
    return Map.fromEntries(
      matchDetails.map((entry) => MapEntry(entry.key, entry.value)),
    );
  }
}
