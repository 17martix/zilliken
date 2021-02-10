import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zilliken/Helpers/Utils.dart';
import 'package:zilliken/Models/Fields.dart';
import 'package:zilliken/Models/Order.dart';
import 'package:zilliken/Services/Authentication.dart';
import 'package:intl/intl.dart';

import '../i18n.dart';

class OrdersPage extends StatefulWidget {
  final Authentication auth;
  final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');

  OrdersPage({this.auth});

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  CollectionReference commandes =
      FirebaseFirestore.instance.collection('order');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ordersList(),
    );
  }

  /*Widget listView() {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: item(),
        )
      ],
    );
  }*/

  Widget item(Order order) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5),
      child: Card(
        elevation: 25,
        color: Colors.white70,
        child: ListTile(
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.restaurant_menu),
            ],
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${orderStatus(context, order)}',
                style: TextStyle(color: colorPicker(order.status)),
              ),
              Text('${I18n.of(context).total} : ${order.grandTotal}'),
            ],
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  '${I18n.of(context).tableNumber} : ${order.roomTableNumber}'),
              Text(
                  '${I18n.of(context).orderDate} : ${widget.formatter.format(DateTime.fromMillisecondsSinceEpoch(order.orderDate))}'),
            ],
          ),
        ),
      ),
    );
  }

  Color colorPicker(String status) {
    Color textColor = Colors.black;
    if (status == Fields.pending)
      textColor = Colors.red;
    else if (status == Fields.confirmed)
      textColor = Colors.green;
    else if (status == Fields.preparation)
      textColor = Colors.orange;
    else if (status == Fields.served) textColor = Colors.blue;

    return textColor;
  }

  Widget ordersList() {
    return StreamBuilder<QuerySnapshot>(
      stream: commandes.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text(I18n.of(context).error);
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(I18n.of(context).loading);
        }

        return new ListView(
          children: snapshot.data.docs.map((DocumentSnapshot document) {
            Order order = Order();
            order.buildObject(document);
            return item(order);
          }).toList(),
        );
      },
    );
  }
}
