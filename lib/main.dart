import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:zilliken/Pages/SplashPage.dart';
import 'package:zilliken/Services/Authentication.dart';
import 'package:zilliken/Services/Database.dart';
import 'Helpers/Styling.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'Pages/LoginPage.dart';
import 'Services/Database.dart';
import 'i18n.dart';
import 'Services/Messaging.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseFirestore.instance.settings = Settings(persistenceEnabled: true);

  FirebaseFirestore.instance.settings = Settings(cacheSizeBytes: 300000000);

  if (kDebugMode) {
    // Force disable Crashlytics collection while doing every day development.
    // Temporarily toggle this to true if you want to test crash reporting in your app.
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  } else {
    // Handle Crashlytics enabled status when not in Debug,
    // e.g. allow your users to opt-in to crash reporting.
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  }

  Messaging messaging = Messaging();

  // Set the background messaging handler early on, as a named top-level function
  /*FirebaseMessaging.onBackgroundMessage(
      messaging.firebaseMessagingBackgroundHandler);*/

  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await messaging.flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(messaging.channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  runApp(Zilliken(
    messaging: messaging,
  ));
  initLoadingScreen();
}

void initLoadingScreen() {
  EasyLoading.instance
    ..indicatorType = EasyLoadingIndicatorType.chasingDots
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 65
    ..radius = 0
    ..progressColor = Color(Styling.accentColor)
    ..backgroundColor = Color(Styling.accentColor)
    ..indicatorColor = Color(Styling.accentColor)
    ..textColor = Color(Styling.primaryBackgroundColor)
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = false
    ..dismissOnTap = false;
}

class Zilliken extends StatelessWidget {
  // This widget is the root of your application.
  final Messaging messaging;

  Zilliken({
    this.messaging,
  });

  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics analytics = FirebaseAnalytics();
    return MaterialApp(
      localizationsDelegates: [
        const I18nDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: I18nDelegate.supportedLocals,
      title: 'Zilliken',
      theme: buildTheme(),
      home: SplashPage(
        auth: Authentication(),
        db: Database(),
        messaging: messaging,
      ),
      builder: EasyLoading.init(),
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
    );
  }

  ThemeData buildTheme() {
    final ThemeData base = ThemeData.light();
    return base.copyWith(
      accentColor: Color(Styling.accentColor),
      primaryColor: Color(Styling.primaryColor),
      buttonColor: Color(Styling.iconColor),
      scaffoldBackgroundColor: Color(Styling.primaryBackgroundColor),
      backgroundColor: Color(Styling.primaryBackgroundColor),
      cardColor: Color(Styling.primaryBackgroundColor),
      //textTheme: base.textTheme.apply(fontFamily: 'Cochin'),
      //primaryTextTheme: base.textTheme.apply(fontFamily: 'Cochin'),
      // accentTextTheme: base.textTheme.apply(fontFamily: 'Cochin'),
    );
  }
}
