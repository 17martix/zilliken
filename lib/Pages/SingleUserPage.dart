import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:zilliken/Components/ZAppBar.dart';
import 'package:zilliken/Components/ZFlatButton.dart';
import 'package:zilliken/Components/ZRaisedButton.dart';
import 'package:zilliken/Helpers/SizeConfig.dart';
import 'package:zilliken/Helpers/Styling.dart';
import 'package:zilliken/Models/Fields.dart';
import 'package:zilliken/Models/StatisticUser.dart';
import 'package:zilliken/Models/UserProfile.dart';
import 'package:zilliken/Services/Authentication.dart';
import 'package:zilliken/Services/Database.dart';
import 'package:zilliken/i18n.dart';
import 'package:intl/intl.dart';

class SingleUserPage extends StatefulWidget {
  final Authentication auth;
  final Database db;
  final String userId;
  final DateFormat formatter = DateFormat('dd/MM/yy hh:mm');
  final String userRole;
  final UserProfile userData;

  SingleUserPage({
    @required this.auth,
    @required this.db,
    @required this.userId,
    @required this.userRole,
    @required this.userData,
  });
  @override
  _SingleUserPageState createState() => _SingleUserPageState();
}

class _SingleUserPageState extends State<SingleUserPage> {
  var oneUserDetails ;
  var _scrollController;
  var isLoading;
  var statistics;

  @override
  void initState() {
    super.initState();
    statistics = FirebaseFirestore.instance
        .collection(Fields.users)
        .doc(widget.userId)
        .collection(Fields.statistic);
;
  }

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
      statList(),

      // userListStream(),
    ]);
  }

  Widget itemCard(StatisticUser statisticUser) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Card(
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SizeConfig.diagonal * 2)),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(SizeConfig.diagonal * 1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${statisticUser.total}',
                          style: TextStyle(
                            color: Colors.lightGreen,
                            fontSize: SizeConfig.diagonal * 3,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Font1",
                          ),
                        ),
                        Text(
                          "fbu",
                          style: TextStyle(
                            color: Color(Styling.iconColor),
                            fontSize: SizeConfig.diagonal * 2.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(SizeConfig.diagonal * 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '{I18n.of(context).orderDate}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Color(Styling.iconColor),
                              fontSize: SizeConfig.diagonal * 2),
                        ),
                        Text(
                          " : "
                          '${widget.formatter.format(statisticUser.date.toDate())}',
                          style: TextStyle(
                              color: Color(Styling.accentColor),
                              fontSize: SizeConfig.diagonal * 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget statList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '{I18n.of(context).dailyTotal}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(Styling.accentColor),
                fontSize: SizeConfig.diagonal * 3.5,
                fontStyle: FontStyle.normal,
              ),
            ),
          ],
        ),
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _scrollController,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                statistics.length == 0
                    ? Center(
                        child: Text(""),
                      )
                    : Row(
                        children: statistics.map((document) {
                          StatisticUser statisticUser = StatisticUser();
                          statisticUser.buildObject(document);
                          return itemCard(statisticUser);
                        }).toList(),
                      ),
                /* ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            controller: _scrollController,
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              Statistic statistic = Statistic();
                              statistic.buildObject(items[index]);
                              return Row(
                                children: [
                                  body(statistic),
                                ],
                              );
                            },
                          ),*/
                isLoading
                    ? Container(
                        width: SizeConfig.diagonal * 8,
                        height: SizeConfig.diagonal * 8,
                        padding: EdgeInsets.all(SizeConfig.diagonal * 1.5),
                        child: Card(
                          elevation: 2,
                          color: Colors.white.withOpacity(1),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(SizeConfig.diagonal * 1),
                          ),
                          child: CircularProgressIndicator(
                            // valueColor: animationController
                            //.drive(ColorTween(begin: Colors.blueAccent, end: Colors.red)),

                            //valueColor:Animation<blue> valueColor ,

                            semanticsLabel: 'Linear progress indicator',

                            backgroundColor: Color(Styling.primaryDarkColor),
                          ),
                        ),
                      )
                    : Container()
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/* Widget userListStream() {
    return StreamBuilder<QuerySnapshot>(
        stream: oneUserDetails.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.data == null) return Center(child: Text(""));
          return ListView(
            children: snapshot.data.docs.map((DocumentSnapshot document) {
              UserProfile userProfile = UserProfile();
              userProfile.buildObject(document);
              return userList(userProfile);
            }).toList(),
          );
        });
  }

  Widget userList(UserProfile userProfile) {
    return Container(
      child: Column(
        children: [
          Container(
              child:
                  Text('{I18n.of(context).name}' ":" '${userProfile.name}')),
          Container(
            child: Text(
                '{I18n.of(context).phone}' ":" '${userProfile.phoneNumber}'),
          ),
          ZRaisedButton(
            textIcon: Text("activer"),
         
          ),
        ],
      ),
    );
  }*/
