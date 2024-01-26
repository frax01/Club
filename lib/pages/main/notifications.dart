import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FirebaseMessaging messaging = FirebaseMessaging.instance;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', //title
  importance: Importance.high,
);

class NotificationHandler extends StatelessWidget {
  NotificationHandler({Key? key}) : super(key: key);

  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

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

  //String to = 'francescomartignoni1@gmail.com';
  //String title = 'Tiber';
  //String body = 'ciao';

  Future<void> sendNotification(to, title, body) async {
    print('Sending notification...');
    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'api key',
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
