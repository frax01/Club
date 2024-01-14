import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dots_indicator/dots_indicator.dart';

class TabRanking extends StatefulWidget {
  const TabRanking({super.key});
  
  @override
  _TabRankingState createState() => _TabRankingState();
}

class _TabRankingState extends State<TabRanking> {
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
        future: FirebaseFirestore.instance.collection('football_ranking').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          }

          List<QueryDocumentSnapshot> rankings = snapshot.data!.docs;

          return Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: rankings.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> rankingData =
                        rankings[index].data() as Map<String, dynamic>;
                    List<MapEntry<String, dynamic>> rankingEntries =
                        rankingData['ranking'].entries.toList();

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Team: ${rankingData['team']}',
                            style: TextStyle(
                                fontSize: 20.0, fontWeight: FontWeight.bold)),
                        SizedBox(height: 16.0),
                        Expanded(
                          child: ListView.builder(
                            itemCount: rankingEntries.length,
                            itemBuilder: (context, index) {
                              MapEntry<String, dynamic> entry =
                                  rankingEntries[index];
                              return ListTile(
                                title: Text(entry.key),
                                subtitle: Text('Punteggio: ${entry.value}'),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                ),
              ),
              DotsIndicator(
                dotsCount: rankings.length,
                position: _currentPage.toDouble(),
                decorator: DotsDecorator(
                  size: const Size.square(9.0),
                  activeSize: const Size(18.0, 9.0),
                  color: Colors.black26,
                  activeColor: Colors.black,
                  spacing: const EdgeInsets.all(3.0),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
