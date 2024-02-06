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

  //
  //import 'package:firebase_messaging/firebase_messaging.dart';
  //import 'package:flutter_local_notifications/flutter_local_notifications.dart';
  //import 'package:http/http.dart' as http;
  //import 'dart:convert';

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