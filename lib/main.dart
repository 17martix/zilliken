import 'package:flutter/material.dart';

import 'Pages/SingleOrderPage.dart';

void main() {
  runApp(Zilliken());
}

class Zilliken extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zilliken',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SingleOrderPage(),
    );
  }
}
