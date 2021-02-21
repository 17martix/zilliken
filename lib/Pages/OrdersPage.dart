import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zilliken/Helpers/SizeConfig.dart';
import 'package:zilliken/Helpers/Utils.dart';
import 'package:zilliken/Models/Fields.dart';
import 'package:zilliken/Models/Order.dart';
import 'package:zilliken/Pages/SingleOrderPage.dart';
import 'package:zilliken/Services/Authentication.dart';
import 'package:intl/intl.dart';
import 'package:zilliken/Services/Database.dart';

import '../i18n.dart';

class OrdersPage extends StatefulWidget {
  final Authentication auth;
  final Database db;
  final String userId;
  final String userRole;
  final DateFormat formatter = DateFormat('dd/MM/yy HH:mm');

  OrdersPage({
    this.auth,
    this.db,
    this.userId,
    this.userRole,
  });

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  var commandes;

  @override
  void initState() {
    super.initState();

    if (widget.userRole == Fields.client) {
      setState(() {
        commandes = FirebaseFirestore.instance
            .collection(Fields.order)
            .where(Fields.userId, isEqualTo: widget.userId)
            .orderBy(Fields.status, descending: false);
      });
    } else {
      setState(() {
        commandes = FirebaseFirestore.instance
            .collection(Fields.order)
            .orderBy(Fields.status, descending: false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    log("mon id est ${widget.userId} et mo role est ${widget.userRole}");
    SizeConfig().init(context);
    return Scaffold(
      body: ordersList(),
    );
  }

  Widget item(Order order) {
    return Padding(
      padding: EdgeInsets.only(
          left: SizeConfig.diagonal * 1, right: SizeConfig.diagonal * 1),
      child: Card(
        elevation: 25,
        color: Colors.white70,
        child: ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SingleOrderPage(
                  auth: widget.auth,
                  db: widget.db,
                  userId: widget.userId,
                  userRole: widget.userRole,
                  orderId: order.id,
                  clientOrder: order,
                ),
              ),
            );
          },
          leading: Icon(
            order.orderLocation == 0
                ? Icons.restaurant_menu
                : FontAwesomeIcons.shoppingBag,
            size: SizeConfig.diagonal * 3,
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  '${orderStatus(context, order)}',
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: colorPicker(order.status),
                      fontSize: SizeConfig.diagonal * 1.5),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '${I18n.of(context).total} : ${order.grandTotal} ${I18n.of(context).fbu}',
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: SizeConfig.diagonal * 1.5),
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: EdgeInsets.only(top: SizeConfig.diagonal * 1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    order.orderLocation == 0
                        ? '${I18n.of(context).tableNumber} : ${order.tableAdress}'
                        : '${I18n.of(context).address} : ${order.tableAdress}',
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: SizeConfig.diagonal * 1.5),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    '${widget.formatter.format(DateTime.fromMillisecondsSinceEpoch(order.orderDate))}',
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: SizeConfig.diagonal * 1.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color colorPicker(int status) {
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
        if (snapshot.data == null) {
          return Center(
            child: Text(""),
          );
        }

        return ListView(
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
