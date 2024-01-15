import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationHandler {
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
}