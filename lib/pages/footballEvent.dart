import 'package:flutter/material.dart';

class FootballEventPage extends StatelessWidget {
  const FootballEventPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Football Event'),
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
              Navigator.pushNamed(context, '/update_calendars');
            },
            child: Text('Update Calendars'),
          ),
          ElevatedButton(
            onPressed: () {
              // Naviga alla pagina UpdateRankings
              Navigator.pushNamed(context, '/update_rankings');
            },
            child: Text('Update Rankings'),
          ),
          ElevatedButton(
            onPressed: () {
              // Naviga alla pagina UpdateScorers
              Navigator.pushNamed(context, '/update_scorers');
            },
            child: Text('Update Scorers'),
          ),
        ],
      ),
    );
  }
}
