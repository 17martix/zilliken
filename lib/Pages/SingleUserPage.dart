import 'package:flutter/material.dart';
import 'package:zilliken/Components/ZAppBar.dart';
import 'package:zilliken/Helpers/SizeConfig.dart';
import 'package:zilliken/Services/Authentication.dart';
import 'package:zilliken/Services/Database.dart';

class SingleUserPage extends StatefulWidget {
  final Authentication auth;
  final Database db;
  final String userId;

  final String userRole;

  SingleUserPage({
    @required this.auth,
    @required this.db,
    @required this.userId,
    @required this.userRole,
  });
  @override
  _SingleUserPageState createState() => _SingleUserPageState();
}

class _SingleUserPageState extends State<SingleUserPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        context,
        widget.auth,
        true,
        null,
        null,
        null,
        null,
      ),
      body: body(),
    );
  }

  Widget body() {
    return Column(children: [
      Container(
        padding: EdgeInsets.all(SizeConfig.diagonal * 1),
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Card(
                
                elevation: 5.0,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(SizeConfig.diagonal * 2)),
                child: Column(
                  children: [
                    Text("le total encaisse"),
                    Text("23/4/2018"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ]);
  }
}
