import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/pages/main/pageFolder.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:club/pages/main/login.dart';

class ClubPage extends StatefulWidget {
  const ClubPage({super.key, required this.title});

  final String title;

  @override
  State<ClubPage> createState() => _ClubPageState();
}

class _ClubPageState extends State<ClubPage> {
  var section = 'CLUB';

  _saveLastPage(String page) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('lastPage', page);
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    //await prefs.clear();
    setState(() {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Login(title: 'Tiber Club', logout: true)));
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

  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> sendNotification(to, title, body) async {
    print('Sending notification...');
    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'AIzaSyAkmPm2DpVcfIg6uXMUuj7uLIxGd371qqM',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{'body': body, 'title': title},
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done'
          },
          'to': to,
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    sendNotification('E2KfozhFBUaAPslgo5Us29Gpswn2', 'ciaoooo', 'ciaoooooo');

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', //title
      importance: Importance.high,
    );

    Future<void> initialize() async {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;

        final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
            FlutterLocalNotificationsPlugin();

        if (notification != null && android != null) {
          flutterLocalNotificationsPlugin.show(
              notification.hashCode,
              notification.title,
              notification.body,
              NotificationDetails(
                android: AndroidNotificationDetails(
                  channel.id,
                  channel.name,
                  icon: android.smallIcon,
                  // other properties...
                ),
              ));
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        // Gestisci la notifica quando l'utente tocca la notifica nell'area di notifica del sistema
      });

      //NotificationSettings settings = await messaging.requestPermission(
      //  alert: true,
      //  badge: true,
      //  sound: true,
      //);

      String? token = await messaging.getToken();
      print('User token: $token');
    }

    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    //var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
  }

  static Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
    print('Got a message whilst in the background!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  }

  final FirebaseInAppMessaging inAppMessaging = FirebaseInAppMessaging.instance;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 130, 16, 8),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text('Trigger In-App Message'),
          onPressed: () {
            inAppMessaging.triggerEvent('test_event');
          },
        ),
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
                image: const AssetImage('images/logo.png'),
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
                            style: TextStyle(fontSize: width > 300 ? 18 : 14));
                      }),
                  FutureBuilder<List<String>>(
                      future: getUserData(),
                      builder: (context, snapshot) {
                        var userSurname = snapshot.data?[1] ?? '';
                        return Text('$userSurname',
                            style: TextStyle(fontSize: width > 300 ? 18 : 14));
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
                if (soccer_class != '') {
                  setState(() {
                    section = value.toString();
                    if (section == 'FOOTBALL') {
                      _saveLastPage('FootballPage');
                      Navigator.pushNamed(context, '/football');
                    }
                  });
                } else {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Non fai ancora parte di una squadra')),
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
                Icons.calendar_month_outlined,
              ),
              title: const Text('Weekend'),
              subtitle: Text('Look at the program',
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
                        builder: (context) => PageFolder(
                            title: 'Tiber Club',
                            level: 'weekend',
                            option: 'club')));
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.holiday_village_outlined,
              ),
              title: const Text('Trips'),
              subtitle: Text('Where does your class go?',
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
                        builder: (context) => PageFolder(
                            title: 'Tiber Club',
                            level: 'trip',
                            option: 'club')));
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.sunny,
              ),
              title: const Text('Summer'),
              subtitle: Text('The best period of the year',
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
                        builder: (context) => PageFolder(
                            title: 'Tiber Club',
                            level: 'summer',
                            option: 'club')));
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.plus_one_outlined,
              ),
              title: const Text('Extra'),
              subtitle: Text('What are you waiting for?',
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
                        builder: (context) => PageFolder(
                            title: 'Tiber Club',
                            level: 'extra',
                            option: 'club')));
              },
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
              subtitle: Text('Create a new program!',
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
                Navigator.pushNamed(context, '/club_modifier');
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
    );
  }
}
