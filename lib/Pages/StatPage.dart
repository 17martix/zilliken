import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:zilliken/Components/Indicator.dart';

import 'package:zilliken/Helpers/SizeConfig.dart';
import 'package:zilliken/Helpers/Styling.dart';
import 'package:zilliken/Helpers/Utils.dart';
import 'package:zilliken/Models/Fields.dart';

import 'package:zilliken/Models/Statistic.dart';
import 'package:intl/intl.dart';
import 'package:zilliken/Models/StatisticUser.dart';
import 'package:zilliken/Models/UserProfile.dart';
import 'package:zilliken/Services/Authentication.dart';
import 'package:zilliken/Services/Database.dart';
import 'package:zilliken/i18n.dart';

import 'package:flutter/foundation.dart';

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
  int touchedIndex = 0;

  ScrollController _controller = ScrollController();
  // AnimationController animationController;
  List<StatisticUser> statisticList = [];

  num totalCount = 0;

  void initState() {
    super.initState();

    widget.db.getTodayStatUser().then((value) {
      setState(() {
        statisticList = value;
      });

      statisticList.forEach((element) {
        totalCount = totalCount + element.count!;
      });
    });

    
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
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(SizeConfig.diagonal * 1.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ZText(
                      content: formatNumber(statistic.total),
                      color: Color(Styling.accentColor),
                      fontSize: SizeConfig.diagonal * 2,
                    ),
                    ZText(
                      content: " Fbu",
                      color: Color(Styling.iconColor),
                      fontSize: SizeConfig.diagonal * 1.5,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(SizeConfig.diagonal * 1.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ZText(
                      content: I18n.of(context).date,
                      textAlign: TextAlign.center,
                      color: Color(Styling.iconColor),
                      fontSize: SizeConfig.diagonal * 1.5,
                    ),
                    ZText(
                      content:
                          "  : ${widget.formatter.format(statistic.date.toDate())}",
                      color: Color(Styling.iconColor),
                      fontSize: SizeConfig.diagonal * 1.5,
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
              content: I18n.of(context).dailyTotal,
              textAlign: TextAlign.center,
              color: Color(Styling.iconColor),
              fontSize: SizeConfig.diagonal * 2,
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
                stockUser(),
                statUser(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget stockUser() {
    return Container(
      child: AspectRatio(
      aspectRatio: 1.3,
      child: Card(
        color: Colors.white,
        child: Row(
          children: <Widget>[
            const SizedBox(
              height: 18,
            ),
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: PieChart(
                  PieChartData(
                      pieTouchData: PieTouchData(touchCallback: (pieTouchResponse) {
                        setState(() {
                          final desiredTouch = pieTouchResponse.touchInput is! PointerExitEvent &&
                              pieTouchResponse.touchInput is! PointerUpEvent;
                          if (desiredTouch && pieTouchResponse.touchedSection != null) {
                            touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                          } else {
                            touchedIndex = -1;
                          }
                        });
                      }),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      sectionsSpace: 0,
                      centerSpaceRadius: 40,
                      sections: showingSections()),
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                Indicator(
                  color: Color(0xff0293ee),
                  text: 'First',
                  isSquare: true,
                ),
                SizedBox(
                  height: 4,
                ),
                Indicator(
                  color: Color(0xfff8b250),
                  text: 'Second',
                  isSquare: true,
                ),
                SizedBox(
                  height: 4,
                ),
                Indicator(
                  color: Color(0xff845bef),
                  text: 'Third',
                  isSquare: true,
                ),
                SizedBox(
                  height: 4,
                ),
                Indicator(
                  color: Color(0xff13d38e),
                  text: 'Fourth',
                  isSquare: true,
                ),
                SizedBox(
                  height: 18,
                ),
              ],
            ),
            const SizedBox(
              width: 28,
            ),
          ],
        ),
      ),
      ),
    );
  }


   List<PieChartSectionData> showingSections() {
    return List.generate(4, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: const Color(0xff0293ee),
            value: 40,
            title: '40%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize, fontWeight: FontWeight.bold, color: const Color(0xffffffff)),
          );
        case 1:
          return PieChartSectionData(
            color: const Color(0xfff8b250),
            value: 30,
            title: '30%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize, fontWeight: FontWeight.bold, color: const Color(0xffffffff)),
          );
        case 2:
          return PieChartSectionData(
            color: const Color(0xff845bef),
            value: 15,
            title: '15%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize, fontWeight: FontWeight.bold, color: const Color(0xffffffff)),
          );
        case 3:
          return PieChartSectionData(
            color: const Color(0xff13d38e),
            value: 15,
            title: '15%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize, fontWeight: FontWeight.bold, color: const Color(0xffffffff)),
          );
        default:
          throw Error();
      }
    });
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
        aspectRatio: 1.6,
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
              mainAxisSize: MainAxisSize.min,
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
                    ZText(
                        content: I18n.of(context).weeklyinventory,
                        color: Color(Styling.iconColor),
                        fontSize: SizeConfig.diagonal * 2),
                    const SizedBox(
                      width: 5,
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.all(SizeConfig.diagonal * 2),
                  height: 1,
                  color: Color(Styling.iconColor),
                  padding: EdgeInsets.all(SizeConfig.diagonal * 3),
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
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: SideTitles(
                            showTitles: true,
                            getTextStyles: (value) => const TextStyle(
                              color: Color(Styling.iconColor),
                              fontSize: 10,
                            ),
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
                              fontSize: 10,
                            ),
                            margin: 20,
                            reservedSize: 26,
                            interval: maxY / 4,
                            getTitles: (value) {
                              // log("value is $value");
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
            color: Color(Styling.iconColor).withOpacity(0.3),
          ),
          const SizedBox(
            width: space,
          ),
          Container(
            width: width,
            height: 10,
            color: Color(Styling.iconColor).withOpacity(0.6),
          ),
          const SizedBox(
            width: space,
          ),
          Container(
            width: width,
            height: 10,
            color: Color(Styling.iconColor).withOpacity(0.9),
          ),
          const SizedBox(
            width: space,
          ),
        ]);
  }

  Widget statUser() {
    return Column(
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SizeConfig.diagonal * 2),
          ),
          color: Color(Styling.primaryBackgroundColor),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(padding: const EdgeInsets.all(6.0)),
              ZText(
                content: I18n.of(context).totalOrders,
                fontSize: SizeConfig.diagonal * 2,
                color: Color(Styling.iconColor),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Expanded(
                  child: Stack(
                    children: [
                      SizedBox(
                        height: 17,
                        width: double.infinity,
                        child: LinearProgressIndicator(
                          value: totalCount.toDouble(),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(Styling.iconColor).withOpacity(0.9),
                          ),
                        ),
                      ),
                      Align(
                        child: Text(
                          "${I18n.of(context).totalCount} : $totalCount ${commandePluriel(totalCount, context)}",
                          style: TextStyle(
                            color: Color(Styling.primaryBackgroundColor),
                          ),
                        ),
                        alignment: Alignment.topCenter,
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: statisticList.map((userStat) {
                  return statUserItem(userStat);
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Padding statUserItem(StatisticUser statisticUser) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Expanded(
        child: Stack(
          children: [
            SizedBox(
              height: 17,
              width: double.infinity,
              child: LinearProgressIndicator(
                value: statisticUser.count! / totalCount,
                backgroundColor:
                    Color(Styling.transparentBackgroundDark).withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(Styling.iconColor).withOpacity(0.8),
                ),
              ),
            ),
            Align(
              child: Text(
                "${statisticUser.userName}: ${(statisticUser.count)} ${commandePluriel(statisticUser.count!, context)}",
                style: TextStyle(
                  color: Color(Styling.primaryBackgroundColor),
                ),
              ),
              alignment: Alignment.topCenter,
            ),
          ],
        ),
      ),
    );
  }
}
