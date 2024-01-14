import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RankingEventPage extends StatelessWidget {
  const RankingEventPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ranking Event'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                _checkDocumentCount(context, '/newRankingEvent', 3);
              },
              child: Text('Nuovo Evento'),
            ),
            ElevatedButton(
              onPressed: () {
                _checkDocumentCount(context, '/updateEvent', 0);
              },
              child: Text('Aggiorna Evento'),
            ),
            ElevatedButton(
              onPressed: () {
                _checkDocumentCount(context, '/deleteRankingEvent', 0);
              },
              child: Text('Cancella Evento'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkDocumentCount(
      BuildContext context, String route, int allowedCount) async {
    final QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('football_ranking').get();

    if (querySnapshot.size != allowedCount) {
      Navigator.pushNamed(context, route);
    } else {
      // Mostra un messaggio di errore.
      ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Non è possibile creare altre classifiche'),
                      ),
                    );
    }
  }
}
