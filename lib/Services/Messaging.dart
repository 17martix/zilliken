import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'Authentication.dart';
import 'Database.dart';

class Messaging {
  final String CHANNEL_ID = "net.visionplusplus.zilliken.channel.id";
  final String CHANNEL_TITLE = "net.visionplusplus.zilliken.channel.title";
  final String CHANNEL_DESCRIPTION =
      "net.visionplusplus.zilliken.channel.description";

  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Create a [AndroidNotificationChannel] for heads up notifications
  AndroidNotificationChannel channel;

  Messaging() {
    channel = AndroidNotificationChannel(
      CHANNEL_ID, // id
      CHANNEL_TITLE, // title
      CHANNEL_DESCRIPTION, // description
      importance: Importance.high,
    );

    var initializationSettingsAndroid =
        new AndroidInitializationSettings('launch_background');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // If you're going to use other Firebase services in the background, such as Firestore,
    // make sure you call `initializeApp` before using other Firebase services.
    await Firebase.initializeApp();
    print('Handling a background message ${message.messageId}');
  }

  void listenMessage(
    context,
    Authentication auth,
    Database db,
    String userId,
    String userRole,
    Messaging messaging,
  ) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      //AndroidNotification android = message.notification?.android;

      var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        CHANNEL_ID,
        CHANNEL_TITLE,
        CHANNEL_DESCRIPTION,
        playSound: true,
        enableVibration: true,
        importance: Importance.high,
        priority: Priority.high,
        icon: 'logo',
      );
      var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
      var platformChannelSpecifics = new NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: iOSPlatformChannelSpecifics);

      if (notification != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          platformChannelSpecifics,
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('A new onMessageOpenedApp event was published!');
      /*Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardPage(
            auth: auth,
            db: db,
            userId: userId,
            userRole: userRole,
            messaging: messaging,
            index: 1,
          ),
        ),
      );*/
    });
  }
}
