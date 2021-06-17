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
import 'package:collection/collection.dart';

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
  bool isLoading = false;
  bool hasMore = true;
  int documentLimit = 25;
  ScrollController _scrollController = ScrollController();
  DocumentSnapshot? lastDocument;
  late Query<Map<String, dynamic>> orderRef;
  List<DocumentSnapshot<Map<String, dynamic>>> items = [];

  @override
  void initState() {
    super.initState();

    orderQuery();
    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.20;
      if (maxScroll - currentScroll <= delta) {
        orderQuery();
      }
    });
  }

  void orderQuery() {
    if (!hasMore) {
      return;
    }

    if (isLoading == true) {
      return;
    }

    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    if (lastDocument == null) {
      if (widget.userRole == Fields.client) {
        orderRef = widget.db.databaseReference
            .collection(Fields.order)
            .where(Fields.userId, isEqualTo: widget.userId)
            .orderBy(Fields.status, descending: false)
            .limit(documentLimit);
      } else {
        orderRef = widget.db.databaseReference
            .collection(Fields.order)
            .orderBy(Fields.status, descending: false)
            .limit(documentLimit);
      }
    } else {
      if (widget.userRole == Fields.client) {
        orderRef = widget.db.databaseReference
            .collection(Fields.order)
            .where(Fields.userId, isEqualTo: widget.userId)
            .orderBy(Fields.status, descending: false)
            .startAfterDocument(lastDocument!)
            .limit(documentLimit);
      } else {
        orderRef = widget.db.databaseReference
            .collection(Fields.order)
            .orderBy(Fields.status, descending: false)
            .startAfterDocument(lastDocument!)
            .limit(documentLimit);
      }
    }

    orderRef.get().then((QuerySnapshot<Map<String, dynamic>> snapshot) {
      if (snapshot.docs.length < documentLimit) {
        hasMore = false;
      }

      if (snapshot.docs.length > 0)
        lastDocument = snapshot.docs[snapshot.docs.length - 1];

      if (mounted) {
        setState(() {
          for (int i = 0; i < snapshot.docs.length; i++) {
            Object? exist = items.firstWhereOrNull((Object element) {
              if (element is DocumentSnapshot<Map<String, dynamic>>) {
                bool isEqual = element.id == snapshot.docs[i].id;
                return isEqual;
              } else {
                return false;
              }
            });

            if (exist == null) {
              items.add(snapshot.docs[i]);
            }
          }

          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ordersList(),
    );
  }

  Widget item(Order order) {
    return Container(
      width: double.infinity,
      child: Padding(
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
    return ListView(
      controller: _scrollController,
      children: [
        items.length == 0
            ? Center(
                child: ZText(content: ""),
              )
            : Column(
                children: items
                    .map((DocumentSnapshot<Map<String, dynamic>> document) {
                  Order order = Order.buildObject(document);
                  return item(order);
                }).toList(),
              ),
        isLoading
            ? Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(SizeConfig.diagonal * 1),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation(Color(Styling.accentColor)),
                  ),
                ),
              )
            : Container()
      ],
    );
  }
}
