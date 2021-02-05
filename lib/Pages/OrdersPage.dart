import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zilliken/Components/ZAppBar.dart';
import 'package:zilliken/Helpers/Styling.dart';
import 'package:zilliken/Services/Authentication.dart';

import '../i18n.dart';

class OrdersPage extends StatefulWidget {
  Authentication auth;
  OrdersPage({this.auth});

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  CollectionReference commandes =
      FirebaseFirestore.instance.collection('commandes');

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

  Widget item(String nom, String category, int prix) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
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
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(nom),
              Text(category),
            ],
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('$prix'),
              Text('Hello 4'),
            ],
          ),
        ),
      ),
    );
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
            return item(document.data()['nom'], document.data()['category'],
                document.data()['prix']);
          }).toList(),
        );
      },
    );
  }
}
