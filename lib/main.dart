import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:relipay_chatbot/notification_service.dart';
import 'package:relipay_chatbot/splashscreen.dart';
import 'package:relipay_chatbot/ui_screen/HomeScreen.dart';
import 'package:relipay_chatbot/ui_screen/login_screen.dart';
import 'package:relipay_chatbot/ui_screen/signup_screen.dart';
import 'package:relipay_chatbot/ui_screen/ui_helper/my_color.dart';

Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage((message) => _backgroundMessageHandler(message));

  FirebaseMessaging.onMessage.listen((RemoteMessage fcmMsg) {
    if (fcmMsg.notification != null) {
      MyNotificationService().showNotification(
        title: fcmMsg.notification!.title!,
        message: fcmMsg.notification!.body!,
      );
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Relipay ChatApp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: MyColor.projectColor,
          primary: MyColor.projectColor,
        ),

        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

