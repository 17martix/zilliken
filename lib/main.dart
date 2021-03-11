import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:zilliken/Pages/SplashPage.dart';
import 'package:zilliken/Services/Authentication.dart';
import 'package:zilliken/Services/Database.dart';
import 'Helpers/Styling.dart';

import 'Pages/SplashPage.dart';
import 'Services/Database.dart';
import 'i18n.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseFirestore.instance.settings = Settings(persistenceEnabled: true);

  FirebaseFirestore.instance.settings = Settings(cacheSizeBytes: 100000000);

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
