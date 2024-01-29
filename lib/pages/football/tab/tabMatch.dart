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

  final _res1Controller = TextEditingController();
  final _res2Controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMatchesData();
  }

  //void updateOpponent() async {
  //  final team = _matchesData[_currentPage]['team'];
  //  print("ecco$team");
//
  //  if (_matchesData.where((match) => match.length == 2).length ==
  //      _matchesData.length) {
  //    final matchQuery = FirebaseFirestore.instance
  //        .collection('football_match')
  //        .where('team', isEqualTo: team);
  //    final matchQuerySnapshot = await matchQuery.get();
//
  //    // Prendi il primo documento corrispondente e aggiorna opponent a ''
  //    final matchDocumentSnapshot = matchQuerySnapshot.docs.first;
  //    await matchDocumentSnapshot.reference.update({'opponent': ''});
  //  }
  //}

  Future<void> _updateFootballCalendar(
      String team1, String team2, String res1, String res2) async {
    final documentReference = FirebaseFirestore.instance
        .collection('football_calendar')
        .doc(_matchesData[_currentPage]['team']);
    final DocumentSnapshot documentSnapshot = await documentReference.get();

    String teamController = _matchesData[_currentPage]['team'];

    List<dynamic> matchesData =
        (documentSnapshot.data() as Map<String, dynamic>)['matches'];
    List<Map<String, dynamic>> matches =
        matchesData.map((item) => item as Map<String, dynamic>).toList();

    print(matchesData);

    int index = matches.indexWhere((match) => match[team1] == team2);

    matches[index] = {res1: res2, team1: team2};
    print(matches);

    await documentReference.update({'matches': matches});

    String opponent = "";
    if (matches.where((match) => match.length == 2).length ==
        matchesData.length) {
      opponent = "";
      updateMatchDetails(teamController, opponent);
    } else if (index < matches.length - 1 && matches[index + 1].length == 1) {
      index++;
      opponent = matches[index].keys.first + " vs " + matches[index].values.first;
      updateMatchDetails(teamController, opponent);
      print('Update eseguito con successo');
    } else if (index == matches.length - 1) {
      int count = 0;
      while (count < matches.length - 1) {
        if (matches[count].length == 1) {
          opponent = matches[count].keys.first + " vs " + matches[count].values.first;
          updateMatchDetails(teamController, opponent);
          print('Update eseguito con successo');
          break;
        }
        count++;
      }
    }
  }

  void updateMatchDetails(String team, String opponent) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot querySnapshot = await firestore
          .collection('football_match')
          .where('team', isEqualTo: team)
          .get();
      String documentId = querySnapshot.docs.first.id;
      await FirebaseFirestore.instance
          .collection('football_match')
          .doc(documentId)
          .update({
        'team': team,
        'opponent': opponent,
      });
    } catch (e) {
      print('Error updating user details: $e');
    }
  }

  Future<void> _fetchMatchesData() async {
    // Ottieni i dati della collezione 'football_match'
    final QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('football_match').get();

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
    print(_matchesData.length);
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: heightScreen / 1.5,
            child: _matchesData.isNotEmpty
                ? PageView.builder(
                    controller: _pageController,
                    itemCount: _matchesData.length,
                    itemBuilder: (context, index) {
                      print(_currentPage);
                      print(_matchesData);
                      print(_matchesData[_currentPage]['team']);

                      if (_matchesData[index]['opponent'] == '') {
                        return Center(
                          child: Text("non ci sono più partite da giocare"),
                        );
                      } else {
                        return Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: widthScreen / 2,
                                height: heightScreen / 12,
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        5.0), // Regola il raggio per ottenere bordi arrotondati
                                  ),
                                  child: Center(
                                    child: Text(
                                        '${_matchesData[index]['team']}',
                                        style: TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ),
                              Image.asset(
                                _matchesData[index]['image'],
                                width: widthScreen / 5,
                                height: heightScreen / 5,
                              ),
                              Container(
                                width: widthScreen / 2,
                                height: heightScreen / 8,
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        5.0), // Regola il raggio per ottenere bordi arrotondati
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                          '${_matchesData[index]['opponent']}'),
                                      Text('${_matchesData[index]['place']}'),
                                      Text('${_matchesData[index]['time']}'),
                                    ],
                                  ),
                                ),
                              ),
                              TextField(
                                controller: _res1Controller,
                                decoration: InputDecoration(labelText: 'Res1'),
                                keyboardType: TextInputType.number,
                              ),
                              Text('-'),
                              TextField(
                                controller: _res2Controller,
                                decoration: InputDecoration(labelText: 'Res2'),
                                keyboardType: TextInputType.number,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  if (_res1Controller.text.isNotEmpty &&
                                      _res2Controller.text.isNotEmpty) {
                                    final opponent =
                                        _matchesData[_currentPage]['opponent'];
                                    final teams = opponent.split(' vs ');
                                    final team1 = teams[0];
                                    final team2 = teams[1];

                                    _updateFootballCalendar(
                                        team1,
                                        team2,
                                        _res1Controller.text,
                                        _res2Controller.text);
                                  }
                                  setState(() {}); //non mi aggiorna la pagina
                                },
                                child: Text('Update'),
                              ),
                            ],
                          ),
                        );
                      }
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
                  duration: Duration(
                      milliseconds: 300), // Imposta la durata dell'animazione
                  curve: Curves
                      .easeInOut, // Imposta la curva di animazione desiderata
                );
              },
            ),
        ],
      ),
    );
  }
}

//import 'package:flutter/material.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:dots_indicator/dots_indicator.dart';
//
//class TabMatchPage extends StatefulWidget {
//  @override
//  _TabMatchPageState createState() => _TabMatchPageState();
//}
//
//class _TabMatchPageState extends State<TabMatchPage> {
//  List<Map<String, dynamic>> _matchesData = [];
//  final _pageController = PageController();
//  int _currentPage = 0;
//
//  final _res1Controller = TextEditingController();
//  final _res2Controller = TextEditingController();
//
//  @override
//  void initState() {
//    super.initState();
//    _fetchMatchesData();
//  }
//
//  Future<void> _updateFootballCalendar(
//      String team1, String team2, String res1, String res2) async {
//    final documentReference = FirebaseFirestore.instance
//        .collection('football_calendar')
//        .doc(_matchesData[_currentPage]['team']);
//    final DocumentSnapshot documentSnapshot = await documentReference.get();
//
//    String teamController = _matchesData[_currentPage]['team'];
//
//    List<dynamic> matchesData =
//        (documentSnapshot.data() as Map<String, dynamic>)['matches'];
//    List<Map<String, dynamic>> matches =
//        matchesData.map((item) => item as Map<String, dynamic>).toList();
//
//    String opponent = "";
//    //if (matchesData.where((match) => match.length == 2).length == matchesData.length - 1) {
//    //  opponent = "end of the calendar";
//    //}
//
//    print(opponent);
//
//    print(matchesData);
//
//    int index = matches.indexWhere((match) => match[team1] == team2);
//
//    matches[index] = {res1: res2, team1: team2};
//
//    await documentReference.update({'matches': matches, "played": true});
//
//    print("ciao${matches[index].length}");
//
//    //Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
//    //bool played = data['played'];
//    //print(played);
//    if (index < matches.length - 1 && matches[index + 1].length == 1) {
//      index++;
//      opponent =
//          matches[index].keys.first + " vs " + matches[index].values.first;
//      updateMatchDetails(teamController, opponent);
//      print('Update eseguito con successo');
//    } else if (index == matches.length - 1) {
//      int count = 0;
//      while (count < matches.length - 1) {
//        if (matches[count].length == 1) {
//          opponent =
//              matches[count].keys.first + " vs " + matches[count].values.first;
//          updateMatchDetails(teamController, opponent);
//          print('Update eseguito con successo');
//          break;
//        }
//        count++;
//      }
//    }
//  }
//
//  void updateMatchDetails(String team, String opponent) async {
//    try {
//      FirebaseFirestore firestore = FirebaseFirestore.instance;
//      QuerySnapshot querySnapshot = await firestore
//          .collection('football_match')
//          .where('team', isEqualTo: team)
//          .get();
//      String documentId = querySnapshot.docs.first.id;
//      await FirebaseFirestore.instance
//          .collection('football_match')
//          .doc(documentId)
//          .update({
//        'team': team,
//        'opponent': opponent,
//        //'place': locationController, da fare sopra
//      });
//    } catch (e) {
//      print('Error updating user details: $e');
//    }
//  }
//
//  Future<void> _fetchMatchesData() async {
//    // Ottieni i dati della collezione 'football_match'
//    final QuerySnapshot querySnapshot =
//        await FirebaseFirestore.instance.collection('football_match').get();
//
//    setState(() {
//      _matchesData = querySnapshot.docs.map((DocumentSnapshot document) {
//        return document.data() as Map<String, dynamic>;
//      }).toList();
//    });
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    var size = MediaQuery.of(context).size;
//    var widthScreen = size.width;
//    var heightScreen = size.height;
//    print(_matchesData.length);
//    String opponent = "";
//    return Scaffold(
//      body: Column(
//        children: [
//          Container(
//            height: heightScreen / 1.5,
//            child: _matchesData.isNotEmpty
//                ? PageView.builder(
//                    controller: _pageController,
//                    itemCount: _matchesData.length,
//                    itemBuilder: (context, index) {
//                      print(_currentPage);
//                      print(_matchesData);
//                      print(_matchesData[_currentPage]['team']);
//                      //final documentReference = FirebaseFirestore.instance
//                      //    .collection('football_calendar')
//                      //    .doc(_matchesData[_currentPage]['team']);
//                      final documentReference = FirebaseFirestore.instance
//                          .collection('football_calendar')
//                          .doc(_matchesData[_currentPage]['team']);
//                      final Future<DocumentSnapshot> documentSnapshot =
//                          documentReference.get();
//                      print(documentSnapshot);
//
//                      final Future<QuerySnapshot> query = FirebaseFirestore
//                          .instance
//                          .collection('football_match')
//                          .where('team',
//                              isEqualTo: _matchesData[_currentPage]['team'])
//                          .get();
//
//                      query.then((querySnapshot) {
//                        if (querySnapshot.docs.isNotEmpty) {
//                          DocumentSnapshot documentSnapshot1 =
//                              querySnapshot.docs.first;
//                          opponent = documentSnapshot1['opponent'];
//                        }
//                      });
//
//                      return FutureBuilder<DocumentSnapshot>(
//                        future: documentSnapshot,
//                        builder: (BuildContext context,
//                            AsyncSnapshot<DocumentSnapshot> snapshot) {
//                          if (snapshot.connectionState ==
//                              ConnectionState.done) {
//                            List<dynamic> matchesData = (snapshot.data!.data()
//                                as Map<String, dynamic>)['matches'];
//                            print(matchesData);
//                            if (matchesData
//                                    .every((match) => match.length == 2) ||
//                                opponent == "") {
//                              return Center(
//                                child:
//                                    Text("non ci sono più partite da giocare"),
//                              );
//                            } else {
//                              return Padding(
//                                padding: EdgeInsets.all(16.0),
//                                child: Column(
//                                  crossAxisAlignment: CrossAxisAlignment.center,
//                                  children: [
//                                    Container(
//                                      width: widthScreen / 2,
//                                      height: heightScreen / 12,
//                                      child: Card(
//                                        shape: RoundedRectangleBorder(
//                                          borderRadius: BorderRadius.circular(
//                                              5.0), // Regola il raggio per ottenere bordi arrotondati
//                                        ),
//                                        child: Center(
//                                          child: Text(
//                                              '${_matchesData[index]['team']}',
//                                              style: TextStyle(
//                                                  fontSize: 18.0,
//                                                  fontWeight: FontWeight.bold)),
//                                        ),
//                                      ),
//                                    ),
//                                    Image.asset(
//                                      _matchesData[index]['image'],
//                                      width: widthScreen / 5,
//                                      height: heightScreen / 5,
//                                    ),
//                                    Container(
//                                      width: widthScreen / 2,
//                                      height: heightScreen / 8,
//                                      child: Card(
//                                        shape: RoundedRectangleBorder(
//                                          borderRadius: BorderRadius.circular(
//                                              5.0), // Regola il raggio per ottenere bordi arrotondati
//                                        ),
//                                        child: Column(
//                                          children: [
//                                            Text(
//                                                '${_matchesData[index]['opponent']}'),
//                                            Text(
//                                                '${_matchesData[index]['place']}'),
//                                            Text(
//                                                '${_matchesData[index]['time']}'),
//                                          ],
//                                        ),
//                                      ),
//                                    ),
//                                    TextField(
//                                      controller: _res1Controller,
//                                      decoration:
//                                          InputDecoration(labelText: 'Res1'),
//                                      keyboardType: TextInputType.number,
//                                    ),
//                                    Text('-'),
//                                    TextField(
//                                      controller: _res2Controller,
//                                      decoration:
//                                          InputDecoration(labelText: 'Res2'),
//                                      keyboardType: TextInputType.number,
//                                    ),
//                                    ElevatedButton(
//                                      onPressed: () {
//                                        if (_res1Controller.text.isNotEmpty &&
//                                            _res2Controller.text.isNotEmpty) {
//                                          final opponent =
//                                              _matchesData[_currentPage]
//                                                  ['opponent'];
//                                          final teams = opponent.split(' vs ');
//                                          final team1 = teams[0];
//                                          final team2 = teams[1];
//
//                                          _updateFootballCalendar(
//                                              team1,
//                                              team2,
//                                              _res1Controller.text,
//                                              _res2Controller.text);
//                                        }
//                                        setState(
//                                            () {}); //non mi aggiorna la pagina
//                                      },
//                                      child: Text('Update'),
//                                    ),
//                                  ],
//                                ),
//                              );
//                            }
//                          } else {
//                            return Text('Something went wrong');
//                          }
//                        },
//                      );
//                    },
//                    onPageChanged: (int index) {
//                      setState(() {
//                        _currentPage = index;
//                      });
//                    },
//                  )
//                : Center(
//                    child: Text('Nessun elemento disponibile'),
//                  ),
//          ),
//          if (_matchesData.isNotEmpty)
//            DotsIndicator(
//              dotsCount: _matchesData.length,
//              position: _currentPage.toDouble(),
//              decorator: DotsDecorator(
//                size: const Size.square(9.0),
//                activeSize: const Size(18.0, 9.0),
//                color: Colors.black26,
//                activeColor: Colors.black,
//              ),
//              onTap: (position) {
//                _pageController.animateToPage(
//                  position.toInt(),
//                  duration: Duration(
//                      milliseconds: 300), // Imposta la durata dell'animazione
//                  curve: Curves
//                      .easeInOut, // Imposta la curva di animazione desiderata
//                );
//              },
//            ),
//        ],
//      ),
//    );
//  }
//}
//
//