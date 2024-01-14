// Importa il pacchetto per il dialog di conferma
import 'package:club/pages/football/calendar/calendarDetails.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'updateCalendarEvent.dart';
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
    _eventsStream = FirebaseFirestore.instance.collection('football_calendar').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Eventi Calendario'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _eventsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          }

          List<QueryDocumentSnapshot> events = snapshot.data!.docs;
          List<String> existingTeams = events.map((e) => (e.data() as Map<String, dynamic>)['team'] as String).toList();
          List<String> teamsWithoutEvent = teams.where((team) => !existingTeams.contains(team)).toList();

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
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UpdateCalendarEventPage(teamName: '${eventData['team']}'),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () async {
                            bool? shouldDelete = await showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Conferma'),
                                  content: Text('Sei sicuro di voler eliminare questo evento?'),
                                  actions: [
                                    TextButton(
                                      child: Text('Annulla'),
                                      onPressed: () {
                                        Navigator.of(context).pop(false);
                                      },
                                    ),
                                    TextButton(
                                      child: Text('Elimina'),
                                      onPressed: () {
                                        Navigator.of(context).pop(true);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );

                            if (shouldDelete == true) {
                              FirebaseFirestore.instance.collection('football_calendar').doc(events[index].id).delete();
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
                      icon: Icon(Icons.add),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EventDetailsPage(title: 'Phoenix United', level: team),
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