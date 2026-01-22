import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MyNotificationService{
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  void requestNotificationPermission()async{
    NotificationSettings notificationSettings = await firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      criticalAlert: true,
      sound: true
    );

    if(notificationSettings.authorizationStatus == AuthorizationStatus.authorized) {
      print("permission granted by user");
    }
    else if(notificationSettings.authorizationStatus == AuthorizationStatus.provisional) {
      print("permission granted by user");
    } else {
      print("permission denied by user");
    }

  }

  Future<String> getFcmToken()async{
    String? token = await firebaseMessaging.getToken();
    print("token : $token");
    return token!;
  }




  ///////////  local notification

  final FlutterLocalNotificationsPlugin notificationsPlugin =
  FlutterLocalNotificationsPlugin();


  Future<void> initNotifications() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
    InitializationSettings(android: androidSettings);

    await notificationsPlugin.initialize(settings);
  }

  Future<void> showNotification({title = "title", message = "message"}) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'channel_id',
      'General',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details =
    NotificationDetails(android: androidDetails);

    await notificationsPlugin.show(
      0,
     title,
      message,
      details,
    );
  }


}