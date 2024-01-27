import 'package:flutter/material.dart';
import 'package:club/pages/main/updateEvent/updatePage.dart';

class FootballModifier extends StatelessWidget {
  const FootballModifier({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Football Modifier'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: () {
              // Naviga alla pagina UpdateMatches
              Navigator.pushNamed(context, '/matchEvent');
            },
            child: Text('Update Matches'),
          ),
          ElevatedButton(
            onPressed: () {
              // Naviga alla pagina UpdateCalendars
              Navigator.pushNamed(context, '/calendarEvent');
            },
            child: Text('Update Calendars'),
          ),
          ElevatedButton(
            onPressed: () {
              // Naviga alla pagina UpdateRankings
              Navigator.pushNamed(context, '/rankingEvent');
            },
            child: Text('Update Rankings'),
          ),
          ElevatedButton(
            onPressed: () {
              // Naviga alla pagina UpdateScorers
              Navigator.pushNamed(context, '/scorerEvent');
            },
            child: Text('Update Scorers'),
          ),
          ElevatedButton(
            onPressed: () {
              // Naviga alla pagina NewEvent
              Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UpdatePage(level: 'tournament', section: 'football',)));
            },
            child: Text('Update Tournament'),
          ),
          ElevatedButton(
            onPressed: () {
              // Naviga alla pagina NewEvent
              Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UpdatePage(level: 'extra', section: 'football',)));
            },
            child: Text('Updated Extra'),
          ),
        ],
      ),
    );
  }
}
