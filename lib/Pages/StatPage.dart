import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart' ;
import 'package:flutter/material.dart';

import 'package:zilliken/Helpers/SizeConfig.dart';
import 'package:zilliken/Helpers/Styling.dart';
import 'package:zilliken/Models/Fields.dart';
import 'package:zilliken/Models/Graph.dart';
import 'package:zilliken/Models/Statistic.dart';
import 'package:intl/intl.dart';
import 'package:zilliken/Services/Authentication.dart';
import 'package:zilliken/Services/Database.dart';
import 'package:zilliken/i18n.dart';

class StatPage extends StatefulWidget {
  final Authentication auth;
  final Database db;
  final String userId;
  final String userRole;
  final DateFormat formatter = DateFormat('dd/MM/yy');
  final List<Graph> data;
  

  StatPage({
    @required this.auth,
    @required this.db,
    @required this.userId,
    @required this.userRole,
    @required this.data,
    
  });
  @override
  _StatPageState createState() => _StatPageState();
}

class _StatPageState extends State<StatPage> {
  List<Graph> data;
  ScrollController _scrollController = ScrollController();
  List<DocumentSnapshot> items = List();
  CollectionReference statistic =
      FirebaseFirestore.instance.collection(Fields.statistic);

  bool isLoading = false;
  bool hasMore = true;

  QuerySnapshot statref;
  DocumentSnapshot lastDocument;

  int documentLimit = 10;
  // AnimationController animationController;

  void initState() {
    super.initState();
    data = [
      Graph(year: '2000', subscribers: null, count: 178),
       Graph(year: '2001', subscribers: null, count: 178),
        Graph(year: '2002', subscribers: null, count: 178),
         Graph(year: '2003', subscribers: null, count: 178),
    ];
    //animationController =
    //AnimationController(duration: new Duration(seconds: 2),);
    //animationController.repeat();
    statQuery();
    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.width * 0.20;
      if (maxScroll - currentScroll <= delta) {
        statQuery();
      }
    });
  }

  void statQuery() async {
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });

    if (lastDocument == null) {
      statref = await widget.db.databaseReference
          .collection(Fields.statistic)
          .limit(documentLimit)
          .orderBy(Fields.date)
          .get();
    } else {
      statref = await widget.db.databaseReference
          .collection(Fields.statistic)
          .limit(documentLimit)
          .orderBy(Fields.date, descending: true)
          .startAfterDocument(lastDocument)
          .get();
    }

    if (statref.docs.length < documentLimit) {
      hasMore = false;
    }

    if (statref.docs.length > 0)
      lastDocument = statref.docs[statref.docs.length - 1];
    setState(() {
      for (int i = 0; i < statref.docs.length; i++) {
        items.add(statref.docs[i]);
      }
      isLoading = false;

      log('length is ${items.length}');
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: statList(), //statisticStream(),
    );
  }

  Widget itemCard(Statistic statistic) {
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
                  padding: EdgeInsets.all(SizeConfig.diagonal * 1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${statistic.total}",
                        style: TextStyle(
                          color: Colors.lightGreen,
                          fontSize: SizeConfig.diagonal * 3,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Font1",
                        ),
                      ),
                      Text(
                        " Fbu",
                        style: TextStyle(
                          color: Color(Styling.iconColor),
                          fontSize: SizeConfig.diagonal * 2.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        I18n.of(context).date,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(Styling.iconColor),
                          fontSize: SizeConfig.diagonal * 2,
                        ),
                      ),
                      Text(
                        "  : ${widget.formatter.format(statistic.date.toDate())}",
                        style: TextStyle(
                          color: Color(Styling.accentColor),
                          fontSize: SizeConfig.diagonal * 2,
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

  Widget statList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              I18n.of(context).dailytotal,
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
                items.length == 0
                    ? Center(
                        child: Text(""),
                      )
                    : Row(
                        children: items.map((document) {
                          Statistic statistic = Statistic();
                          statistic.buildObject(document);
                          return itemCard(statistic);
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

  Widget graph() {
    return Column(
      children:<Widget> [
      
        
        BarChart(
      
          BarChartData(),
          swapAnimationDuration: Duration(milliseconds: 150),
        ),
      ],
    );
  }

  /* Widget statisticStream() {
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
        StreamBuilder<QuerySnapshot> (
          stream: statistic.snapshots(),
          // ignore: missing_return
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            return Container(
              height: SizeConfig.diagonal * 20,
              child: ListView.builder(
                  controller: _scrollController,
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
  }*/

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
