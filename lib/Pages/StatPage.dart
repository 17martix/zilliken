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
import 'package:zilliken/Models/StatisticStock.dart';
import 'package:zilliken/Models/StatisticUser.dart';
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

  StatPage({
    required this.auth,
    required this.db,
    required this.userId,
    required this.userRole,
  });
  @override
  _StatPageState createState() => _StatPageState();
}

class _StatPageState extends State<StatPage> {
  ScrollController _scrollController = ScrollController();
  List<DocumentSnapshot<Map<String, dynamic>>> items = [];

  bool isLoading = false;
  bool hasMore = true;

  QuerySnapshot<Map<String, dynamic>>? statref;
  DocumentSnapshot<Map<String, dynamic>>? lastDocument;

  List<BarChartGroupData> rawBarGroups = [];
  List<BarChartGroupData> showingBarGroups = [];
  List<BarChartGroupData> rawPieGroups = [];
  List<BarChartGroupData> sections = [];
  int? touchedGroupIndex;

  final Color rightBarColor = Color(Styling.accentColor);
  final double width = 7;

  int documentLimit = 10;

  num maxY = 1;
  num perc = 1;
  num pourcentage = 0;
  int touchedIndex = 0;

  ScrollController _controller = ScrollController();
  // AnimationController animationController;
  List<StatisticUser> statisticList = [];
  List<StatisticStock> stock = [];

  num totalCount = 0;

  num maxQuantity = 0;

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

    widget.db.getTodayStatisticStock().then((value) {
      //log("valueSize is ${value.length}");
      setState(() {
        stock = value;
      });
      stock.forEach((element) {
        maxQuantity = maxQuantity + element.quantity;
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

      //log('length is ${items.length}');
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: statList(),
    );
  }

  Widget itemCard(Statistic statistic) {
    return Container(
      height: SizeConfig.diagonal * 10,
      child: Card(
        elevation: 8,
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
                    ),
                    ZText(
                      content: " Fbu",
                      color: Color(Styling.iconColor),
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
                    ),
                    ZText(
                      content:
                          "  : ${widget.formatter.format(statistic.date.toDate())}",
                      color: Color(Styling.iconColor),
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
        Padding(
          padding: EdgeInsets.all(SizeConfig.diagonal * 0.5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ZText(
                content: I18n.of(context).dailyTotal,
                textAlign: TextAlign.center,
                color: Color(Styling.iconColor),
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(
              horizontal: SizeConfig.diagonal * 2,
              vertical: SizeConfig.diagonal * 1),
          width: double.infinity,
          height: 1,
          color: Color(Styling.primaryColor),
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
                if (stock.isNotEmpty) stockUser(),
                if (statisticList.isNotEmpty) statUser(),
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
        aspectRatio: 0.8,
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SizeConfig.diagonal * 2),
          ),
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(SizeConfig.diagonal * 1),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    makeTransactionsIcon(),
                    SizedBox(width: SizeConfig.diagonal * 1),
                    ZText(
                      content: I18n.of(context).stockUsed,
                      color: Color(Styling.iconColor),
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(width: SizeConfig.diagonal * 1),
                  ],
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: SizeConfig.diagonal * 1,
                      vertical: SizeConfig.diagonal * 1),
                  width: double.infinity,
                  height: 1,
                  color: Color(Styling.primaryColor),
                ),
                Expanded(
                  child: PieChart(
                    PieChartData(
                        borderData: FlBorderData(
                          show: false,
                        ),
                        sectionsSpace: 2,
                        centerSpaceRadius: 90,
                        sections: showingSections()),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(SizeConfig.diagonal * 1),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: stock.map((e) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Indicator(
                            color: colorsStatStock(stock.indexOf(e)),
                            text: '${e.name}',
                            isSquare: false,
                          ),
                          SizedBox(height: SizeConfig.diagonal * 0.5),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(width: SizeConfig.diagonal * 0.5),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return stock.map((e) {
      int index = stock.indexOf(e);
      return PieChartSectionData(
        color: colorsStatStock(index),
        value: (e.quantity / maxQuantity),
        title: '${e.quantity} ${e.unit}',
        radius: 60.0,
        titleStyle: TextStyle(
            fontSize: SizeConfig.diagonal * 1.5,
            fontWeight: FontWeight.bold,
            color: const Color(0xffffffff)),
      );
    }).toList();
  }

  BarChartGroupData makeGroupData(int x, num y1) {
    return BarChartGroupData(barsSpace: 4, x: x, barRods: [
      BarChartRodData(
        y: y1.toDouble(),
        colors: [rightBarColor],
        width: 3,
      ),
    ]);
  }

  Widget graph() {
    return Container(
      child: AspectRatio(
        aspectRatio: 1.6,
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SizeConfig.diagonal * 2),
          ),
          color: Color(Styling.primaryBackgroundColor),
          child: Padding(
            padding: EdgeInsets.all(SizeConfig.diagonal * 1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    makeTransactionsIcon(),
                    SizedBox(width: SizeConfig.diagonal * 1),
                    ZText(
                      content: I18n.of(context).weeklyinventory,
                      color: Color(Styling.iconColor),
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(width: SizeConfig.diagonal * 1),
                  ],
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: SizeConfig.diagonal * 1,
                      vertical: SizeConfig.diagonal * 1),
                  width: double.infinity,
                  height: 1,
                  color: Color(Styling.primaryColor),
                ),
                Expanded(
                  //flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: BarChart(
                      BarChartData(
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
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    makeTransactionsIcon(),
                    SizedBox(width: SizeConfig.diagonal * 1),
                    ZText(
                      content: I18n.of(context).totalOrders,
                      fontWeight: FontWeight.bold,
                      color: Color(Styling.iconColor),
                    ),
                    SizedBox(width: SizeConfig.diagonal * 1),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.all(SizeConfig.diagonal * 1),
                  child: Expanded(
                    child: Stack(
                      children: [
                        SizedBox(
                          height: SizeConfig.diagonal * 2,
                          width: double.infinity,
                          child: LinearProgressIndicator(
                            value: totalCount.toDouble(),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(Styling.iconColor).withOpacity(0.9),
                            ),
                          ),
                        ),
                        Align(
                          child: ZText(
                            content:
                                "${I18n.of(context).totalCount} : $totalCount ${commandePluriel(totalCount, context)}",
                            color: Color(Styling.primaryBackgroundColor),
                          ),
                          alignment: Alignment.center,
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
        ),
      ],
    );
  }

  Padding statUserItem(StatisticUser statisticUser) {
    return Padding(
      padding: EdgeInsets.all(SizeConfig.diagonal * 1),
      child: Expanded(
        child: Stack(
          children: [
            SizedBox(
              height: SizeConfig.diagonal * 2,
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
              child: ZText(
                content:
                    "${statisticUser.userName}: ${(statisticUser.count)} ${commandePluriel(statisticUser.count!, context)}",
                color: Color(Styling.primaryBackgroundColor),
              ),
              alignment: Alignment.center,
            ),
          ],
        ),
      ),
    );
  }
}
