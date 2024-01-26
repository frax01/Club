import 'package:flutter/material.dart';
import 'package:club/pages/club/updateClubEvent/updatePage.dart';

class ClubModifier extends StatelessWidget {
  const ClubModifier({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page Modifier'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: () {
              // Naviga alla pagina UpdateMatches
              Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UpdatePage(level: 'weekend')));
            },
            child: Text('Update Weekend'),
          ),
          ElevatedButton(
            onPressed: () {
              // Naviga alla pagina UpdateCalendars
              Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UpdatePage(level: 'trip')));
            },
            child: Text('Update Trip'),
          ),
          ElevatedButton(
            onPressed: () {
              // Naviga alla pagina UpdateRankings
              Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UpdatePage(level: 'summer')));
            },
            child: Text('Update Summer'),
          ),
          ElevatedButton(
            onPressed: () {
              // Naviga alla pagina UpdateScorers
              Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UpdatePage(level: 'extra')));
            },
            child: Text('Update Extra'),
          ),
        ],
      ),
    );
  }
}
