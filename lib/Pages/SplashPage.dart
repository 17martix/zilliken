import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zilliken/Helpers/SizeConfig.dart';
import 'package:zilliken/Helpers/Styling.dart';
import 'package:zilliken/Models/Fields.dart';
import 'package:zilliken/Pages/DashboardPage.dart';
import 'package:zilliken/Services/Authentication.dart';
import 'package:zilliken/Services/Database.dart';
import 'package:zilliken/Services/Messaging.dart';
import 'package:zilliken/i18n.dart';

class SplashPage extends StatefulWidget {
  final Authentication auth;
  final Database db;
  final Messaging messaging;

  SplashPage({
    @required this.auth,
    @required this.db,
    @required this.messaging,
  });

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    Timer(
      Duration(seconds: 2),
      isLoggedIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      backgroundColor: Color(Styling.primaryColor),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: SizeConfig.diagonal * 2),
            child: Center(
              child: logo(),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(SizeConfig.diagonal * 2),
            child: CircularProgressIndicator(),
          ),
        ],
      ),
    );
  }

  Widget logo() {
    return Hero(
      tag: I18n.of(context).appTitle,
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.diagonal * 2),
        child: CircleAvatar(
          radius: SizeConfig.diagonal * 10,
          backgroundColor: Colors.transparent,
          child: Image(
            image: AssetImage('assets/logo.png'),
          ),
        ),
      ),
    );
  }

  void isLoggedIn() async {
    widget.messaging.firebaseMessaging.requestPermission();
    User user = widget.auth.getCurrentUser();
    if (user?.uid == null) {
      String id = await widget.auth.anonymousSignIn();
      String token = await widget.messaging.firebaseMessaging.getToken();
      String role = await widget.db.getUserRole(id, token);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardPage(
            auth: widget.auth,
            db: widget.db,
            userId: id,
            userRole: role,
            messaging: widget.messaging,
          ),
        ),
      );
    } else if (user.isAnonymous) {
      String role = Fields.client;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardPage(
            auth: widget.auth,
            db: widget.db,
            userId: user.uid,
            userRole: role,
            messaging: widget.messaging,
          ),
        ),
      );
    } else {
      String token = await widget.messaging.firebaseMessaging.getToken();
      String role = await widget.db.getUserRole(user.uid, token);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardPage(
            auth: widget.auth,
            db: widget.db,
            userId: user.uid,
            userRole: role,
            messaging: widget.messaging,
          ),
        ),
      );
    }
  }
}
