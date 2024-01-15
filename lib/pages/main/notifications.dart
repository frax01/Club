import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationHandler extends StatelessWidget {
  NotificationHandler({Key? key}) : super(key: key);

  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Gestisci la notifica quando l'app è in primo piano
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Gestisci la notifica quando l'utente tocca la notifica nell'area di notifica del sistema
    });

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    String? token = await messaging.getToken();
    print('User token: $token');
  }

  String to = 'francescomartignoni1@gmail.com';
  String title = 'Tiber';
  String body = 'ciao';

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
  Widget build(BuildContext context) {
    return Container();
  }
}
