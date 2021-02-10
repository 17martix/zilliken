import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:zilliken/Components/ZAppBar.dart';
import 'package:zilliken/Helpers/Styling.dart';
import 'package:zilliken/Models/Fields.dart';
import 'package:zilliken/Models/Order.dart';
import 'package:zilliken/Services/Authentication.dart';
import 'package:zilliken/Services/Database.dart';
import 'package:zilliken/i18n.dart';
import 'package:intl/intl.dart';

class SingleOrderPage extends StatefulWidget {
  final Authentication auth;
  final Database db;
  final String userId;
  final String userRole;
  final String orderId;
  final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');

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

  @override
  void initState() {
    super.initState();

    oneOrderDetails =
        FirebaseFirestore.instance.collection('order').doc(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: ListView(
        children: [
          orderDetails(),
          listStream(),
        ],
      ),
    );
  }

  Widget listStream() {
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
            billDetails(order),
          ],
        );
      },
    );
  }

  Widget orderDetails() {
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5),
      child: Card(
        elevation: 15,
        child: Container(
          child: ListBody(
            children: [
              Column(
                children: [
                  Center(child: Text(I18n.of(context).order)),
                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text('Items'), Text('Number')],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Title 1'),
                        Text('Title 2'),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget orderInformations(Order order) {
    return Padding(
      padding: EdgeInsets.only(left: 8, right: 8),
      child: Card(
        elevation: 15,
        child: Column(
          children: [
            Text(
              I18n.of(context).orderInformation,
              style: TextStyle(
                color: Color(
                  Styling.textColor,
                ),
              ),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${I18n.of(context).orderDate}'),
                  Text(
                    '${widget.formatter.format(DateTime.fromMillisecondsSinceEpoch(order.orderDate))}',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${I18n.of(context).tableNumber}'),
                  Text('${order.roomTableNumber}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget billDetails(Order order) {
    return Padding(
      padding: EdgeInsets.only(left: 8, right: 8),
      child: Card(
        elevation: 15,
        child: Column(
          children: [
            Text(
              I18n.of(context).billDetails,
              style: TextStyle(
                color: Color(
                  Styling.textColor,
                ),
              ),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${order.clientOrder}'),
                  Text('${order.total}')
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
