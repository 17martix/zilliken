import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:zilliken/Helpers/SizeConfig.dart';
import 'package:zilliken/Helpers/Styling.dart';
import 'package:zilliken/Models/MenuItem.dart';
import 'package:zilliken/Pages/MenuPage.dart';
import 'package:zilliken/Services/Authentication.dart';
import 'package:zilliken/Services/Database.dart';
import 'package:zilliken/Services/Messaging.dart';

class StatPage extends StatefulWidget {
  final Authentication auth;
  final Database db;

  final String userId;
  final String userRole;

  StatPage({
    @required this.auth,
    @required this.db,
    @required this.userId,
    @required this.userRole,
  });
  @override
  _StatPageState createState() => _StatPageState();
}

class _StatPageState extends State<StatPage> {
  ScrollController _scrollController = ScrollController();
  List<DocumentSnapshot> items = List();
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: body(),
    );
  }

  Widget body() {
    return Column(
      children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          Card(
            elevation: 6.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SizeConfig.diagonal * 50),
            ),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Container(
                width: SizeConfig.diagonal * 23,
                height: SizeConfig.diagonal * 8,
                child: ListTile(
                    title: Text("le prix"),
                    subtitle: Text(
                      "la date",
                    )),
              ),
            ),
          )
        ])
      ],
    );
  }

  /*Widget body() {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          card(),
        ],
      ),
    );
  }*/

  /*Widget card() {
    return Card(
      child: Column(
        children: [
          Expanded(
                    child: GridView.builder(
                padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.safeBlockHorizontal * 1),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 20 / 28.5,
                  crossAxisCount: 4,
                  mainAxisSpacing: SizeConfig.diagonal * 0.2,
                  crossAxisSpacing: SizeConfig.diagonal * 0.2,
                ),
                itemCount: items.length,
                itemBuilder: (BuildContext context, int index) {
                  MenuItem ad = MenuItem();
                  ad.buildObject(items[index]);
                }),
          ),
          Card(
            0,
            color: Color(Styling.primaryBackgroundColor),
            shape: RoundedRectangleBorder(
              belevationorderRadius: BorderRadius.circular(30),
            ),
            child: ListTile(
              title: Text("le prix"),
              subtitle: Text("le jour"),
            ),
          ),
        ],
      ),
     
    );
  }*/
}
