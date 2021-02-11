import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
    this.auth,
    this.db,
    this.userId,
    this.userRole,
  });

  @override
  _DisabledPageState createState() => _DisabledPageState();
}

class _DisabledPageState extends State<DisabledPage> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Center(
        child: Text(
          I18n.of(context).accountDisabled,
          textAlign: TextAlign.center,
          style: new TextStyle(
            fontSize: SizeConfig.diagonal * 2,
          ),
        ),
      ),
    );
  }
}
