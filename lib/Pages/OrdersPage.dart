import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zilliken/Helpers/SizeConfig.dart';
import 'package:zilliken/Helpers/Styling.dart';
import 'package:zilliken/Helpers/Utils.dart';
import 'package:zilliken/Models/Fields.dart';
import 'package:zilliken/Models/Order.dart';
import 'package:zilliken/Pages/SingleOrderPage.dart';
import 'package:zilliken/Services/Authentication.dart';
import 'package:intl/intl.dart';
import 'package:zilliken/Services/Database.dart';
import 'package:zilliken/Services/Messaging.dart';

import '../Components/ZText.dart';
import '../i18n.dart';

class OrdersPage extends StatefulWidget {
  final Authentication auth;
  final Database db;
  final String userId;
  final String userRole;
  final Messaging messaging;
  final DateFormat formatter = DateFormat('dd/MM/yy HH:mm');

  OrdersPage({
    required this.auth,
    required this.db,
    required this.userId,
    required this.userRole,
    required this.messaging,
  });

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late Query<Map<String, dynamic>> commandes;

  @override
  void initState() {
    super.initState();

    if (widget.userRole == Fields.client) {
      setState(() {
        commandes = FirebaseFirestore.instance
            .collection(Fields.order)
            .where(Fields.userId, isEqualTo: widget.userId)
            .orderBy(Fields.status, descending: false);
        //.orderBy(Fields.orderDate, descending: true);
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
    // log("mon id est ${widget.userId} et mo role est ${widget.userRole}");
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ordersList(),
    );
  }

  Widget item(Order order) {
    return Padding(
      padding: EdgeInsets.only(
          left: SizeConfig.diagonal * 0.2, right: SizeConfig.diagonal * 0.2),
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SizeConfig.diagonal * 1.5)),
        elevation: 16,
        color: Colors.white.withOpacity(0.8),
        child: Container(
          alignment: Alignment.center,
          height: SizeConfig.diagonal * 10,
          width: SizeConfig.diagonal * 10,
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
                    orderId: order.id!,
                    clientOrder: order,
                    messaging: widget.messaging,
                  ),
                ),
              );
            },
            leading: Padding(
              padding: EdgeInsets.only(top: SizeConfig.diagonal * 1),
              child: Icon(
                order.orderLocation == 0
                    ? FontAwesomeIcons.listAlt
                    : FontAwesomeIcons.truckMoving,
                size: 25,
                color: Color(Styling.accentColor),
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 1,
                  child: ZText(
                      content: '${orderStatus(context, order)}',
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      color: colorPicker(order.status),
                      fontSize: SizeConfig.diagonal * 1.5),
                ),
                Expanded(
                  flex: 1,
                  child: ZText(
                      content:
                          '${I18n.of(context).total} : ${formatNumber(order.grandTotal)} ${I18n.of(context).fbu}',
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                      fontSize: SizeConfig.diagonal * 1.5),
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
                    child: ZText(
                        content: order.orderLocation == 0
                            ? '${I18n.of(context).tableNumber} : ${order.tableAdress}'
                            : '${I18n.of(context).address} : ${order.tableAdress}',
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        fontSize: SizeConfig.diagonal * 1.5),
                  ),
                  Expanded(
                    flex: 1,
                    child: ZText(
                        content: order.orderDate == null
                            ? ""
                            : '${widget.formatter.format(order.orderDate!.toDate())}',
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                        fontSize: SizeConfig.diagonal * 1.5),
                  ),
                ],
              ),
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
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: commandes.snapshots(),
      builder: (BuildContext context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.data == null || snapshot.data!.docs.length <= 0) {
          return Center(
            child: ZText(
              content: I18n.of(context).orderPlaceholder,
              textAlign: TextAlign.center,
              fontSize: SizeConfig.diagonal * 2,
              color: Color(Styling.primaryColor),
              fontWeight: FontWeight.bold,
            ),
          );
        }

        return ListView(
          children: snapshot.data!.docs
              .map((DocumentSnapshot<Map<String, dynamic>> document) {
            Order order = Order.buildObject(document);

            return item(order);
          }).toList(),
        );
      },
    );
  }
}
