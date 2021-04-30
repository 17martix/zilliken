import 'package:flutter/material.dart';
import 'package:zilliken/Helpers/SizeConfig.dart';
import 'package:zilliken/Helpers/Styling.dart';
import 'package:zilliken/Services/Authentication.dart';
import 'package:zilliken/Services/Database.dart';

import '../i18n.dart';

class DisabledPage extends StatefulWidget {
  final Authentication auth;
  final Database db;
  final String userId;
  final String userRole;

  DisabledPage({
   required this.auth,
   required this.db,
   required this.userId,
   required this.userRole,
  });

  @override
  _DisabledPageState createState() => _DisabledPageState();
}

class _DisabledPageState extends State<DisabledPage> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
        image: AssetImage('assets/Zilliken.jpg'),
        fit: BoxFit.cover,
      )),
      child: Container(
        color: Color(Styling.primaryBackgroundColor).withOpacity(0.7),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Text(
              I18n.of(context).accountDisabled,
              textAlign: TextAlign.center,
              style: new TextStyle(
                fontSize: SizeConfig.diagonal * 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
