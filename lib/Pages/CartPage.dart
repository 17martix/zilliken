import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zilliken/Components/ZAppBar.dart';
import 'package:zilliken/Components/ZCircularProgress.dart';
import 'package:zilliken/Components/ZRaisedButton.dart';
import 'package:zilliken/Components/ZTextField.dart';
import 'package:zilliken/Helpers/ConnectionStatus.dart';
import 'package:zilliken/Helpers/NumericStepButton.dart';
import 'package:zilliken/Helpers/SizeConfig.dart';
import 'package:zilliken/Helpers/Styling.dart';
import 'package:zilliken/Helpers/Utils.dart';
import 'package:zilliken/Models/Fields.dart';
import 'package:zilliken/Models/MenuItem.dart';
import 'package:zilliken/Models/Order.dart';
import 'package:zilliken/Models/OrderItem.dart';
import 'package:zilliken/Pages/SingleOrderPage.dart';
import 'package:zilliken/Services/Authentication.dart';
import 'package:zilliken/Services/Database.dart';
import '../i18n.dart';
import 'DisabledPage.dart';

class CartPage extends StatefulWidget {
  final List<OrderItem> clientOrder;
  final String userId;
  final String userRole;
  final Database db;
  final Authentication auth;

  CartPage({
    this.auth,
    this.clientOrder,
    this.db,
    this.userId,
    this.userRole,
  });

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int restaurantOrRoomOrder = 0;
  TextEditingController choiceController = TextEditingController();
  int tax = 0;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String tableAdress;
  String phone;
  String instruction;
  List<OrderItem> clientOrder;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  StreamSubscription _connectionChangeStream;
  bool isOffline = false;
  bool _isLoading = false;
  bool _isTaxLoaded = false;
  int enabled = 1;

  @override
  void initState() {
    super.initState();
    clientOrder = widget.clientOrder;
    widget.db.getTax().then((value) {
      setState(() {
        tax = value;
        _isTaxLoaded = true;
      });
    });

     FirebaseFirestore.instance
        .collection(Fields.configuration)
        .doc(Fields.settings)
        .snapshots()
        .listen((DocumentSnapshot documentSnapshot) {
      setState(() {
        enabled = documentSnapshot.data()[Fields.enabled];
      });
    });

    ConnectionStatus connectionStatus = ConnectionStatus.getInstance();
    _connectionChangeStream =
        connectionStatus.connectionChange.listen(connectionChanged);

    FirebaseFirestore.instance
        .collection(Fields.configuration)
        .doc(Fields.settings)
        .snapshots()
        .listen((DocumentSnapshot documentSnapshot) {
      setState(() {
        enabled = documentSnapshot.data()[Fields.enabled];
      });
    });
  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isOffline = !hasConnection;
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return enabled == 0
        ? DisabledPage(
            auth: widget.auth,
            db: widget.db,
            userId: widget.userId,
            userRole: widget.userRole,
          )
        : Scaffold(
            key: _scaffoldKey,
            appBar: buildAppBar(context, widget.auth, true, false, null, null),
            body: Stack(
              children: [
                body(),
                ZCircularProgress(_isLoading),
              ],
            ),
          );
  }

  Widget body() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          orderItems(),
          order(),
          bill(),
        ],
      ),
    );
  }

  Widget order() {
    return Card(
      elevation: 16,
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.diagonal * 1),
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
          padding: EdgeInsets.all(SizeConfig.diagonal * 1),
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
          itemCount: clientOrder.length,
          itemBuilder: (context, position) {
            return item(clientOrder[0].menuItem);
          },
        ),
      ],
    );
  }

  Widget item(MenuItem menu) {
    return Card(
      elevation: 25,
      color: Colors.white70,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.diagonal * 1.8,
          vertical: SizeConfig.diagonal * 1.8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.only(left: SizeConfig.diagonal * 1),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menu.name,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Color(Styling.textColor),
                      fontWeight: FontWeight.bold,
                      fontSize: SizeConfig.diagonal * 1.5,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: SizeConfig.diagonal * 1),
                    child: Text(
                      "${menu.price} ${I18n.of(context).fbu}",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Color(Styling.textColor),
                        fontWeight: FontWeight.normal,
                        fontSize: SizeConfig.diagonal * 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            isAlreadyOnTheOrder(clientOrder, menu.id)
                ? NumericStepButton(
                    counter: findOrderItem(clientOrder, menu.id).count,
                    maxValue: 20,
                    onChanged: (value) {
                      OrderItem orderItem = findOrderItem(clientOrder, menu.id);
                      if (value == 0) {
                        setState(() {
                          clientOrder.remove(orderItem);
                        });
                        //order.remove(orderItem);
                      } else {
                        setState(() {
                          orderItem.count = value;
                        });
                        //orderItem.count = value;
                      }
                    },
                  )
                : InkWell(
                    onTap: () {
                      setState(() {
                        clientOrder.add(OrderItem(
                          menuItem: menu,
                          count: 1,
                        ));
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color(Styling.accentColor),
                        ),
                      ),
                      margin: EdgeInsets.all(8),
                      padding: EdgeInsets.all(8),
                      child: Row(
                        children: [
                          Text(
                            I18n.of(context).addItem,
                            style:
                                TextStyle(fontSize: SizeConfig.diagonal * 1.5),
                          ),
                          Icon(
                            Icons.add,
                            size: SizeConfig.diagonal * 1.5,
                          ),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget showOrder() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.all(SizeConfig.diagonal * 1),
          child: Text(
            I18n.of(context).orderKind,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Color(Styling.iconColor),
                fontSize: SizeConfig.diagonal * 1.5),
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
                padding: EdgeInsets.all(SizeConfig.diagonal * 1),
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
    return _isTaxLoaded
        ? Card(
            elevation: 16,
            child: Padding(
              padding: EdgeInsets.all(SizeConfig.diagonal * 1),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.all(SizeConfig.diagonal * 1),
                    child: Text(
                      I18n.of(context).bil,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: SizeConfig.diagonal * 1.5,
                        color: Color(Styling.textColor),
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
                        padding: EdgeInsets.all(SizeConfig.diagonal * 1),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              I18n.of(context).total,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: SizeConfig.diagonal * 1.5,
                                color:
                                    Color(Styling.textColor).withOpacity(0.7),
                              ),
                            ),
                            Text(priceItemsTotal(context, clientOrder)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(SizeConfig.diagonal * 1),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              I18n.of(context).taxCharge,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color:
                                    Color(Styling.accentColor).withOpacity(0.7),
                                fontSize: SizeConfig.diagonal * 1.5,
                              ),
                            ),
                            Text(appliedTax(context, clientOrder, tax)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(SizeConfig.diagonal * 1),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              I18n.of(context).gtotal,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(Styling.accentColor),
                                fontSize: SizeConfig.diagonal * 1.5,
                              ),
                            ),
                            Text(grandTotal(context, clientOrder, tax)),
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
                        fontSize: SizeConfig.diagonal * 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        : ZCircularProgress(true);
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
      setState(() {
        _isLoading = true;
      });

      if (isOffline) {
        setState(() {
          _isLoading = false;
        });

        _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: Text(I18n.of(context).noInternet),
          ),
        );
      } else {
        try {
          Order order = Order(
            clientOrder: clientOrder,
            orderLocation: restaurantOrRoomOrder,
            tableAdress: tableAdress,
            phoneNumber: phone,
            instructions: instruction,
            grandTotal: grandTotalNumber(context, clientOrder, tax),
            orderDate: DateTime.now().millisecondsSinceEpoch,
            confirmedDate: 0,
            servedDate: 0,
            status: 0,
            userId: widget.userId,
            userRole: widget.userRole,
            taxPercentage: tax,
            total: priceItemsTotalNumber(
              context,
              clientOrder,
            ),
          );
          await widget.db.placeOrder(order);

          setState(() {
            _isLoading = false;
          });

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
        } on Exception catch (e) {
          //print('Error: $e');
          setState(() {
            _isLoading = false;
            formKey.currentState.reset();
          });

          _scaffoldKey.currentState.showSnackBar(
            SnackBar(
              content: Text(e.toString()),
            ),
          );
        }
      }
    }
  }
}
