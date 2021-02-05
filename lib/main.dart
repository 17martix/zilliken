import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:zilliken/Pages/DashboardPage.dart';
import 'package:zilliken/Services/Authentication.dart';

import 'Helpers/ConnectionStatus.dart';
import 'Helpers/PushNotificationManager.dart';
import 'Helpers/Styling.dart';
import 'Pages/SingleOrderPage.dart';
import 'Services/Database.dart';
import 'i18n.dart';

import 'Pages/SplashPage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  ConnectionStatus connectionStatus = ConnectionStatus.getInstance();
  PushNotificationManager pushNotificationManager = PushNotificationManager();
  pushNotificationManager.init();
  connectionStatus.initialize();

  runApp(Zilliken());
}

class Zilliken extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
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
      ),
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
    );
  }
}
