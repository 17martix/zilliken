import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zilliken/Components/ZAppBar.dart';
import 'package:zilliken/Helpers/Styling.dart';
import '../i18n.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  CollectionReference commandes =
      FirebaseFirestore.instance.collection('commandes');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      //body: orderlist(),
      body: Column(
        children: [
          order(),
          bill(),
        ],
      ),
    );
  }

  Widget order() {
    return Card(
      elevation: 10,
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Order",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            Container(
              width: double.infinity,
              height: 1,
              color: Colors.black,
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                "sparkiling water / Eau petillante",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            Container(
              width: double.infinity,
              height: 1,
              color: Colors.black,
            ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Text(
                I18n.of(context).sprkling,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            Container(
              width: double.infinity,
              height: 1,
              color: Colors.black,
            ),
            FlatButton.icon(
              onPressed: null,
              icon: Icon(Icons.pause_circle_filled),
              label: Text(
                "Restaurant order"
                "Room Order",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                width: double.infinity,
                height: 1,
                color: Colors.black,
              ),
            ),
            Text(
              "5",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                width: double.infinity,
                height: 1,
                color: Colors.grey,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Do you have instructions?",
                  icon: Icon(Icons.access_alarm),
                ),
                keyboardType: TextInputType.text,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                width: double.infinity,
                height: 1,
                color: Color(Styling.iconColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget bill() {
    return Card(
      elevation: 20,
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(9.0),
              child: Text(
                "Bill",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(Styling.iconColor),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              height: 1,
              color: Color(Styling.accentColor),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Item total",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(Styling.accentColor),
                        ),
                      ),
                      Text("4"),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        I18n.of(context).taxCharge,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(Styling.accentColor),
                        ),
                      ),
                      Text("4"),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Grand Total",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      Text("4"),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              width: double.infinity,
              child: RaisedButton(
                color: Color(Styling.accentColor),
                onPressed: () {},
                child: Text("place order"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget orderlist() {
    return StreamBuilder<QuerySnapshot>(
      stream: commandes.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }

        return new ListView(
          children: snapshot.data.docs.map((DocumentSnapshot document) {
            return new ListTile(
              title: new Text(document.data()['nom']),
              subtitle: new Text(document.data()['category']),
            );
          }).toList(),
        );
      },
    );
  }
}
