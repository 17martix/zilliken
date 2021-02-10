import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zilliken/Helpers/SizeConfig.dart';
import 'package:zilliken/Helpers/Styling.dart';
import 'package:zilliken/Pages/DashboardPage.dart';
import 'package:zilliken/Services/Authentication.dart';
import 'package:zilliken/Services/Database.dart';
import 'package:zilliken/i18n.dart';

class SplashPage extends StatefulWidget {
  final Authentication auth;
  final Database db;

  SplashPage({
    this.auth,
    this.db,
  });

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  //int abc=1;
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
            margin: EdgeInsets.only(bottom: 10),
            child: Center(
              child: logo(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
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
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          radius: 90,
          backgroundColor: Colors.transparent,
          child: Image(
            image: AssetImage('assets/logo.jpg'),
          ),
        ),
      ),
    );
  }

  void isLoggedIn() async {
    User user = await widget.auth.getCurrentUser();
    if (user?.uid == null) {
      String id = await widget.auth.anonymousSignIn();
      String role = 'client';
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardPage(
            auth: widget.auth,
            db: widget.db,
            userId: id,
            userRole: role,
          ),
        ),
      );
    } else {
      String role = await widget.db.getUserRole(user.uid);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardPage(
            auth: widget.auth,
            db: widget.db,
            userId: user.uid,
            userRole: role,
          ),
        ),
      );
    }
  }
}
