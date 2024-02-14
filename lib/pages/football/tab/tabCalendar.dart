import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dots_indicator/dots_indicator.dart';

class TabCalendarPage extends StatefulWidget {
  const TabCalendarPage({super.key});

  @override
  _TabCalendarPageState createState() => _TabCalendarPageState();
}

class _TabCalendarPageState extends State<TabCalendarPage> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  Future<String> funzione(team) async {
    final firestore = FirebaseFirestore.instance;
    final opponentQuerySnapshot = await firestore
        .collection('football_match')
        .where('team', isEqualTo: team)
        .get();
    if (opponentQuerySnapshot.docs.isEmpty) {
      throw Exception('No documents found');
    }

    final documentSnapshot = opponentQuerySnapshot.docs.first;
    final opponent = documentSnapshot.data()['opponent'] as String;
    return opponent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rankings'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future:
            FirebaseFirestore.instance.collection('football_calendar').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          }

          List<QueryDocumentSnapshot> calendars = snapshot.data!.docs;

          return Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: calendars.length,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  itemBuilder: (context, index) {
                    Map<String, dynamic> rankingData =
                        calendars[_currentPage].data() as Map<String, dynamic>;

                    List<Map<String, dynamic>> rankingList =
                        List<Map<String, dynamic>>.from(rankingData['matches']);
                    print("rankingggg: $rankingList");

                    return FutureBuilder<String>(
                      future: funzione(rankingData['team']),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }

                        if (snapshot.hasError) {
                          return Text('Errore: ${snapshot.error}');
                        }

                        String vs = snapshot.data!;

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Team: ${rankingData['team']}',
                                style: const TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16.0),
                            Expanded(
                              child: ListView.builder(
                                itemCount: rankingList.length,
                                itemBuilder: (context, listViewIndex) {
                                  String match = '';
                                  String score = '';
                                  if (rankingList[listViewIndex].length == 1) {
                                    match =
                                        '${rankingList[listViewIndex].keys.first} vs ${rankingList[listViewIndex].values.first}';
                                  } else {
                                    score = 
                                      '${rankingList[listViewIndex].keys.first} vs ${rankingList[listViewIndex].values.first}';
                                    match =
                                        '${rankingList[listViewIndex].keys.elementAt(1)} vs ${rankingList[listViewIndex].values.elementAt(1)}';
                                  }
                                  if (score == '') {
                                    return Card(
                                      color: vs == match ? Colors.green : null,
                                      elevation: 4.0,
                                      margin: const EdgeInsets.all(8.0),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Row(
                                          children: [
                                            Text(match),
                                            const SizedBox(width: 10),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                  else {
                                    return Card(
                                      color: vs == match ? Colors.green : null,
                                      elevation: 4.0,
                                      margin: const EdgeInsets.all(8.0),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Row(
                                          children: [
                                            Text('$match $score'),
                                            const SizedBox(width: 10),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                            DotsIndicator(
                              dotsCount: calendars.length,
                              position: _currentPage.toDouble(),
                              decorator: const DotsDecorator(
                                size: Size.square(9.0),
                                activeSize: Size(18.0, 9.0),
                                color: Colors.black26,
                                activeColor: Colors.black,
                                spacing: EdgeInsets.all(3.0),
                              ),
                              onTap: (position) {
                                _pageController.animateToPage(
                                  position.toInt(),
                                  duration: const Duration(
                                      milliseconds:
                                          300), // Imposta la durata dell'animazione
                                  curve: Curves
                                      .easeInOut, // Imposta la curva di animazione desiderata
                                );
                                setState(() {
                                  _currentPage = position.toInt();
                                });
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}