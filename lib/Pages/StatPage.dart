import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:zilliken/Helpers/SizeConfig.dart';
import 'package:zilliken/Helpers/Styling.dart';
import 'package:zilliken/Helpers/Utils.dart';
import 'package:zilliken/Models/Fields.dart';

import 'package:zilliken/Models/Statistic.dart';
import 'package:intl/intl.dart';
import 'package:zilliken/Models/UserProfile.dart';
import 'package:zilliken/Services/Authentication.dart';
import 'package:zilliken/Services/Database.dart';
import 'package:zilliken/i18n.dart';

import '../Components/ZText.dart';

class StatPage extends StatefulWidget {
  final Authentication auth;
  final Database db;
  final String userId;
  final String userRole;
  final DateFormat formatter = DateFormat('dd/MM/yy');
  final DateFormat format = DateFormat('dd/MM');

  //final List<Graph> data;

  StatPage({
    required this.auth,
    required this.db,
    required this.userId,
    required this.userRole,

    //required this.data,
  });
  @override
  _StatPageState createState() => _StatPageState();
}

class _StatPageState extends State<StatPage> {
  //List<Graph>? data;
  ScrollController _scrollController = ScrollController();
  List<DocumentSnapshot> items = [];

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

  num maxY = 1;
  num pourcentage = 0;

  ScrollController _controller = ScrollController();
  // AnimationController animationController;

  void initState() {
    super.initState();

    /*data = [
      Graph(year: '2000', subscribers: null, count: 178),
      Graph(year: '2001', subscribers: null, count: 178),
      Graph(year: '2002', subscribers: null, count: 178),
      Graph(year: '2003', subscribers: null, count: 178),
    ];*/
    //animationController =
    //AnimationController(duration: new Duration(seconds: 2),);
    //animationController.repeat();
    statisticQuery();
    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.width * 0.20;
      if (maxScroll - currentScroll <= delta) {
        statisticQuery();
      }
    });
  }

  void graphData() {
    int length = items.length;
    if (length > 7) length = 7;

    final List<BarChartGroupData> barItems = [];
    for (int i = 0; i < length; i++) {
      final barGroup = makeGroupData(i, items[i].data()![Fields.total]);
      barItems.add(barGroup);
      if (maxY < items[i].data()![Fields.total]) {
        setState(() {
          maxY = items[i].data()![Fields.total];
        });
      }
    }
    /* final barGroup1 = makeGroupData(0, items[0].data()![Fields.total]);
    final barGroup2 = makeGroupData(1, items[2].data()![Fields.total]);
    final barGroup3 = makeGroupData(2, items[3].data()![Fields.total]);
    final barGroup4 = makeGroupData(3, items[4].data()![Fields.total]);
    final barGroup5 = makeGroupData(4, items[5].data()![Fields.total]);
    final barGroup6 = makeGroupData(5, items[6].data()![Fields.total]);
    final barGroup7 = makeGroupData(6, items[7].data()![Fields.total]);

    final barItems = [
      barGroup1,
      barGroup2,
      barGroup3,
      barGroup4,
      barGroup5,
      barGroup6,
      barGroup7,
    ];*/
    rawBarGroups = barItems;

    showingBarGroups = rawBarGroups;
  }

  void statisticQuery() async {
    if (isLoading) {
      return;
    }

    if (hasMore == false) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    if (lastDocument == null) {
      statref = await widget.db.databaseReference
          .collection(Fields.statistic)
          .limit(documentLimit)
          .orderBy(Fields.date, descending: true)
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

      graphData();
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
                color: Colors.grey.withOpacity(0.2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ZText(
                      content: "${statistic.total}",
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
                    ZText(
                      content: I18n.of(context).date,
                      textAlign: TextAlign.center,
                      color: Color(Styling.iconColor),
                      fontSize: SizeConfig.diagonal * 2,
                    ),
                    ZText(
                      content:
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
            ZText(
              content: I18n.of(context).dailytotal,
              textAlign: TextAlign.center,
              color: Color(Styling.iconColor),
              fontStyle: FontStyle.normal,
              fontSize: SizeConfig.diagonal * 2.5,
            ),
          ],
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: _scrollController,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              items.length == 0
                  ? Center(
                      child: ZText(content: ""),
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
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            controller: _controller,
            child: Column(
              children: [
                graph(),
                graph2(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  BarChartGroupData makeGroupData(
    int x,
    num y1,
  ) {
    return BarChartGroupData(barsSpace: 4, x: x, barRods: [
      BarChartRodData(
        y: y1.toDouble(),
        colors: [rightBarColor],
        width: 3,
      ),
    ]);
  }

  Widget graph() {
    //maxY1 = maxY / 4;
    return Container(
      child: AspectRatio(
        aspectRatio: 1.3,
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SizeConfig.diagonal * 2),
          ),
          color: Color(Styling.primaryBackgroundColor),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                  color: Colors.grey.withOpacity(0.2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      makeTransactionsIcon(),
                      const SizedBox(
                        width: 45,
                      ),
                      ZText(
                          content: 'Transactions',
                          color: Color(Styling.iconColor),
                          fontSize: 15),
                      const SizedBox(
                        width: 5,
                      ),
                      ZText(
                          content: 'state',
                          color: Color(Styling.accentColor),
                          fontSize: 12),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Expanded(
                  //flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: BarChart(
                      BarChartData(
                        // groupsSpace:6,
                        maxY: maxY.toDouble(),
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            tooltipBgColor: Colors.red,
                            getTooltipItem: (_a, _b, _c, _d) => null,
                          ),
                          /*touchCallback: (response) {
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
                                        in showingBarGroups[touchedGroupIndex!]
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
                            }*/
                        ),
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
                                  Timestamp date =
                                      items[0].data()![Fields.date];
                                  return widget.format.format(date.toDate());
                                case 1:
                                  Timestamp date =
                                      items[1].data()![Fields.date];
                                  return widget.format.format(date.toDate());
                                case 2:
                                  Timestamp date =
                                      items[2].data()![Fields.date];
                                  return widget.format.format(date.toDate());
                                case 3:
                                  Timestamp date =
                                      items[3].data()![Fields.date];
                                  return widget.format.format(date.toDate());
                                case 4:
                                  Timestamp date =
                                      items[4].data()![Fields.date];
                                  return widget.format.format(date.toDate());
                                case 5:
                                  Timestamp date =
                                      items[5].data()![Fields.date];
                                  return widget.format.format(date.toDate());
                                case 6:
                                  Timestamp date =
                                      items[6].data()![Fields.date];
                                  return widget.format.format(date.toDate());

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
                            interval: maxY / 4,
                            getTitles: (value) {
                              log("value is $value");
                              if (value == 0) {
                                return '0';
                              } else if (value == maxY / 4) {
                                return formatInterVal(maxY / 4)!;
                              } else if (value == maxY / 2) {
                                return formatInterVal(maxY / 2)!;
                              } else if (value == maxY * 3 / 4) {
                                return formatInterVal(maxY * 3 / 4)!;
                              } else if (value == maxY) {
                                return formatInterVal(maxY.toDouble())!;
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
                      //swapAnimationDuration: Duration(milliseconds: 150),
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
            color: Colors.grey.withOpacity(0.4),
          ),
          const SizedBox(
            width: space,
          ),
          Container(
            width: width,
            height: 10,
            color: Colors.grey.withOpacity(0.9),
          ),
          const SizedBox(
            width: space,
          ),
          Container(
            width: width,
            height: 10,
            color: Colors.black.withOpacity(0.5),
          ),
          const SizedBox(
            width: space,
          ),
        ]);
  }

  Widget graph2() {
    return Container(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeConfig.diagonal * 2),
        ),
        color: Color(Styling.primaryBackgroundColor),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  ZText(
                    content: 'Total : ',
                    color: Color(Styling.accentColor),
                    fontSize: SizeConfig.diagonal * 2,
                    fontWeight: FontWeight.bold,
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 20,
                      width: 5,
                      child: LinearProgressIndicator(
                        value: 1,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.lightGreen.shade200),
                        backgroundColor: Colors.lightGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  ZText(
                    content: 'Solana : ',
                    color: Color(Styling.accentColor),
                    fontSize: SizeConfig.diagonal * 2,
                    fontWeight: FontWeight.bold,
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 20,
                      width: 5,
                      child: LinearProgressIndicator(
                        value: 0.5,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.purpleAccent),
                        backgroundColor: Colors.cyan,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  ZText(
                    content: 'Lavinie : ',
                    color: Color(Styling.accentColor),
                    fontSize: SizeConfig.diagonal * 2,
                    fontWeight: FontWeight.bold,
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 20,
                      width: 5,
                      child: LinearProgressIndicator(
                        value: pourcentage.toDouble(),
                        semanticsLabel: "aaaa",
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.orange),
                        backgroundColor:
                            Color(Styling.secondaryBackgroundColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
