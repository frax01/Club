import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dots_indicator/dots_indicator.dart';

class TabCalendarPage extends StatefulWidget {
  const TabCalendarPage({super.key});

  @override
  _TabCalendarPageState createState() => _TabCalendarPageState();
}

class _TabCalendarPageState extends State<TabCalendarPage> {
  List<Map<String, dynamic>> _calendarData = [];
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _fetchCalendarData();
  }

  Future<void> _fetchCalendarData() async {
    final QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('football_calendar').get();

    setState(() {
      _calendarData = querySnapshot.docs
          .map((DocumentSnapshot document) =>
              document.data() as Map<String, dynamic>)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar Partite'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _calendarData.length,
              itemBuilder: (context, index) {
                final team = _calendarData[index]['team'];
                final matches = _calendarData[index]['matches'];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Team: $team',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (matches != null && matches is Map)
                      ...matches.entries.map((entry) {
                        return Card(
                          elevation: 4.0,
                          margin: EdgeInsets.all(8.0),
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Text('${entry.key} vs ${entry.value}'),
                                SizedBox(width: 10),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                  ],
                );
              },
              onPageChanged: (int index) {
                setState(() {
                  _currentPage = index;
                });
              },
            ),
          ),
          if (_calendarData.isNotEmpty)
            DotsIndicator(
              dotsCount: _calendarData.length,
              position: _currentPage.toDouble(),
              decorator: DotsDecorator(
                color: Colors.grey[400]!, // Inattivi
                activeColor: Colors.blue, // Attivo
              ),
              onTap: (position) {
                _pageController.animateToPage(
                  position.toInt(),
                  duration: Duration(milliseconds: 300),
                  curve: Curves.ease,
                );
              },
            ),
        ],
      ),
    );
  }
}
