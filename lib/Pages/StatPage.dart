import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:zilliken/Helpers/SizeConfig.dart';
import 'package:zilliken/Helpers/Styling.dart';
import 'package:zilliken/Models/Fields.dart';
import 'package:zilliken/Models/MenuItem.dart';
import 'package:zilliken/Models/Statistic.dart';
import 'package:intl/intl.dart';
import 'package:zilliken/Pages/MenuPage.dart';
import 'package:zilliken/Services/Authentication.dart';
import 'package:zilliken/Services/Database.dart';
import 'package:zilliken/Services/Messaging.dart';

class StatPage extends StatefulWidget {
  final Authentication auth;
  final Database db;
  final String userId;
  final String userRole;
  final DateFormat formatter = DateFormat('dd/MM/yy HH:mm');

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
  CollectionReference statistic =
      FirebaseFirestore.instance.collection(Fields.statistic);
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: statisticStream(),
    );
  }

  Widget body(Statistic statistic) {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Card(
            elevation: 5.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SizeConfig.diagonal * 1.5),
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        " Le Total encaissE le:  ",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(Styling.iconColor),
                          fontSize: SizeConfig.diagonal * 2,
                        ),
                      ),
                      Text(
                        "${widget.formatter.format(statistic.date.toDate())}",
                        style: TextStyle(
                          color: Color(Styling.accentColor),
                          fontSize: SizeConfig.diagonal * 2,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(SizeConfig.diagonal * 1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /*Text(
                        "est: ",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(Styling.iconColor),
                          fontSize: SizeConfig.diagonal * 2,
                        ),
                      ),*/
                      Text(
                        "${statistic.total}",
                        style: TextStyle(
                          color: Colors.lightGreen,
                          fontSize: SizeConfig.diagonal * 3.5,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Font1",
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ])
      ],
    );
  }

  Widget statisticStream() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(SizeConfig.diagonal * 1),
          child: Text(
            "Title",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(Styling.accentColor),
              fontSize: SizeConfig.diagonal * 3.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: statistic.snapshots(),
          // ignore: missing_return
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            return Container(
              height: SizeConfig.diagonal * 20,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (BuildContext context, index) {
                    Statistic stat = Statistic();
                    stat.buildObject(snapshot.data.docs[index]);
                    return Row(
                      children: [
                        body(stat),
                      ],
                    );
                  }),
            );
          },
        ),
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
