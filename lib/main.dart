import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:zilliken/Pages/DashboardPage.dart';

import 'Pages/SingleOrderPage.dart';
import 'i18n.dart';

void main() {
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
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: DashboardPage(),
    );
  }
}
