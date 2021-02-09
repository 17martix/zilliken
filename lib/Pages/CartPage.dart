import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zilliken/Components/ZAppBar.dart';
import 'package:zilliken/Helpers/Styling.dart';
import 'package:zilliken/Models/MenuItem.dart';
import 'package:zilliken/Models/OrderItem.dart';
import 'package:zilliken/Services/Authentication.dart';
import 'package:zilliken/Services/Database.dart';
import '../i18n.dart';

class CartPage extends StatefulWidget {
  final List<OrderItem> clientOrder = [
    OrderItem(
      count: 2,
      menuItem: MenuItem(
          availability: 1,
          id: "ffffaf",
          name: "The",
          category: "Boissons",
          price: 2000,
          rank: 2,
          global: 2,
          createdAt: 2424524),
    ),
    OrderItem(
      count: 2,
      menuItem: MenuItem(
          availability: 1,
          id: "ffffaf",
          name: "Cafe",
          category: "Boissons",
          price: 4000,
          rank: 3,
          global: 3,
          createdAt: 42353),
    ),
  ];
  final String userId;
  final String userRole;
  final Database db;
  final Authentication auth;

  CartPage({
    this.auth,
    //this.clientOrder,
    this.db,
    this.userId,
    this.userRole,
  });

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int restaurantOrRoomOrder = 0;
  int abc = 1;

  TextEditingController choiceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      //body: orderlist(),

      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            orderItems(),
            order(),
            bill(),
          ],
        ),
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
            showOrder(),
            showChoice(),
          ],
        ),
      ),
    );
  }

  Widget orderItems() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            I18n.of(context).orders,
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
        ListView.builder(
          shrinkWrap: true,
          itemCount: widget.clientOrder.length,
          itemBuilder: (context, position) {
            return ListTile(
              leading: Icon(
                Icons.restaurant_menu,
                color: Color(Styling.iconColor),
              ),
              title: Text(widget.clientOrder[position].menuItem.name),
              subtitle: Text("${widget.clientOrder[position].menuItem.price}"),
            );
          },
        ),
      ],
    );
  }

  Widget showOrder() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            I18n.of(context).orderKind,
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
      ],
    );
  }

  void restaurantRoomChange(int value) {
    setState(() {
      restaurantOrRoomOrder = value;
      choiceController.clear();
    });
  }

  Widget showChoice() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Radio(
                  value: 0,
                  groupValue: restaurantOrRoomOrder,
                  onChanged: restaurantRoomChange),
              Text(I18n.of(context).restaurantOrder),
              Radio(
                value: 1,
                groupValue: restaurantOrRoomOrder,
                onChanged: restaurantRoomChange,
              ),
              Text(I18n.of(context).roomOrder),
            ],
          ),
        ),
        TextField(
          controller: choiceController,
          decoration: InputDecoration(
            labelText: restaurantOrRoomOrder == 0
                ? "numero de table"
                : "numero de chambre",
            icon: restaurantOrRoomOrder == 0
                ? Icon(
                    Icons.restaurant_menu,
                    color: Color(Styling.accentColor),
                  )
                : Icon(
                    Icons.single_bed,
                    color: Color(Styling.accentColor),
                  ),
          ),
        ),

        /*FlatButton.icon(
          onPressed: null,
          icon: Icon(Icons.pause_circle_filled),
          label: Text(
            "Restaurant order"
            "Room Order",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(Styling.iconColor),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Container(
            width: double.infinity,
            height: 1,
            color: Color(Styling.accentColor),
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
            color: Color(Styling.accentColor),
          ),
        ),*/
        Padding(
          padding: EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              labelText: I18n.of(context).instruction,
              icon: Icon(
                Icons.info,
                color: Color(Styling.accentColor),
              ),
            ),
            keyboardType: TextInputType.text,
          ),
        ),
      ],
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
                I18n.of(context).bil,
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
                        I18n.of(context).total,
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
                child: Text(
                  I18n.of(context).ordPlace,
                  style: TextStyle(
                    color: Color(Styling.iconColor),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
