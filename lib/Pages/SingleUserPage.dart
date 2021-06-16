import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:zilliken/Components/ZAppBar.dart';
import 'package:zilliken/Components/ZElevatedButton.dart';
import 'package:zilliken/Helpers/SizeConfig.dart';
import 'package:zilliken/Helpers/Styling.dart';
import 'package:zilliken/Helpers/Utils.dart';
import 'package:zilliken/Models/Fields.dart';
import 'package:zilliken/Models/Statistic.dart';
import 'package:zilliken/Models/UserProfile.dart';
import 'package:zilliken/Services/Authentication.dart';
import 'package:zilliken/Services/Database.dart';
import 'package:intl/intl.dart';

import '../Components/ZText.dart';
import '../i18n.dart';

class SingleUserPage extends StatefulWidget {
  final Authentication auth;
  final Database db;
  final String userId;
  final DateFormat formatter = DateFormat('dd/MM/yy hh:mm');
  final DateFormat format = DateFormat('dd/MM');
  final String userRole;
  final UserProfile userData;

  SingleUserPage({
    required this.auth,
    required this.db,
    required this.userId,
    required this.userRole,
    required this.userData,
  });
  @override
  _SingleUserPageState createState() => _SingleUserPageState();
}

class _SingleUserPageState extends State<SingleUserPage> {
  var oneUserDetails;

  List<DocumentSnapshot<Map<String, dynamic>>> items = [];
  ScrollController _scrollController = ScrollController();
  bool isLoading = false;
  bool hasMore = true;

  QuerySnapshot<Map<String, dynamic>>? statref;
  DocumentSnapshot<Map<String, dynamic>>? lastDocument;

  List<BarChartGroupData> rawBarGroups = [];
  List<BarChartGroupData> showingBarGroups = [];
  int? touchedGroupIndex;

  final Color rightBarColor = Color(Styling.accentColor);
  final double width = 7;

  int documentLimit = 10;
  num maxY = 1;
  ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();

    oneUserDetails = FirebaseFirestore.instance
        .collection(Fields.users)
        .doc(widget.userData.id);

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

  void statQuery() async {
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });

    if (lastDocument == null) {
      statref = await widget.db.databaseReference
          .collection(Fields.statisticUser)
          .where(Fields.userId, isEqualTo: widget.userData.id)
          .limit(documentLimit)
          .orderBy(Fields.date, descending: true)
          .get();
    } else {
      statref = await widget.db.databaseReference
          .collection(Fields.statisticUser)
          .where(Fields.userId, isEqualTo: widget.userData.id)
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
    });
  }

  void _actionPression(UserProfile userProfile) async {
    bool isActive = !userProfile.isActive;

    await widget.db.updateIsActive(userProfile.id!, isActive);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
        image: AssetImage('assets/Zilliken.jpg'),
        fit: BoxFit.cover,
      )),
      child: Scaffold(
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
        backgroundColor: Colors.transparent,
      ),
    );
  }

  Widget body() {
    return Column(children: [
      statList(),
      Expanded(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          controller: _controller,
          child: Column(
            children: [
              graph(),
              userStream(),
            ],
          ),
        ),
      ),
    ]);
  }

  Widget itemCard(Statistic statistic) {
    return Container(
      height: SizeConfig.diagonal * 10,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeConfig.diagonal * 1.5),
        ),
        elevation: 8,
        color: Colors.white.withOpacity(0.7),
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
                        Statistic statisticUser =
                            Statistic.buildObject(document);

                        return itemCard(statisticUser);
                      }).toList(),
                    ),
              isLoading
                  ? Container(
                      width: SizeConfig.diagonal * 8,
                      height: SizeConfig.diagonal * 8,
                      padding: EdgeInsets.all(SizeConfig.diagonal * 1.5),
                      child: Card(
                        elevation: 2,
                        color: Colors.white.withOpacity(0.7),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(SizeConfig.diagonal * 1),
                        ),
                        child: CircularProgressIndicator(
                          semanticsLabel: 'Linear progress indicator',
                          backgroundColor: Color(Styling.primaryDarkColor),
                        ),
                      ),
                    )
                  : Container()
            ],
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
    return Container(
      child: AspectRatio(
        aspectRatio: 1.6,
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SizeConfig.diagonal * 2),
          ),
          color: Color(Styling.primaryBackgroundColor).withOpacity(0.7),
          child: Padding(
            padding: EdgeInsets.all(SizeConfig.diagonal * 1),
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: BarChart(
                      BarChartData(
                        maxY: maxY.toDouble(),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: SideTitles(
                            showTitles: true,
                            getTextStyles: (value) => const TextStyle(
                                color: Color(Styling.iconColor), fontSize: 10),
                            margin: 15,
                            reservedSize: 8,
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
            color: Color(Styling.iconColor).withOpacity(0.4),
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

  Widget userStream() {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: oneUserDetails.snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.data == null) return Center(child: ZText(content: ""));
          UserProfile userProfile = UserProfile.buildObjectAsync(snapshot);
          return userDetails(userProfile);
        });
  }

  Widget userDetails(UserProfile userProfile) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SizeConfig.diagonal * 2),
      ),
      color: Color(Styling.primaryBackgroundColor).withOpacity(0.7),
      child: Container(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.diagonal * 1,
                  vertical: SizeConfig.diagonal * 1),
              child: ZText(
                content: '${I18n.of(context).deactivateUser}',
                textAlign: TextAlign.center,
                fontSize: SizeConfig.diagonal * 1.5,
                fontWeight: FontWeight.bold,
                color: Color(Styling.textColor),
              ),
            ),
            Container(
              margin: EdgeInsets.all(SizeConfig.diagonal * 1),
              width: double.infinity,
              height: 1,
              color: Color(Styling.primaryColor),
            ),
            Container(
                child: Padding(
              padding: EdgeInsets.all(SizeConfig.diagonal * 1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ZText(
                    content: '${I18n.of(context).name} :',
                    textAlign: TextAlign.center,
                    fontSize: SizeConfig.diagonal * 1.5,
                    color: Color(Styling.textColor).withOpacity(0.7),
                  ),
                  ZText(
                    content: '${userProfile.name}',
                    textAlign: TextAlign.center,
                    color: Color(Styling.textColor).withOpacity(0.7),
                    fontSize: SizeConfig.diagonal * 1.5,
                  ),
                ],
              ),
            )),
            Container(
              child: Padding(
                padding: EdgeInsets.all(SizeConfig.diagonal * 1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ZText(
                      content: '${I18n.of(context).phone} :',
                      textAlign: TextAlign.center,
                      fontSize: SizeConfig.diagonal * 1.5,
                      color: Color(Styling.textColor).withOpacity(0.7),
                    ),
                    ZText(
                      content: '${userProfile.phoneNumber}',
                      textAlign: TextAlign.center,
                      color: Color(Styling.textColor).withOpacity(0.7),
                      fontSize: SizeConfig.diagonal * 1.5,
                    ),
                  ],
                ),
              ),
            ),
            if (userProfile.role == 'admin')
              ZElevatedButton(
                  child: Text(userProfile.isActive
                      ? "${I18n.of(context).desactive}"
                      : "${I18n.of(context).active}"),
                  onpressed: () => _actionPression(userProfile)),
          ],
        ),
      ),
    );
  }
}
