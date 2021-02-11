import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:zilliken/Components/ZAppBar.dart';
import 'package:zilliken/Helpers/SizeConfig.dart';
import 'package:zilliken/Helpers/Styling.dart';
import 'package:zilliken/Models/Fields.dart';
import 'package:zilliken/Models/Order.dart';
import 'package:zilliken/Models/OrderItem.dart';
import 'package:zilliken/Services/Authentication.dart';
import 'package:zilliken/Services/Database.dart';
import 'package:zilliken/i18n.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';

class SingleOrderPage extends StatefulWidget {
  final Authentication auth;
  final Database db;
  final String userId;
  final String userRole;
  final String orderId;
  final DateFormat formatter = DateFormat('dd/MM/yyyy  HH:mm');

  SingleOrderPage({
    this.auth,
    this.db,
    this.userId,
    this.userRole,
    this.orderId,
  });

  @override
  _SingleOrderPageState createState() => _SingleOrderPageState();
}

class _SingleOrderPageState extends State<SingleOrderPage> {
  var oneOrderDetails;
  var orderItems;

  @override
  void initState() {
    super.initState();

    oneOrderDetails =
        FirebaseFirestore.instance.collection(Fields.order).doc(widget.orderId);

    orderItems = FirebaseFirestore.instance
        .collection(Fields.order)
        .doc(widget.orderId)
        .collection(Fields.items);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Color(Styling.primaryColor),
      appBar: buildAppBar(context),
      body: ListView(
        children: [
          visualStatus(),
          orderItemStream(),
          billStream(),
          informationStream(),
        ],
      ),
    );
  }

  Widget visualStatus() {
    return Container(
      child: Column(
        children: [
          TimelineTile(
            alignment: TimelineAlign.center,
            isFirst: true,
          ),
          TimelineTile(
            alignment: TimelineAlign.center,
          ),
          TimelineTile(
            alignment: TimelineAlign.center,
          ),
          TimelineTile(
            alignment: TimelineAlign.center,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget orderItemStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: orderItems.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        return Padding(
          padding: EdgeInsets.only(
              left: SizeConfig.diagonal * 0.5,
              right: SizeConfig.diagonal * 0.5),
          child: Card(
            elevation: 15,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: SizeConfig.diagonal * 1.5,
                    right: SizeConfig.diagonal * 1.5,
                    top: SizeConfig.diagonal * 1.5,
                  ),
                  child: Center(child: Text(I18n.of(context).order)),
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
        return Padding(
          padding: EdgeInsets.only(
              left: SizeConfig.diagonal * 0.5,
              right: SizeConfig.diagonal * 0.5),
          child: Card(
            elevation: 15,
            child: Column(
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
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: snapshot.data.docs.map((DocumentSnapshot document) {
                    OrderItem orderItem = OrderItem();
                    orderItem.buildObject(document);
                    return billElement(orderItem);
                  }).toList(),
                ),
              ],
            ),
          ),
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
                '${orderItem.menuItem.price}',
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
        elevation: 15,
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
                  color: Color(
                    Styling.textColor,
                  ),
                ),
                textAlign: TextAlign.center,
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
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
