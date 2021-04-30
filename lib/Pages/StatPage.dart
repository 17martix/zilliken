import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
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
import 'package:flutter/gestures.dart';

import '../Components/ZText.dart';

class StatPage extends StatefulWidget {
  final Authentication auth;
  final Database db;
  final String userId;
  final String userRole;
  final DateFormat formatter = DateFormat('dd/MM/yy');
  final List<Graph> data;

  StatPage({
    required this.auth,
    required this.db,
    required this.userId,
    required this.userRole,
    required this.data,
  });
  @override
  _StatPageState createState() => _StatPageState();
}

class _StatPageState extends State<StatPage> {
  List<Graph>? data;
  ScrollController _scrollController = ScrollController();
  List<DocumentSnapshot> items = [];
  CollectionReference statistic =
      FirebaseFirestore.instance.collection(Fields.statistic);

  bool isLoading = false;
  bool hasMore = true;

  QuerySnapshot? statref;
  DocumentSnapshot? lastDocument;

  List<BarChartGroupData> rawBarGroups = [];
  List<BarChartGroupData> showingBarGroups = [];
  int? touchedGroupIndex;

  final Color rightBarColor = Color(Styling.accentColor);
  final double width = 7;

  int documentLimit = 10;
  // AnimationController animationController;

  void initState() {
    super.initState();
    final barGroup1 = makeGroupData(0, 12);
    final barGroup2 = makeGroupData(1, 12);
    final barGroup3 = makeGroupData(2, 5);
    final barGroup4 = makeGroupData(3, 16);
    final barGroup5 = makeGroupData(4, 6);
    final barGroup6 = makeGroupData(5, 1.5);
    final barGroup7 = makeGroupData(6, 1.5);
    final barGroup8 = makeGroupData(5, 1.5);
    final barGroup9 = makeGroupData(6, 1.5);
    final barGroup10 = makeGroupData(0, 12);
    final barGroup11 = makeGroupData(1, 12);
    final barGroup12 = makeGroupData(2, 5);
    final barGroup13 = makeGroupData(3, 16);
    final barGroup14 = makeGroupData(6, 1.5);

    final items = [
      barGroup1,
      barGroup2,
      barGroup3,
      barGroup4,
      barGroup5,
      barGroup6,
      barGroup7,
      barGroup8,
      barGroup9,
      barGroup10,
      barGroup11,
      barGroup12,
      barGroup13,
      barGroup14,
    ];
    rawBarGroups = items;

    showingBarGroups = rawBarGroups;

    /*data = [
      Graph(year: '2000', subscribers: null, count: 178),
      Graph(year: '2001', subscribers: null, count: 178),
      Graph(year: '2002', subscribers: null, count: 178),
      Graph(year: '2003', subscribers: null, count: 178),
    ];*/
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
          .startAfterDocument(lastDocument!)
          .get();
    }

    if (statref!.docs.length < documentLimit) {
      hasMore = false;
    }

    if (statref!.docs.length > 0)
      lastDocument = statref!.docs[statref!.docs.length - 1];
    setState(() {
      for (int i = 0; i < statref!.docs.length; i++) {
        items.add(statref!.docs[i]);
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
    return Container(
      height: SizeConfig.diagonal * 10,
      child: Card(
        color: Colors.white.withOpacity(0.9),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(SizeConfig.diagonal * 0.2),
                height: 3,
                color: Color(Styling.iconColor).withOpacity(0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ZText(content:
                      "${statistic.total}",
                    
                        color: Color(Styling.accentColor),
                        fontSize: SizeConfig.diagonal * 3,
                        fontWeight: FontWeight.bold,
                        
                     
                    ),
                    ZText(
                      content: " Fbu",
                      color: Color(Styling.iconColor),
                      fontSize: SizeConfig.diagonal * 2.5,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(SizeConfig.diagonal * 0.2),
                color: Color(Styling.primaryBackgroundColor).withOpacity(0.3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                   ZText(content:
                      I18n.of(context).date,
                      textAlign: TextAlign.center,
                     
                        color: Color(Styling.iconColor),
                        fontSize: SizeConfig.diagonal * 2,
                      
                    ),
                   ZText(content:
                      "  : ${widget.formatter.format(statistic.date.toDate())}",
                     
                        color: Color(Styling.iconColor),
                        fontSize: SizeConfig.diagonal * 2,
                      
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget statList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SizedBox(
        //   height: SizeConfig.diagonal * 5,
        // ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ZText(content:
              I18n.of(context).dailytotal,
              textAlign: TextAlign.center,
              
                color: Color(Styling.iconColor),
                fontStyle: FontStyle.normal,
                fontSize: SizeConfig.diagonal * 2.5,
              
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
                        child: ZText(content:""),
                      )
                    : Row(
                        children: items.map((document) {
                          Statistic statistic = Statistic.buildObject(document);
                          return itemCard(statistic);
                          //return graph();
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
                          elevation: 0.0,
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
        graph(),
      ],
    );
  }

  BarChartGroupData makeGroupData(
    int x,
    double y1,
  ) {
    return BarChartGroupData(barsSpace: 4, x: x, barRods: [
      BarChartRodData(
        y: y1,
        colors: [rightBarColor],
        width: 3,
      ),
    ]);
  }

  Widget graph() {
    return Container(
      child: AspectRatio(
        aspectRatio: 1.2,
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SizeConfig.diagonal * 2),
          ),
          color: Color(Styling.primaryBackgroundColor).withOpacity(0.9),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    makeTransactionsIcon(),
                    const SizedBox(
                      width: 45,
                    ),
                    ZText(content:
                      'Transactions',
                    
                          color: Color(Styling.iconColor), fontSize: 15),
                  
                    const SizedBox(
                      width: 5,
                    ),
                    ZText(content:
                      'state',
                      
                          color: Color(Styling.accentColor), fontSize: 12),
                    
                  ],
                ),
                const SizedBox(
                  height: 4,
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: _scrollController,
                      child: BarChart(
                        BarChartData(
                          // groupsSpace:6,
                          maxY: 25,
                          barTouchData: BarTouchData(
                              touchTooltipData: BarTouchTooltipData(
                                tooltipBgColor: Colors.grey,
                                getTooltipItem: (_a, _b, _c, _d) => null,
                              ),
                              touchCallback: (response) {
                                if (response.spot == null) {
                                  setState(() {
                                    touchedGroupIndex = -1;
                                    showingBarGroups = List.of(rawBarGroups);
                                  });
                                  return;
                                }

                                touchedGroupIndex =
                                    response.spot!.touchedBarGroupIndex;

                                setState(() {
                                  if (response.touchInput is PointerExitEvent ||
                                      response.touchInput is PointerUpEvent) {
                                    touchedGroupIndex = -1;
                                    showingBarGroups = List.of(rawBarGroups);
                                  } else {
                                    showingBarGroups = List.of(rawBarGroups);
                                    if (touchedGroupIndex != -1) {
                                      double sum = 0;
                                      for (BarChartRodData rod
                                          in showingBarGroups[
                                                  touchedGroupIndex!]
                                              .barRods) {
                                        sum += rod.y;
                                      }
                                      final avg = sum /
                                          showingBarGroups[touchedGroupIndex!]
                                              .barRods
                                              .length;

                                      showingBarGroups[touchedGroupIndex!] =
                                          showingBarGroups[touchedGroupIndex!]
                                              .copyWith(
                                        barRods:
                                            showingBarGroups[touchedGroupIndex!]
                                                .barRods
                                                .map((rod) {
                                          return rod.copyWith(y: avg);
                                        }).toList(),
                                      );
                                    }
                                  }
                                });
                              }),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: SideTitles(
                              showTitles: true,
                              getTextStyles: (value) => const TextStyle(
                                  color: Color(Styling.iconColor),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10),
                              margin: 15,
                              getTitles: (double value) {
                                switch (value.toInt()) {
                                  case 0:
                                    return 'Mn';
                                  case 1:
                                    return 'Te';
                                  case 2:
                                    return 'Wd';
                                  case 3:
                                    return 'Tu';
                                  case 4:
                                    return 'Fr';
                                  case 5:
                                    return 'St';
                                  case 6:
                                    return 'Sn';

                                  default:
                                    return '';
                                }
                              },
                            ),
                            leftTitles: SideTitles(
                              showTitles: true,
                              getTextStyles: (value) => const TextStyle(
                                  color: Color(Styling.iconColor),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14),
                              margin: 20,
                              reservedSize: 20,
                              getTitles: (value) {
                                if (value == 0) {
                                  return '50K';
                                } else if (value == 10) {
                                  return '1M';
                                } else if (value == 19) {
                                  return '10M';
                                } else if (value == 30) {
                                  return '50M';
                                } else {
                                  return '';
                                }
                              },
                            ),
                          ),
                          borderData: FlBorderData(
                            show: false,
                          ),
                          barGroups: showingBarGroups,
                        ),
                        swapAnimationDuration: Duration(milliseconds: 150),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget makeTransactionsIcon() {
    const double width = 7;
    const double space = 7;
    return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: width,
            height: 10,
            color: Colors.white.withOpacity(0.9),
          ),
          const SizedBox(
            width: space,
          ),
          Container(
            width: width,
            height: 10,
            color: Colors.white.withOpacity(0.9),
          ),
          const SizedBox(
            width: space,
          ),
          Container(
            width: width,
            height: 10,
            color: Colors.white.withOpacity(0.9),
          ),
          const SizedBox(
            width: space,
          ),
        ]);
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
