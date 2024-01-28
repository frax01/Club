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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rankings'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('football_calendar').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
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

                    List<Map<String, dynamic>> rankingList =List<Map<String, dynamic>>.from(rankingData['matches']);


                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Team: ${rankingData['team']}',
                            style: TextStyle(
                                fontSize: 20.0, fontWeight: FontWeight.bold)),
                        SizedBox(height: 16.0),
                        Expanded(
                          child: ListView.builder(
                            itemCount: rankingList.length,
                            itemBuilder: (context, listViewIndex) {
                              return Card(
                                elevation: 4.0,
                                margin: EdgeInsets.all(8.0),
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      Text('${rankingList[listViewIndex].keys.first} vs ${rankingList[listViewIndex].values.first}'),
                                      SizedBox(width: 10),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        DotsIndicator(
                          dotsCount: calendars.length,
                          position: _currentPage.toDouble(),
                          decorator: DotsDecorator(
                            size: const Size.square(9.0),
                            activeSize: const Size(18.0, 9.0),
                            color: Colors.black26,
                            activeColor: Colors.black,
                            spacing: const EdgeInsets.all(3.0),
                          ),
                          onTap: (position) {
                            _pageController.animateToPage(
                              position.toInt(),
                              duration: Duration(milliseconds: 300), // Imposta la durata dell'animazione
                              curve: Curves.easeInOut, // Imposta la curva di animazione desiderata
                            );
                            setState(() {
                              _currentPage = position.toInt();
                            });
                          },
                        ),
                      ],
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

//import 'package:flutter/material.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:dots_indicator/dots_indicator.dart';
//
//class TabCalendarPage extends StatefulWidget {
//  const TabCalendarPage({super.key});
//
//  @override
//  _TabCalendarPageState createState() => _TabCalendarPageState();
//}
//
//class _TabCalendarPageState extends State<TabCalendarPage> {
//  List<Map<String, dynamic>> _calendarData = [];
//  final PageController _pageController = PageController();
//  int _currentPage = 0;
//
//  @override
//  void initState() {
//    super.initState();
//    _fetchCalendarData();
//  }
//
//  Future<void> _fetchCalendarData() async {
//    final QuerySnapshot querySnapshot =
//        await FirebaseFirestore.instance.collection('football_calendar').get();
//
//    setState(() {
//      _calendarData = querySnapshot.docs
//          .map((DocumentSnapshot document) =>
//              document.data() as Map<String, dynamic>)
//          .toList();
//    });
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(
//        title: Text('Calendar Partite'),
//      ),
//      body: Column(
//        crossAxisAlignment: CrossAxisAlignment.stretch,
//        children: [
//          Expanded(
//            child: PageView.builder(
//              controller: _pageController,
//              itemCount: _calendarData.length,
//              itemBuilder: (context, index) {
//                final team = _calendarData[index]['team'];
//                final matches = _calendarData[index]['matches'];
//
//                return Column(
//                  crossAxisAlignment: CrossAxisAlignment.stretch,
//                  children: [
//                    Padding(
//                      padding: EdgeInsets.all(16.0),
//                      child: Text(
//                        'Team: $team',
//                        style: TextStyle(
//                            fontSize: 18, fontWeight: FontWeight.bold),
//                      ),
//                    ),
//                    if (matches != null && matches is Map)
//                      ...matches.entries.map((entry) {
//                        return Card(
//                          elevation: 4.0,
//                          margin: EdgeInsets.all(8.0),
//                          child: Padding(
//                            padding: EdgeInsets.all(16.0),
//                            child: Row(
//                              children: [
//                                Text('${entry.key} vs ${entry.value}'),
//                                SizedBox(width: 10),
//                              ],
//                            ),
//                          ),
//                        );
//                      }).toList(),
//                  ],
//                );
//              },
//              onPageChanged: (int index) {
//                setState(() {
//                  _currentPage = index;
//                });
//              },
//            ),
//          ),
//          if (_calendarData.isNotEmpty)
//            DotsIndicator(
//              dotsCount: _calendarData.length,
//              position: _currentPage.toDouble(),
//              decorator: DotsDecorator(
//                color: Colors.grey[400]!, // Inattivi
//                activeColor: Colors.blue, // Attivo
//              ),
//              onTap: (position) {
//                _pageController.animateToPage(
//                  position.toInt(),
//                  duration: Duration(milliseconds: 300),
//                  curve: Curves.ease,
//                );
//              },
//            ),
//        ],
//      ),
//    );
//  }
//}