import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zilliken/Components/ZAppBar.dart';
import 'package:zilliken/Components/ZRaisedButton.dart';
import 'package:zilliken/Components/ZTextField.dart';
import 'package:zilliken/Helpers/Styling.dart';
import 'package:zilliken/Helpers/Utils.dart';
import 'package:zilliken/Models/MenuItem.dart';
import 'package:zilliken/Models/Order.dart';
import 'package:zilliken/Models/OrderItem.dart';
import 'package:zilliken/Pages/SingleOrderPage.dart';
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

  int tax = 0;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String tableAdress;

  String phone;

  String instruction;

  @override
  void initState() {
    super.initState();
    widget.db.getTax().then((value) {
      setState(() {
        tax = value;
      });
    });
  }

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
              Text(I18n.of(context).livrdomicile),
            ],
          ),
        ),
        Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ZTextField(
                controller: choiceController,
                onSaved: (newValue) => tableAdress = newValue,
                validator: (value) =>
                    value.isEmpty ? I18n.of(context).requit : null,
                keyboardType: restaurantOrRoomOrder == 0
                    ? TextInputType.number
                    : TextInputType.text,
                label: restaurantOrRoomOrder == 0
                    ? I18n.of(context).ntable
                    : I18n.of(context).addr,
                icon: restaurantOrRoomOrder == 0
                    ? Icon(
                        Icons.restaurant_menu,
                        color: Color(Styling.accentColor),
                      )
                    : Icon(
                        Icons.shopping_cart,
                        color: Color(Styling.accentColor),
                      ),
              ),
              if (restaurantOrRoomOrder == 1)
                ZTextField(
                  onSaved: (newValue) => phone = newValue,
                  validator: (value) =>
                      value.isEmpty ? I18n.of(context).requit : null,
                  keyboardType: TextInputType.phone,
                  label: I18n.of(context).fone,
                  icon: Icon(
                    Icons.phone_android,
                    color: Color(
                      Styling.accentColor,
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: ZTextField(
                  onSaved: (newValue) => instruction = newValue,
                  label: I18n.of(context).instruction,
                  icon: Icon(
                    Icons.info,
                    color: Color(Styling.accentColor),
                  ),
                  keyboardType: TextInputType.text,
                ),
              ),
            ],
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
                      Text(priceItemsTotal(context, widget.clientOrder)),
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
                      Text(appliedTax(context, widget.clientOrder, tax)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        I18n.of(context).gtotal,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      Text(grandTotal(context, widget.clientOrder, tax)),
                    ],
                  ),
                ),
              ],
            ),
            ZRaisedButton(
              onpressed: sendToFireBase,
              color: Color(Styling.accentColor),
              textIcon: Text(
                I18n.of(context).ordPlace,
                style: TextStyle(
                  color: Color(Styling.primaryBackgroundColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool validate() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<void> sendToFireBase() async {
    if (validate()) {
      Order order = Order(
        clientOrder: widget.clientOrder,
        orderLocation: restaurantOrRoomOrder,
        tableAdress: tableAdress,
        phoneNumber: phone,
        instructions: instruction,
        grandTotal: grandTotalNumber(context, widget.clientOrder, tax),
        orderDate: DateTime.now().millisecondsSinceEpoch,
        confirmedDate: 0,
        servedDate: 0,
        status: 0,
        userId: widget.userId,
        userRole: widget.userRole,
        taxPercentage: tax,
        total: priceItemsTotalNumber(
          context,
          widget.clientOrder,
        ),
      );
      await widget.db.placeOrder(order);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SingleOrderPage(),
        ),
      );
    }
  }
}
