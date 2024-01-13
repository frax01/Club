import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dots_indicator/dots_indicator.dart';

class TabMatchPage extends StatefulWidget {
  @override
  _TabMatchPageState createState() => _TabMatchPageState();
}

class _TabMatchPageState extends State<TabMatchPage> {
  List<Map<String, dynamic>> _matchesData = [];
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _fetchMatchesData();
  }

  Future<void> _fetchMatchesData() async {
    // Ottieni i dati della collezione 'football_match'
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('football_match')
        .get();

    setState(() {
      _matchesData = querySnapshot.docs.map((DocumentSnapshot document) {
        return document.data() as Map<String, dynamic>;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var widthScreen = size.width;
    var heightScreen = size.height;
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: heightScreen,
            child: _matchesData.isNotEmpty
            ? PageView.builder(
              controller: _pageController,
              itemCount: _matchesData.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.all(0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: widthScreen/2,
                        height: heightScreen/12,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0), // Regola il raggio per ottenere bordi arrotondati
                          ),
                          child: Center(
                            child: Text('${_matchesData[index]['team']}', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                      Image.asset(_matchesData[index]['image'], width: widthScreen/1.75, height: heightScreen/1.75,),
                      Container(
                        width: widthScreen/2,
                        height: heightScreen/8,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0), // Regola il raggio per ottenere bordi arrotondati
                          ),
                          child: Column(
                            children: [
                              Text('${_matchesData[index]['opponent']}'),
                              Text('${_matchesData[index]['place']}'),
                              Text('${_matchesData[index]['time']}'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              onPageChanged: (int index) {
                setState(() {
                  _currentPage = index;
                });
              },
            )
            : Center(
                  child: Text('Nessun elemento disponibile'),
                ),
          ),
          if (_matchesData.isNotEmpty)
            DotsIndicator(
              dotsCount: _matchesData.length,
              position: _currentPage.toDouble(),
              decorator: DotsDecorator(
                size: const Size.square(9.0),
                activeSize: const Size(18.0, 9.0),
                color: Colors.black26,
                activeColor: Colors.black,
              ),
              onTap: (position) {
                _pageController.animateToPage(
                  position.toInt(),
                  duration: Duration(milliseconds: 300), // Imposta la durata dell'animazione
                  curve: Curves.easeInOut, // Imposta la curva di animazione desiderata
                );
              },
            ),
        ],
      ),
    );
  }
}