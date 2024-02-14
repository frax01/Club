import 'package:flutter/material.dart';

class FootballModifier extends StatelessWidget {
  const FootballModifier({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Football Modifier'),
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
            child: const Text('Update Matches'),
          ),
          ElevatedButton(
            onPressed: () {
              // Naviga alla pagina UpdateCalendars
              Navigator.pushNamed(context, '/calendarEvent');
            },
            child: const Text('Update Calendars'),
          ),
          ElevatedButton(
            onPressed: () {
              // Naviga alla pagina UpdateRankings
              Navigator.pushNamed(context, '/rankingEvent');
            },
            child: const Text('Update Rankings'),
          ),
        ],
      ),
    );
  }
}
