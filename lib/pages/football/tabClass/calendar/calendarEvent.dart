// Importa il pacchetto per il dialog di conferma
import 'package:club/pages/football/tabClass/calendar/newCalendar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'updateCalendar.dart';
//import 'newCalendarEvent.dart';

class CalendarEventPage extends StatefulWidget {
  const CalendarEventPage({super.key, required this.title});

  final String title;

  @override
  _CalendarEventState createState() => _CalendarEventState();
}

class _CalendarEventState extends State<CalendarEventPage> {
  late Stream<QuerySnapshot> _eventsStream;
  final List<String> teams = ['beginner', 'intermediate', 'advanced'];

  @override
  void initState() {
    super.initState();
    _eventsStream =
        FirebaseFirestore.instance.collection('football_calendar').snapshots();
  }

  Future<void> _clearOpponentField(String teamName) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('football_match')
        .where('team', isEqualTo: teamName)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
      await documentSnapshot.reference.update({'opponent': ""});
    } else {
      print("No document found with team name: $teamName");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eventi Calendario'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _eventsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          }

          List<QueryDocumentSnapshot> events = snapshot.data!.docs;
          List<String> existingTeams = events
              .map((e) => (e.data() as Map<String, dynamic>)['team'] as String)
              .toList();
          List<String> teamsWithoutEvent =
              teams.where((team) => !existingTeams.contains(team)).toList();

          return ListView.builder(
            itemCount: events.length + teamsWithoutEvent.length,
            itemBuilder: (context, index) {
              if (index < events.length) {
                Map<String, dynamic> eventData =
                    events[index].data() as Map<String, dynamic>;

                return Card(
                  child: ListTile(
                    title: Text('${eventData['team']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            // Ottieni la CollectionReference
                            CollectionReference colRef = FirebaseFirestore
                                .instance
                                .collection('football_calendar');

                            // Utilizza la clausola where per ottenere i documenti con 'team' uguale a eventData['team']
                            QuerySnapshot querySnapshot = await colRef
                                .where('team',
                                    isEqualTo: '${eventData['team']}')
                                .get();

                            // Controlla se esiste un documento che soddisfa la condizione
                            if (querySnapshot.docs.isNotEmpty) {
                              // Prendi il primo documento che soddisfa la condizione
                              DocumentSnapshot docSnapshot =
                                  querySnapshot.docs.first;
                              Map<String, dynamic> docData =
                                  docSnapshot.data() as Map<String, dynamic>;

                              // Controlla se esiste una mappa con 2 elementi nella lista 'matches'
                              List matches = docData['matches'];
                              bool hasTwoElements =
                                  matches.any((match) => match.length == 2);

                              if (hasTwoElements) {
                                // Mostra uno SnackBar se esiste una mappa con 2 elementi
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Il campionato è già cominciato, non puoi modificarlo')),
                                );
                              } else {
                                // Naviga alla pagina di aggiornamento del calendario se non esiste una mappa con 2 elementi
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UpdateCalendarPage(
                                        teamName: '${eventData['team']}'),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            bool? shouldDelete = await showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Conferma'),
                                  content: const Text(
                                      'Sei sicuro di voler eliminare questo evento?'),
                                  actions: [
                                    TextButton(
                                      child: const Text('Annulla'),
                                      onPressed: () {
                                        Navigator.of(context).pop(false);
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('Elimina'),
                                      onPressed: () {
                                        Navigator.of(context).pop(true);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );

                            if (shouldDelete == true) {
                              FirebaseFirestore.instance
                                  .collection('football_calendar')
                                  .doc(events[index].id)
                                  .delete();
                              _clearOpponentField(eventData['team']);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                String team = teamsWithoutEvent[index - events.length];

                return Card(
                  child: ListTile(
                    title: Text(team),
                    trailing: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NewCalendarPage(
                                title: 'Phoenix United', level: team),
                          ),
                        );
                      },
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
