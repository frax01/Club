import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tab/tabMatch.dart';
import 'tab/tabCalendar.dart';
import 'tab/tabRanking.dart';
import 'tab/tabScorer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:club/pages/main/login.dart';
import 'package:club/pages/club/club.dart';
import 'package:club/pages/main/setting.dart';
import 'package:club/pages/football/tab/tabScorer.dart';

class FootballPage extends StatefulWidget {
  const FootballPage(
      {super.key,
      required this.title,
      required this.document});

  final Map document;
  final String title;

  @override
  State<FootballPage> createState() => _FootballPageState();
}

class _FootballPageState extends State<FootballPage> {
  var section = 'FOOTBALL';
  String _selectedLevel = 'match';

  _saveLastPage(String page) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('lastPage', page);
  }

  Future<void> _logout() async {
    setState(() {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const Login(title: 'Tiber Club', logout: true)));
    });
  }

  String club_class = '';
  String soccer_class = '';

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
          print(email);
          club_class = querySnapshot.docs.first['club_class'];
          soccer_class = querySnapshot.docs.first['soccer_class'];

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
          ),
          body: Center(
            child: Tab(
              page: _selectedLevel,
              document: widget.document,
            )
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
                  child: Image.asset(
                    'images/logo.png',
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
                            return Text(userSurname,
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
                        return Text(userEmail,
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
                    if (club_class != '') {
                      setState(() {
                        section = value.toString();
                        if (section == 'CLUB') {
                          _saveLastPage('ClubPage');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ClubPage(title: 'Tiber Club', document: widget.document)));
                        }
                      });
                    } else {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Non sei ancora iscritto al club')),
                      );
                    }
                  },
                  alignment: AlignmentDirectional.center,
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  underline: Container(
                    height: 0.5,
                    color: Colors.black,
                  ),
                  items: const [
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
                    Icons.settings,
                  ),
                  title: const Text('Settings'),
                  subtitle: Text('Account management',
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
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SettingsPage(id: widget.document['id'],)));
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
                          title: const Text('Logout'),
                          content: const Text('Are you sure you want to logout?'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: const Text('Yes'),
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
          bottomNavigationBar: BottomAppBar(
        color: const Color.fromARGB(255, 130, 16, 8),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            InkWell(
              onTap: () {
                setState(() {
                  _selectedLevel = 'match';
                });
              },
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.calendar_month_outlined, color: Colors.white),
                  Text('Matches', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            InkWell(
               onTap: () {
              setState(() {
                _selectedLevel = 'calendar';
              });
              },
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.calendar_month_outlined, color: Colors.white),
                  Text('Calendar', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                _selectedLevel = 'ranking';
              });
            },
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.calendar_month_outlined, color: Colors.white),
                Text('Rankings', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          InkWell(
              onTap: () {
                setState(() {
                _selectedLevel = 'scorer';
              });
            },
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.calendar_month_outlined, color: Colors.white),
                Text('Top scorers', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          ],
        ),
      ),
        ));
  }
}


class Tab extends StatelessWidget {
  const Tab({super.key, required this.page, required this.document});

  final Map document;
  final String page;

  @override
  Widget build(BuildContext context) {
    if (page=='match') {
      return const TabMatchPage();
    } else if (page=='calendar') {
      return const TabCalendarPage();
    } else if (page=='ranking') {
      return const TabRanking();
    } else {
      return TabScorer(email: document['email'], status: document['status']);
    }
  }
}