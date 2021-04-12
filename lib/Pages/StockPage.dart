import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zilliken/Helpers/SizeConfig.dart';
import 'package:zilliken/Helpers/Styling.dart';
import 'package:zilliken/Models/Fields.dart';
import 'package:zilliken/Models/Stock.dart';
import 'package:zilliken/Services/Authentication.dart';
import 'package:zilliken/Services/Database.dart';
import 'package:zilliken/Services/Messaging.dart';
import 'package:zilliken/i18n.dart';

class StockPage extends StatefulWidget {
  final Authentication auth;
  final Database db;
  final Messaging messaging;
  final String userId;
  final String userRole;

  StockPage({
    this.auth,
    this.db,
    this.messaging,
    this.userId,
    this.userRole,
  });

  @override
  _StockPageState createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  CollectionReference item =
      FirebaseFirestore.instance.collection(Fields.stock);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: itemStream(),
      floatingActionButton: CircleAvatar(
        radius: SizeConfig.diagonal * 3.5,
        backgroundColor: Color(Styling.accentColor),
        child: IconButton(
          color: Color(Styling.textColor),
          icon: Icon(Icons.add),
          onPressed: () {},
        ),
      ),
    );
  }

  Widget itemStream() {
    return StreamBuilder<QuerySnapshot>(
        stream: item.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.data == null)
            return Center(
              child: Text(''),
            );

          return ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: snapshot.data.docs.length,
              itemBuilder: (BuildContext context, index) {
                Stock stock = Stock();
                stock.buildObject(snapshot.data.docs[index]);
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    itemTile(stock),
                  ],
                );
              });
        });
  }

  Widget itemTile(Stock stock) {
    return Card(
      margin: EdgeInsets.symmetric(
          horizontal: SizeConfig.diagonal * 0.9,
          vertical: SizeConfig.diagonal * 0.3),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeConfig.diagonal * 1.5)),
      elevation: 8,
      child: ListTile(
        onTap: () {},
        leading: Icon(
          Icons.food_bank,
          size: SizeConfig.diagonal * 4,
        ),
        title: Text(stock.name),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(I18n.of(context).quantity + ' : ' + '${stock.quantity}'),
            Text(I18n.of(context).used + ' : ' + '${stock.usedSince}'),
          ],
        ),
      ),
    );
  }
}
