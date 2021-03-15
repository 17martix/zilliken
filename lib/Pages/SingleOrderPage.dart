import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zilliken/Components/ZAppBar.dart';
import 'package:zilliken/Components/ZCircularProgress.dart';
import 'package:zilliken/Components/ZRaisedButton.dart';
import 'package:zilliken/Helpers/SizeConfig.dart';
import 'package:zilliken/Helpers/Styling.dart';
import 'package:zilliken/Helpers/Utils.dart';
import 'package:zilliken/Models/Fields.dart';
import 'package:zilliken/Models/Order.dart';
import 'package:zilliken/Models/OrderItem.dart';
import 'package:zilliken/Services/Authentication.dart';
import 'package:zilliken/Services/Database.dart';
import 'package:zilliken/i18n.dart';
import 'package:intl/intl.dart';
import 'package:timelines/timelines.dart';

import 'DashboardPage.dart';
import 'DisabledPage.dart';

class SingleOrderPage extends StatefulWidget {
  final Authentication auth;
  final Database db;
  final String userId;
  final String userRole;
  final String orderId;
  final Order clientOrder;
  final DateFormat formatter = DateFormat('dd/MM/yyyy  HH:mm');

  SingleOrderPage({
    this.auth,
    this.db,
    this.userId,
    this.userRole,
    this.orderId,
    this.clientOrder,
  });

  @override
  _SingleOrderPageState createState() => _SingleOrderPageState();
}

class _SingleOrderPageState extends State<SingleOrderPage> {
  var oneOrderDetails;
  var orderItems;
  bool isDataBeingDeleted = false;
  int _status = Fields.confirmed;
  bool _isLoading = false;

  int _orderStatus = 0;
  int enabled = 1;

  @override
  void initState() {
    super.initState();
    _orderStatus = widget.clientOrder.status;
    oneOrderDetails =
        FirebaseFirestore.instance.collection(Fields.order).doc(widget.orderId);

    orderItems = FirebaseFirestore.instance
        .collection(Fields.order)
        .doc(widget.orderId)
        .collection(Fields.items);

    FirebaseFirestore.instance
        .collection(Fields.order)
        .doc(widget.orderId)
        .snapshots()
        .listen((DocumentSnapshot documentSnapshot) {
      setState(() {
        _status = documentSnapshot.data()[Fields.status];
      });
    });

    FirebaseFirestore.instance
        .collection(Fields.configuration)
        .doc(Fields.settings)
        .snapshots()
        .listen((DocumentSnapshot documentSnapshot) {
      setState(() {
        enabled = documentSnapshot.data()[Fields.enabled];
      });
    });
  }

  void backFunction() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => DashboardPage(
          db: widget.db,
          auth: widget.auth,
          userId: widget.userId,
          userRole: widget.userRole,
          index: 1,
        ),
      ),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return WillPopScope(
      onWillPop: () {
        return Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardPage(
              db: widget.db,
              auth: widget.auth,
              userId: widget.userId,
              userRole: widget.userRole,
              index: 1,
            ),
          ),
          (Route<dynamic> route) => false,
        );
      },
      child: enabled == 0
          ? DisabledPage(
              auth: widget.auth,
              db: widget.db,
              userId: widget.userId,
              userRole: widget.userRole,
            )
          : Scaffold(
              appBar: buildAppBar(
                  context, widget.auth, true, false, null, null, backFunction),
              body: Stack(
                children: [
                  body(),
                  ZCircularProgress(_isLoading),
                ],
              ),
            ),
    );
  }

  Widget body() {
    if (isDataBeingDeleted) {
      return Center(
        child: ZCircularProgress(true),
      );
    } else {
      return ListView(
        children: [
          if (widget.userRole == Fields.client) progressionTimeLine(),
          if (widget.userRole == Fields.chef ||
              widget.userRole == Fields.admin ||
              widget.userRole == Fields.developer)
            statusUpdate(),
          orderItemStream(),
          informationStream(),
          Padding(
            padding: EdgeInsets.only(
                left: SizeConfig.diagonal * 0.5,
                right: SizeConfig.diagonal * 0.5),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(SizeConfig.diagonal * 1.5)),
              elevation: 15,
              child: Column(
                children: [
                  billStream(),
                  billStream2(),
                  if ((_status == 1 && widget.userRole == Fields.client) ||
                      widget.userRole == Fields.admin ||
                      widget.userRole == Fields.developer)
                    cancelOrder(),
                ],
              ),
            ),
          )
        ],
      );
    }
  }

  Widget progressionTimeLine() {
    oneOrderDetails.snapshots(includeMetadataChanges: true);
    return Container(
      decoration: BoxDecoration(color: Color(Styling.primaryBackgroundColor)),
      child: StreamBuilder<DocumentSnapshot>(
          stream: oneOrderDetails.snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.data == null)
              return Center(
                child: Text(""),
              );

            Order order = Order();
            order.buildObjectAsync(snapshot);

            return Container(
              width: double.infinity,
              height: SizeConfig.diagonal * 25,
              child: progressStatus(order),
            );
          }),
    );
  }

  Widget progressStatus(Order order) {
    return Padding(
      padding: EdgeInsets.only(
        left: SizeConfig.diagonal * 0.5,
        right: SizeConfig.diagonal * 0.5,
      ),
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SizeConfig.diagonal * 1.5)),
        elevation: 16,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: SizeConfig.diagonal * 1.5,
                bottom: SizeConfig.diagonal * 1.5,
              ),
              child: Text(
                I18n.of(context).orderStatus,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(
                    Styling.textColor,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: SizeConfig.diagonal * 2,
                  right: SizeConfig.diagonal * 2,
                  bottom: SizeConfig.diagonal * 1.5),
              child: Container(
                color: Color(Styling.primaryColor),
                height: 1,
                width: double.infinity,
              ),
            ),
            Expanded(
              child: Timeline(
                scrollDirection: Axis.horizontal,
                children: [
                  TimelineTile(
                    oppositeContents: Padding(
                      padding: EdgeInsets.all(SizeConfig.diagonal * 1),
                      child: Icon(
                        Icons.access_alarm,
                        size: SizeConfig.diagonal * 4,
                        color: order.status == 1
                            ? Color(Styling.accentColor)
                            : Color(Styling.primaryColor),
                      ),
                    ),
                    contents: Container(
                      padding: EdgeInsets.all(SizeConfig.diagonal * 1),
                      child: Text(
                        I18n.of(context).pending,
                        style: TextStyle(
                          color: order.status == 1
                              ? Color(Styling.accentColor)
                              : Color(Styling.primaryColor),
                        ),
                      ),
                    ),
                    direction: Axis.horizontal,
                    node: TimelineNode(
                      direction: Axis.horizontal,
                      indicator: DotIndicator(
                        color: order.status == 1
                            ? Color(Styling.accentColor)
                            : Color(Styling.primaryColor),
                        size: SizeConfig.diagonal * 3,
                        child: order.status == 1
                            ? Padding(
                                padding:
                                    EdgeInsets.all(SizeConfig.diagonal * 1),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Icon(
                                Icons.check,
                                color: Color(Styling.accentColor),
                                size: SizeConfig.diagonal * 2,
                              ),
                      ),
                      startConnector: null,
                      endConnector: SizedBox(
                        width: SizeConfig.diagonal * 4,
                        child: SolidLineConnector(
                          color: order.status < 2
                              ? Color(Styling.textColor).withOpacity(0.2)
                              : Color(Styling.primaryColor),
                        ),
                      ),
                    ),
                  ),
                  TimelineTile(
                    oppositeContents: Padding(
                      padding: EdgeInsets.all(SizeConfig.diagonal * 1),
                      child: Icon(
                        Icons.thumb_up,
                        size: SizeConfig.diagonal * 4,
                        color: order.status == 2
                            ? Color(Styling.accentColor)
                            : order.status < 2
                                ? Color(Styling.textColor).withOpacity(0.2)
                                : Color(Styling.primaryColor),
                      ),
                    ),
                    contents: Container(
                      padding: EdgeInsets.all(SizeConfig.diagonal * 1),
                      child: Text(
                        I18n.of(context).confirmed,
                        style: TextStyle(
                          color: order.status == 2
                              ? Color(Styling.accentColor)
                              : order.status < 2
                                  ? Color(Styling.textColor).withOpacity(0.2)
                                  : Color(Styling.primaryColor),
                        ),
                      ),
                    ),
                    direction: Axis.horizontal,
                    node: TimelineNode(
                      direction: Axis.horizontal,
                      indicator: DotIndicator(
                        color: order.status == 2
                            ? Color(Styling.accentColor)
                            : order.status < 2
                                ? Color(Styling.textColor).withOpacity(0.2)
                                : Color(Styling.primaryColor),
                        size: SizeConfig.diagonal * 3,
                        child: order.status == 2
                            ? Padding(
                                padding:
                                    EdgeInsets.all(SizeConfig.diagonal * 1),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : order.status < 2
                                ? null
                                : Icon(
                                    Icons.check,
                                    color: Color(Styling.accentColor),
                                    size: SizeConfig.diagonal * 2,
                                  ),
                      ),
                      startConnector: SizedBox(
                        width: SizeConfig.diagonal * 4,
                        child: SolidLineConnector(
                          color: order.status < 2
                              ? Color(Styling.textColor).withOpacity(0.2)
                              : Color(Styling.primaryColor),
                        ),
                      ),
                      endConnector: SizedBox(
                        width: SizeConfig.diagonal * 4,
                        child: SolidLineConnector(
                          color: order.status < 3
                              ? Color(Styling.textColor).withOpacity(0.2)
                              : Color(Styling.primaryColor),
                        ),
                      ),
                    ),
                  ),
                  TimelineTile(
                    oppositeContents: Padding(
                      padding: EdgeInsets.all(SizeConfig.diagonal * 1),
                      child: Icon(
                        Icons.kitchen,
                        size: SizeConfig.diagonal * 4,
                        color: order.status == 3
                            ? Color(Styling.accentColor)
                            : order.status < 3
                                ? Color(Styling.textColor).withOpacity(0.2)
                                : Color(Styling.primaryColor),
                      ),
                    ),
                    contents: Container(
                      padding: EdgeInsets.all(SizeConfig.diagonal * 1),
                      child: Text(
                        I18n.of(context).preparing,
                        style: TextStyle(
                          color: order.status == 3
                              ? Color(Styling.accentColor)
                              : order.status < 3
                                  ? Color(Styling.textColor).withOpacity(0.2)
                                  : Color(Styling.primaryColor),
                        ),
                      ),
                    ),
                    direction: Axis.horizontal,
                    node: TimelineNode(
                      direction: Axis.horizontal,
                      indicator: DotIndicator(
                        color: order.status == 3
                            ? Color(Styling.accentColor)
                            : order.status < 3
                                ? Color(Styling.textColor).withOpacity(0.2)
                                : Color(Styling.primaryColor),
                        size: SizeConfig.diagonal * 3,
                        child: order.status == 3
                            ? Padding(
                                padding:
                                    EdgeInsets.all(SizeConfig.diagonal * 1),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : order.status < 3
                                ? null
                                : Icon(
                                    Icons.check,
                                    color: Color(Styling.accentColor),
                                    size: SizeConfig.diagonal * 2,
                                  ),
                      ),
                      startConnector: SizedBox(
                        width: SizeConfig.diagonal * 4,
                        child: SolidLineConnector(
                          color: order.status < 3
                              ? Color(Styling.textColor).withOpacity(0.2)
                              : Color(Styling.primaryColor),
                        ),
                      ),
                      endConnector: SizedBox(
                        width: SizeConfig.diagonal * 4,
                        child: SolidLineConnector(
                          color: order.status < 4
                              ? Color(Styling.textColor).withOpacity(0.2)
                              : Color(Styling.primaryColor),
                        ),
                      ),
                    ),
                  ),
                  TimelineTile(
                    oppositeContents: Padding(
                      padding: EdgeInsets.all(SizeConfig.diagonal * 1),
                      child: Icon(
                        Icons.restaurant_menu,
                        size: SizeConfig.diagonal * 4,
                        color: order.status == 4
                            ? Color(Styling.accentColor)
                            : order.status < 4
                                ? Color(Styling.textColor).withOpacity(0.2)
                                : Color(Styling.primaryColor),
                      ),
                    ),
                    contents: Container(
                      padding: EdgeInsets.all(SizeConfig.diagonal * 1),
                      child: Text(
                        I18n.of(context).served,
                        style: TextStyle(
                          color: order.status == 4
                              ? Color(Styling.accentColor)
                              : order.status < 4
                                  ? Color(Styling.textColor).withOpacity(0.2)
                                  : Color(Styling.primaryColor),
                        ),
                      ),
                    ),
                    direction: Axis.horizontal,
                    node: TimelineNode(
                      direction: Axis.horizontal,
                      indicator: DotIndicator(
                        color: order.status == 4
                            ? Color(Styling.accentColor)
                            : order.status < 4
                                ? Color(Styling.textColor).withOpacity(0.2)
                                : Color(Styling.primaryColor),
                        size: SizeConfig.diagonal * 3,
                        child: order.status < 4
                            ? null
                            : Icon(
                                Icons.check,
                                color: Color(Styling.primaryBackgroundColor),
                                size: SizeConfig.diagonal * 2,
                              ),
                      ),
                      startConnector: SizedBox(
                        width: SizeConfig.diagonal * 4,
                        child: SolidLineConnector(
                          color: order.status < 4
                              ? Color(Styling.textColor).withOpacity(0.2)
                              : Color(Styling.primaryColor),
                        ),
                      ),
                      endConnector: null,
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

  Widget statusUpdate() {
    return Padding(
      padding: EdgeInsets.only(
          left: SizeConfig.diagonal * 0.5, right: SizeConfig.diagonal * 0.5),
      child: Card(
        elevation: 16,
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.all(SizeConfig.diagonal * 1),
              child: Text(
                I18n.of(context).updateStatus,
                style: new TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.diagonal * 1,
                  vertical: SizeConfig.diagonal * 0.5),
              child: Divider(height: 2.0, color: Colors.black),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  new Radio(
                    value: 1,
                    groupValue: _orderStatus,
                    onChanged: handleStatusChange,
                  ),
                  new Text(
                    I18n.of(context).pendingOrder,
                    style: new TextStyle(fontSize: SizeConfig.diagonal * 1.5),
                  ),
                  new Radio(
                    value: 2,
                    groupValue: _orderStatus,
                    onChanged: handleStatusChange,
                  ),
                  new Text(
                    I18n.of(context).confirmedOrder,
                    style: new TextStyle(
                      fontSize: SizeConfig.diagonal * 1.5,
                    ),
                  ),
                  new Radio(
                    value: 3,
                    groupValue: _orderStatus,
                    onChanged: handleStatusChange,
                  ),
                  new Text(
                    I18n.of(context).orderPreparation,
                    style: new TextStyle(
                      fontSize: SizeConfig.diagonal * 1.5,
                    ),
                  ),
                  new Radio(
                    value: 4,
                    groupValue: _orderStatus,
                    onChanged: handleStatusChange,
                  ),
                  new Text(
                    I18n.of(context).orderServed,
                    style: new TextStyle(
                      fontSize: SizeConfig.diagonal * 1.5,
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

  void handleStatusChange(int value) {
    setState(() {
      _orderStatus = value;
    });
    widget.db.updateStatus(widget.orderId, _orderStatus, value);
  }

  Widget orderItemStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: orderItems.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.data == null)
          return Center(
            child: Text(""),
          );

        return Padding(
          padding: EdgeInsets.only(
              left: SizeConfig.diagonal * 0.5,
              right: SizeConfig.diagonal * 0.5),
          child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SizeConfig.diagonal * 1.5)),
            elevation: 16,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      left: SizeConfig.diagonal * 1.5,
                      right: SizeConfig.diagonal * 1.5,
                      top: SizeConfig.diagonal * 1.5,
                      bottom: SizeConfig.diagonal * 1.5),
                  child: Center(
                    child: Text(
                      I18n.of(context).order,
                      style: TextStyle(
                          color: Color(Styling.textColor),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      left: SizeConfig.diagonal * 2,
                      right: SizeConfig.diagonal * 2,
                      bottom: SizeConfig.diagonal * 1.5),
                  child: Container(
                    color: Color(Styling.primaryColor),
                    height: 1,
                    width: double.infinity,
                  ),
                ),
                ListTile(
                  onTap: () {},
                  title: Text(
                    I18n.of(context).items,
                    style: TextStyle(
                      color: Color(Styling.textColor),
                      fontWeight: FontWeight.bold,
                      fontSize: SizeConfig.diagonal * 1.5,
                    ),
                  ),
                  trailing: Text(
                    I18n.of(context).number,
                    style: TextStyle(
                      color: Color(Styling.textColor),
                      fontWeight: FontWeight.bold,
                      fontSize: SizeConfig.diagonal * 1.5,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: snapshot.data.docs.map((DocumentSnapshot document) {
                    OrderItem orderItem = OrderItem();
                    orderItem.buildObject(document);
                    return orderElement(orderItem);
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget orderElement(OrderItem orderItem) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: SizeConfig.diagonal * 1.5,
            right: SizeConfig.diagonal * 1.5,
            bottom: SizeConfig.diagonal * 1.5,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${orderItem.menuItem.name}',
                style: TextStyle(
                  color: Color(Styling.textColor),
                ),
              ),
              Text(
                '${orderItem.count}',
                style: TextStyle(
                  color: Color(Styling.textColor),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget billStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: orderItems.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.data == null)
          return Center(
            child: Text(""),
          );

        return Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                bottom: SizeConfig.diagonal * 1.5,
                top: SizeConfig.diagonal * 1.5,
              ),
              child: Center(
                child: Text(
                  I18n.of(context).billDetails,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: SizeConfig.diagonal * 2,
                  right: SizeConfig.diagonal * 2,
                  bottom: SizeConfig.diagonal * 1.5),
              child: Container(
                color: Color(Styling.primaryColor),
                height: 1,
                width: double.infinity,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: snapshot.data.docs.map((DocumentSnapshot document) {
                OrderItem orderItem = OrderItem();
                orderItem.buildObject(document);
                return billElement(orderItem);
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget billElement(OrderItem orderItem) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: SizeConfig.diagonal * 1.5,
            right: SizeConfig.diagonal * 1.5,
            bottom: SizeConfig.diagonal * 1.5,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${orderItem.menuItem.name} x ${orderItem.count}',
                style: TextStyle(
                  color: Color(Styling.textColor),
                ),
              ),
              Text(
                '${formatNumber(orderItem.menuItem.price)} Fbu',
                style: TextStyle(
                  color: Color(Styling.textColor),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget billStream2() {
    return StreamBuilder<DocumentSnapshot>(
      stream: oneOrderDetails.snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.data == null)
          return Center(
            child: Text(""),
          );

        Order order = Order();
        order.buildObjectAsync(snapshot);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            billElement2(order),
          ],
        );
      },
    );
  }

  Widget billElement2(Order order) {
    int grandTotal;
    if (order.grandTotal is double) {
      grandTotal = order.grandTotal.round();
    } else {
      grandTotal = order.grandTotal;
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: SizeConfig.diagonal * 1.5,
            right: SizeConfig.diagonal * 1.5,
            bottom: SizeConfig.diagonal * 1.5,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${I18n.of(context).taxCharge}',
                style: TextStyle(
                  color: Color(Styling.textColor),
                ),
              ),
              Text(
                appliedTaxFromTotal(context, order.total, order.taxPercentage),
                style: TextStyle(
                  color: Color(Styling.textColor),
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: SizeConfig.diagonal * 1.5,
            right: SizeConfig.diagonal * 1.5,
            bottom: SizeConfig.diagonal * 1.5,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${I18n.of(context).grandTotal}',
                style: TextStyle(
                  color: Color(Styling.textColor),
                ),
              ),
              Text(
                '${formatNumber(grandTotal)} Fbu',
                style: TextStyle(
                  color: Color(Styling.textColor),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget informationStream() {
    return StreamBuilder<DocumentSnapshot>(
      stream: oneOrderDetails.snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.data == null)
          return Center(
            child: Text(""),
          );

        Order order = Order();
        order.buildObjectAsync(snapshot);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            orderInformations(order),
          ],
        );
      },
    );
  }

  Widget orderInformations(Order order) {
    return Padding(
      padding: EdgeInsets.only(
        left: SizeConfig.diagonal * 0.5,
        right: SizeConfig.diagonal * 0.5,
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeConfig.diagonal * 1.5),
        ),
        elevation: 16,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: SizeConfig.diagonal * 1.5,
                bottom: SizeConfig.diagonal * 1.5,
              ),
              child: Text(
                I18n.of(context).orderInformation,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(
                    Styling.textColor,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: SizeConfig.diagonal * 2,
                  right: SizeConfig.diagonal * 2,
                  bottom: SizeConfig.diagonal * 1.5),
              child: Container(
                color: Color(Styling.primaryColor),
                height: 1,
                width: double.infinity,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: SizeConfig.diagonal * 1.5,
                right: SizeConfig.diagonal * 1.5,
                bottom: SizeConfig.diagonal * 1.5,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${I18n.of(context).orderDate}',
                    style: TextStyle(
                      color: Color(
                        Styling.textColor,
                      ),
                    ),
                  ),
                  Text(
                    '${widget.formatter.format(DateTime.fromMillisecondsSinceEpoch(order.orderDate))}',
                    style: TextStyle(
                      color: Color(
                        Styling.textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: SizeConfig.diagonal * 1.5,
                right: SizeConfig.diagonal * 1.5,
                bottom: SizeConfig.diagonal * 1.5,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${tableAddressStatus(order)}',
                    style: TextStyle(
                      color: Color(
                        Styling.textColor,
                      ),
                    ),
                  ),
                  Text(order.tableAdress),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  String tableAddressStatus(Order order) {
    String value;
    if (order.orderLocation == 1) {
      value = I18n.of(context).addr;
    } else {
      value = I18n.of(context).tableNumber;
    }
    return value;
  }

  Widget cancelOrder() {
    return ZRaisedButton(
      leftPadding: SizeConfig.diagonal * 1,
      rightPadding: SizeConfig.diagonal * 1,
      onpressed: () async {
        setState(() {
          isDataBeingDeleted = true;
        });
        await widget.db.cancelOrder(widget.orderId);
        backFunction();
      },
      textIcon: Text(
        I18n.of(context).cancelOrder,
        style: TextStyle(color: Color(Styling.primaryBackgroundColor)),
      ),
    );
  }
}
