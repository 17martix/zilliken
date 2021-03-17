import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:zilliken/Components/ZAppBar.dart';
import 'package:zilliken/Components/ZCircularProgress.dart';
import 'package:zilliken/Components/ZRaisedButton.dart';
import 'package:zilliken/Components/ZTextField.dart';
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
import 'package:zilliken/Services/Messaging.dart';
import '../i18n.dart';
import 'DashboardPage.dart';
import 'DisabledPage.dart';

class CartPage extends StatefulWidget {
  final List<OrderItem> clientOrder;
  final String userId;
  final String userRole;
  final Database db;
  final Authentication auth;
  final Messaging messaging;

  CartPage({
    @required this.auth,
    @required this.clientOrder,
    @required this.db,
    @required this.userId,
    @required this.userRole,
    @required this.messaging,
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

  void backFunction() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => DashboardPage(
          db: widget.db,
          auth: widget.auth,
          userId: widget.userId,
          userRole: widget.userRole,
          clientOrder: clientOrder,
          messaging: widget.messaging,
        ),
      ),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return WillPopScope(
      onWillPop: () {
        return Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardPage(
              db: widget.db,
              auth: widget.auth,
              userId: widget.userId,
              userRole: widget.userRole,
              clientOrder: clientOrder,
              messaging: widget.messaging,
            ),
          ),
          (Route<dynamic> route) => false,
        );
      },
      child: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage('assets/Zilliken.jpg'),
          fit: BoxFit.cover,
        )),
        child: Container(
          color: Color(Styling.primaryBackgroundColor).withOpacity(0.7),
          child: enabled == 0
              ? DisabledPage(
                  auth: widget.auth,
                  db: widget.db,
                  userId: widget.userId,
                  userRole: widget.userRole,
                )
              : Scaffold(
                  backgroundColor: Colors.transparent,
                  key: _scaffoldKey,
                  appBar: buildAppBar(context, widget.auth, true, false, null,
                      null, backFunction),
                  body: Stack(
                    children: [
                      body(),
                      ZCircularProgress(_isLoading),
                    ],
                  ),
                ),
        ),
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
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeConfig.diagonal * 1.5)),
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
          margin: EdgeInsets.symmetric(
              horizontal: SizeConfig.diagonal * 2,
              vertical: SizeConfig.diagonal * 1),
          width: double.infinity,
          height: 1,
          color: Color(Styling.primaryColor),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: clientOrder.map((orderItem) {
            return item(orderItem.menuItem);
          }).toList(),
        ),

        /* ListView.builder(
          shrinkWrap: true,
          itemCount: clientOrder.length,
          itemBuilder: (context, position) {
            return item(clientOrder[position].menuItem);
          },
        ),*/
      ],
    );
  }

  Widget item(MenuItem menu) {
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeConfig.diagonal * 1.5)),
      elevation: 2,
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              // color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(SizeConfig.diagonal * 1.5),
              image: DecorationImage(
                image: AssetImage("assets/${menu.imageName}"),
                fit: BoxFit.cover,
              ),
            ),
            height: SizeConfig.diagonal * 10,
            width: SizeConfig.diagonal * 10,
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(SizeConfig.diagonal * 1),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menu.name,
                    textAlign: TextAlign.left,
                    //overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(Styling.textColor),
                      fontWeight: FontWeight.bold,
                      fontSize: SizeConfig.diagonal * 1.5,
                    ),
                  ),
                  SizedBox(width: SizeConfig.diagonal * 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          "${formatNumber(menu.price)} ${I18n.of(context).fbu}",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Color(Styling.textColor),
                            fontWeight: FontWeight.normal,
                            fontSize: SizeConfig.diagonal * 1.5,
                          ),
                        ),
                      ),
                      isAlreadyOnTheOrder(clientOrder, menu.id)
                          ? Expanded(
                              flex: 1,
                              child: NumericStepButton(
                                counter:
                                    findOrderItem(clientOrder, menu.id).count,
                                maxValue: 20,
                                onChanged: (value) {
                                  OrderItem orderItem =
                                      findOrderItem(clientOrder, menu.id);
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
                              ),
                            )
                          : Expanded(
                              flex: 1,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  InkWell(
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
                                        color: Color(Styling.accentColor),
                                        borderRadius: BorderRadius.circular(
                                            SizeConfig.diagonal * 3),
                                        border: Border.all(
                                          color: Color(Styling.accentColor),
                                        ),
                                      ),
                                      margin: EdgeInsets.all(
                                          SizeConfig.diagonal * 1),
                                      padding: EdgeInsets.all(
                                          SizeConfig.diagonal * 1),
                                      child: Row(
                                        children: [
                                          Text(
                                            I18n.of(context).addItem,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize:
                                                    SizeConfig.diagonal * 1.5),
                                          ),
                                          SizedBox(
                                              width: SizeConfig.diagonal * 0.5),
                                          Icon(
                                            Icons.add,
                                            size: SizeConfig.diagonal * 1.5,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
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
          margin: EdgeInsets.all(SizeConfig.diagonal * 1),
          width: double.infinity,
          height: 1,
          color: Color(Styling.primaryColor),
        ),
      ],
    );
  }

  void restaurantRoomChange(int value) {
    setState(() {
      restaurantOrRoomOrder = value;
      choiceController.clear();
      formKey.currentState.reset();
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
                        color: Color(Styling.primaryColor),
                      )
                    : Icon(
                        Icons.shopping_cart,
                        color: Color(Styling.primaryColor),
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
                      Styling.primaryColor,
                    ),
                  ),
                ),
              ZTextField(
                onSaved: (newValue) => instruction = newValue,
                label: I18n.of(context).instruction,
                icon: Icon(
                  Icons.info,
                  color: Color(Styling.primaryColor),
                ),
                keyboardType: TextInputType.text,
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
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SizeConfig.diagonal * 1.5)),
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
                    margin: EdgeInsets.all(SizeConfig.diagonal * 1),
                    width: double.infinity,
                    height: 1,
                    color: Color(Styling.primaryColor),
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
                    leftPadding: 0.0,
                    rightPadding: 0.0,
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

      bool isOnline = await DataConnectionChecker().hasConnection;
      if (!isOnline) {
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
            status: 1,
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
                messaging: widget.messaging,
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
