import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tab/tabMatch.dart';
import 'tab/tabCalendar.dart';
import 'tab/tabRanking.dart';
import 'tab/tabScorer.dart';
import 'package:club/pages/main/pageFolder.dart';

class FootballPage extends StatefulWidget {
  const FootballPage({super.key, required this.title});

  final String title;

  @override
  State<FootballPage> createState() => _FootballPageState();
}

class _FootballPageState extends State<FootballPage> {
  var section = 'FOOTBALL';

  Future<void> _logout() async {
    setState(() {
      Navigator.pushNamed(context, '/login');
    });
  }

  Future<List<String>> getUserData() async {
    List<String> userData = [];

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        CollectionReference users =
            FirebaseFirestore.instance.collection('user');
        QuerySnapshot querySnapshot =
            await users.where('email', isEqualTo: user.email).get();

        if (querySnapshot.docs.isNotEmpty) {
          var name = querySnapshot.docs.first['name'];
          var surname = querySnapshot.docs.first['surname'];
          var email = querySnapshot.docs.first['email'];

          userData = [name, surname, email];
        }
      }
    } catch (e) {
      print('Error getting user data: $e');
    }

    return userData;
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;
    return DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title:
                Text(widget.title, style: const TextStyle(color: Colors.white)),
            backgroundColor: const Color.fromARGB(255, 130, 16, 8),
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.white),
            bottom: const TabBar(
              tabs: [
                Tab(
                  icon: Column(
                    children: [
                      Icon(Icons.car_crash, color: Colors.white),
                      Text('Matches', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                Tab(
                  icon: Column(
                    children: [
                      Icon(Icons.sports_soccer_outlined, color: Colors.white),
                      Text('Calendar', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                Tab(
                  icon: Column(
                    children: [
                      Icon(Icons.calendar_month, color: Colors.white),
                      Text('Rankings', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                Tab(
                  icon: Column(
                    children: [
                      Icon(Icons.sports_soccer_outlined, color: Colors.white),
                      Text('Top scorers',
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              // Contenuto per il Tab 1
              TabMatchPage(),
              //Icon(Icons.directions_car, size: 150, color: Colors.red),
              // Contenuto per il Tab 2
              TabCalendarPage(),
              //Icon(Icons.directions_transit, size: 150, color: Colors.brown),
              // Contenuto per il Tab 3
              //TabCalendarPage(),
              TabRanking(),

              //Icon(Icons.directions_bike, size: 150, color: Colors.teal),
              // Contenuto per il Tab 4
              TabScorer(),
            ],
          ),
          drawer: Drawer(
            width: width > 700
                ? width / 3
                : width > 400
                    ? width / 2
                    : width / 1.5,
            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image(
                    image: const AssetImage('images/photo.jpg'),
                    width: width > 700 ? width / 4 : width / 8,
                    height: height / 4,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FutureBuilder<List<String>>(
                          future: getUserData(),
                          builder: (context, snapshot) {
                            var userName = snapshot.data?[0] ?? '';
                            return Text('$userName ',
                                style:
                                    TextStyle(fontSize: width > 300 ? 18 : 14));
                          }),
                      FutureBuilder<List<String>>(
                          future: getUserData(),
                          builder: (context, snapshot) {
                            var userSurname = snapshot.data?[1] ?? '';
                            return Text('$userSurname',
                                style:
                                    TextStyle(fontSize: width > 300 ? 18 : 14));
                          }),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                  child: FutureBuilder<List<String>>(
                      future: getUserData(),
                      builder: (context, snapshot) {
                        var userEmail = snapshot.data?[2] ?? '';
                        return Text('$userEmail',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: width > 500
                                    ? 14
                                    : width > 300
                                        ? 10
                                        : 8));
                      }),
                ),
                DropdownButton(
                  value: section,
                  onChanged: (value) {
                    setState(() {
                      section = value.toString();
                      if (section == 'CLUB') {
                        Navigator.pushNamed(context, '/club');
                      }
                    });
                  },
                  alignment: AlignmentDirectional.center,
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  underline: Container(
                    height: 0.5,
                    color: Colors.black,
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'CLUB',
                      child: Text('CLUB'),
                    ),
                    DropdownMenuItem(
                      value: 'FOOTBALL',
                      child: Text('FOOTBALL'),
                    ),
                  ],
                ),
                ListTile(
                  leading: const Icon(
                    Icons.calendar_month_outlined,
                  ),
                  title: const Text('Tournaments'),
                  subtitle: Text('Just do it', style: TextStyle(fontSize: width > 700? 12 : width > 500? 14 : width > 400? 11 : width > 330? 12 : 10)),
                  onTap: () {
                    Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PageFolder(title: 'ASD Tiber Club', level: 'tournament', option: 'football')));
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.plus_one_outlined,
                  ),
                  title: const Text('Extra'),
                  subtitle: Text('What are you waiting for?', style: TextStyle(fontSize: width > 700? 12 : width > 500? 14 : width > 400? 11 : width > 330? 12 : 10)),
                  onTap: () {
                    Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PageFolder(title: 'ASD Tiber Club', level: 'extra', option: 'football')));
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.settings,
                  ),
                  title: const Text('Settings'),
                  subtitle: Text('Account management', style: TextStyle(fontSize: width > 700? 12 : width > 500? 14 : width > 400? 11 : width > 330? 12 : 10)),
                  onTap: () {
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.code,
                  ),
                  title: const Text('Code generation'),
                  subtitle: Text('Accept new users',
                      style: TextStyle(
                          fontSize: width > 700
                              ? 12
                              : width > 500
                                  ? 14
                                  : width > 400
                                      ? 11
                                      : width > 330
                                          ? 12
                                          : 10)),
                  onTap: () {
                    Navigator.pushNamed(context, '/acceptance');
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.mode,
                  ),
                  title: const Text('Page modifier'),
                  subtitle: Text('Modify information!',
                      style: TextStyle(
                          fontSize: width > 700
                              ? 12
                              : width > 500
                                  ? 14
                                  : width > 400
                                      ? 11
                                      : width > 330
                                          ? 12
                                          : 10)),
                  onTap: () {
                    Navigator.pushNamed(context, '/football_modifier');
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.logout,
                  ),
                  title: const Text('Logout'),
                  subtitle: Text('We will miss you...',
                      style: TextStyle(
                          fontSize: width > 700
                              ? 12
                              : width > 500
                                  ? 14
                                  : width > 400
                                      ? 11
                                      : width > 330
                                          ? 12
                                          : 10)),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Logout'),
                          content: Text('Are you sure you want to logout?'),
                          actions: <Widget>[
                            TextButton(
                              child: Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text('Yes'),
                              onPressed: () async {
                                await _logout();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        )
      );
  }
}
