import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zilliken/Components/ZCircularProgress.dart';
import 'package:zilliken/Components/ZRaisedButton.dart';
import 'package:zilliken/Components/ZTextField.dart';
import 'package:zilliken/Helpers/ConnectionStatus.dart';
import 'package:zilliken/Helpers/NumericStepButton.dart';
import 'package:zilliken/Helpers/SizeConfig.dart';
import "package:zilliken/Helpers/Styling.dart";
import 'package:zilliken/Helpers/Utils.dart';
import 'package:zilliken/Models/Category.dart';
import 'package:zilliken/Models/Fields.dart';
import 'package:zilliken/Models/MenuItem.dart';
import 'package:zilliken/Models/OrderItem.dart';

import 'package:zilliken/Services/Authentication.dart';
import 'package:zilliken/Services/Database.dart';

import 'package:zilliken/i18n.dart';

import 'CartPage.dart';

class MenuPage extends StatefulWidget {
  final Authentication auth;
  final Database db;
  final String userId;
  final String userRole;

  MenuPage({
    this.auth,
    this.db,
    this.userId,
    this.userRole,
  });

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  var commandes;
  var categories = FirebaseFirestore.instance
      .collection(Fields.category)
      .orderBy(Fields.rank, descending: false);
  String selectedCategory = Fields.tout;
  List<OrderItem> clientOrder = List<OrderItem>();

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  StreamSubscription _connectionChangeStream;
  bool isOffline = false;
  bool _isLoading;

  int _itemorCategory = 0;
  MenuItem _menuItem = MenuItem();
  Category _cat = Category();

  bool _isCategoryLoaded = false;
  final _formKey = GlobalKey<FormState>();
  final _catformKey = GlobalKey<FormState>();
  List<String> _catList = new List();

  @override
  void initState() {
    super.initState();

    setState(() {
      commandesQuery(selectedCategory);
    });

    ConnectionStatus connectionStatus = ConnectionStatus.getInstance();
    _connectionChangeStream =
        connectionStatus.connectionChange.listen(connectionChanged);
    _isLoading = false;

    widget.db.getCategories().then((value) {
      _catList.addAll(value);
      _menuItem.category = _catList[0];
      _isCategoryLoaded = true;
    });
  }

  void commandesQuery(String category) {
    if (category == Fields.tout) {
      if (widget.userRole == Fields.client) {
        commandes = FirebaseFirestore.instance
            .collection(Fields.menu)
            .where(Fields.availability, isEqualTo: 1)
            .orderBy(Fields.global, descending: false);
      } else {
        commandes = FirebaseFirestore.instance
            .collection(Fields.menu)
            .orderBy(Fields.global, descending: false);
      }
    } else {
      if (widget.userRole == Fields.client) {
        commandes = FirebaseFirestore.instance
            .collection(Fields.menu)
            .where(Fields.availability, isEqualTo: 1)
            .where(Fields.category, isEqualTo: category)
            .orderBy(Fields.global, descending: false);
      } else {
        commandes = FirebaseFirestore.instance
            .collection(Fields.menu)
            .where(Fields.category, isEqualTo: category)
            .orderBy(Fields.global, descending: false);
      }
    }
  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isOffline = !hasConnection;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [
          body(),
          ZCircularProgress(_isLoading),
        ],
      ),
    );
  }

  Widget body() {
    return Column(
      children: [
        if (widget.userRole == Fields.admin ||
            widget.userRole == Fields.developer)
          addItemCategory(),
        categoryList(),
        Expanded(
          child: menulist(),
        ),
        if (clientOrder.length > 0) showBill(),
      ],
    );
  }

  Widget addItemCategory() {
    return Column(
      children: [
        chooseCategoryOrItems(),
      ],
    );
  }

  Widget chooseCategoryOrItems() {
    return Container(
      padding: EdgeInsets.all(SizeConfig.diagonal * 1),
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          new Text(
            I18n.of(context).addWhat,
            style: new TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: SizeConfig.diagonal * 1.5,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.diagonal * 1,
                vertical: SizeConfig.diagonal * 1),
            child: Divider(height: 2.0, color: Colors.black),
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              new Radio(
                value: 0,
                groupValue: _itemorCategory,
                onChanged: _handleValueChange,
              ),
              new Text(
                I18n.of(context).item,
                style: new TextStyle(fontSize: SizeConfig.diagonal * 1.5),
              ),
              new Radio(
                value: 1,
                groupValue: _itemorCategory,
                onChanged: _handleValueChange,
              ),
              new Text(
                I18n.of(context).category,
                style: new TextStyle(
                  fontSize: SizeConfig.diagonal * 1.5,
                ),
              ),
            ],
          ),
          new Divider(height: 2.0, color: Colors.black),
          _itemorCategory == 0
              ? Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.disabled,
                  child: Column(
                    children: [
                      ZTextField(
                        onSaved: (value) => _menuItem.name = value,
                        validator: (value) =>
                            value.isEmpty ? I18n.of(context).requit : null,
                        keyboardType: TextInputType.text,
                        icon: Icon(Icons.restaurant_menu),
                        obsecure: false,
                        hint: I18n.of(context).itemName,
                      ),
                      ZTextField(
                        onSaved: (value) => _menuItem.price = int.parse(value),
                        validator: (value) =>
                            value.isEmpty ? I18n.of(context).requit : null,
                        keyboardType: TextInputType.number,
                        icon: Icon(Icons.monetization_on),
                        obsecure: false,
                        hint: I18n.of(context).itemPrice,
                      ),
                      if (_isCategoryLoaded)
                        DropdownButton<String>(
                          value: _menuItem.category,
                          icon: Icon(Icons.arrow_drop_down),
                          iconSize: 24,
                          elevation: 16,
                          style: TextStyle(
                            color: Color(Styling.accentColor),
                            fontSize: SizeConfig.diagonal * 1.5,
                          ),
                          onChanged: (String newValue) {
                            setState(() {
                              _menuItem.category = newValue;
                            });
                          },
                          items: _catList
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(
                                  fontSize: SizeConfig.diagonal * 1.5,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ZRaisedButton(
                        textIcon: Text(
                          I18n.of(context).addItem,
                          style: TextStyle(
                            fontSize: SizeConfig.diagonal * 1.5,
                            color: Color(Styling.primaryBackgroundColor),
                          ),
                        ),
                        bottomPadding: SizeConfig.diagonal * 1,
                        onpressed: saveItem,
                      ),
                    ],
                  ),
                )
              : Form(
                  key: _catformKey,
                  child: Column(
                    children: [
                      ZTextField(
                        onSaved: (value) => _cat.name = value,
                        validator: (value) =>
                            value.isEmpty ? I18n.of(context).requit : null,
                        keyboardType: TextInputType.text,
                        icon: Icon(Icons.category),
                        obsecure: false,
                        hint: I18n.of(context).categoryName,
                      ),
                      ZRaisedButton(
                        textIcon: Text(
                          I18n.of(context).addItem,
                          style: TextStyle(
                            fontSize: SizeConfig.diagonal * 2,
                            color: Color(Styling.primaryBackgroundColor),
                          ),
                        ),
                        bottomPadding: SizeConfig.diagonal * 1,
                        onpressed: saveCategory,
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget showBill() {
    return Align(
        alignment: Alignment.bottomCenter,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CartPage(
                  clientOrder: clientOrder,
                  db: widget.db,
                  auth: widget.auth,
                  userId: widget.userId,
                  userRole: widget.userRole,
                ),
              ),
            );
          },
          child: Card(
            color: Color(Styling.accentColor),
            elevation: 16,
            child: ListTile(
              title: Text(
                numberItems(context, clientOrder),
                style: TextStyle(color: Color(Styling.primaryBackgroundColor)),
              ),
              subtitle: Text(
                priceItems(context, clientOrder),
                style: TextStyle(
                  color: Color(Styling.primaryBackgroundColor),
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: Text(
                I18n.of(context).vOrder,
                style: TextStyle(
                  color: Color(Styling.primaryBackgroundColor),
                ),
              ),
            ),
          ),
        ));
  }

  bool validateAndSaveCategory() {
    final form = _catformKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void saveCategory() async {
    if (validateAndSaveCategory()) {
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
          await widget.db.addCategoy(_cat);

          _catList.clear();
          widget.db.getCategories().then((value) {
            setState(() {
              _catList.addAll(value);
              _menuItem.category = _catList[0];
              _isCategoryLoaded = true;
            });
          });

          setState(() {
            _isLoading = false;
          });

          setState(() {
            _catformKey.currentState.reset();
          });
        } on Exception catch (e) {
          //print('Error: $e');
          setState(() {
            _isLoading = false;
            _catformKey.currentState.reset();
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

  bool validateAndSaveItem() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void saveItem() async {
    if (validateAndSaveItem()) {
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
          await widget.db.addItem(_menuItem);

          setState(() {
            _isLoading = false;
          });

          setState(() {
            _formKey.currentState.reset();
          });
        } on Exception catch (e) {
          //print('Error: $e');
          setState(() {
            _isLoading = false;
            _formKey.currentState.reset();
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

  void _handleValueChange(int value) {
    setState(() {
      _itemorCategory = value;
    });
  }

  Widget categoryList() {
    return StreamBuilder<QuerySnapshot>(
      stream: categories.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.data == null)
          return Center(
            child: Text(""),
          );

        return SingleChildScrollView(
          child: Row(
            children: snapshot.data.docs.map((DocumentSnapshot document) {
              Category category = Category();
              category.buildObject(document);
              return categoryItem(category);
            }).toList(),
          ),
        );
      },
    );
  }

  Widget menulist() {
    return StreamBuilder<QuerySnapshot>(
      stream: commandes.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.data == null)
          return Center(
            child: Text(""),
          );

        return ListView(
          shrinkWrap: true,
          children: snapshot.data.docs.map((DocumentSnapshot document) {
            MenuItem menu = MenuItem();
            menu.buildObject(document);
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (menu.rank == 1) categoryRow(menu),
                item(menu),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  Widget categoryRow(MenuItem menu) {
    return Container(
      margin: EdgeInsets.only(top: SizeConfig.diagonal * 2),
      child: Column(
        children: [
          Text(
            menu.category,
            style: TextStyle(
              color: Color(Styling.textColor),
              fontWeight: FontWeight.bold,
              fontSize: SizeConfig.diagonal * 1.5,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.diagonal * 2,
                vertical: SizeConfig.diagonal * 0.5),
            child: Divider(height: 2.0, color: Color(Styling.accentColor)),
          ),
        ],
      ),
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
            widget.userRole == Fields.chef ||
                    widget.userRole == Fields.admin ||
                    widget.userRole == Fields.developer
                ? Container(
                    width: SizeConfig.diagonal * 20,
                    child: SwitchListTile(
                      activeColor: Color(Styling.accentColor),
                      value: menu.availability == 1 ? true : false,
                      onChanged: (isEnabled) =>
                          itemAvailability(isEnabled, menu),
                    ),
                  )
                : isAlreadyOnTheOrder(clientOrder, menu.id)
                    ? Container(
                        width: SizeConfig.diagonal * 20,
                        child: NumericStepButton(
                          counter: findOrderItem(clientOrder, menu.id).count,
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
                                style: TextStyle(
                                    fontSize: SizeConfig.diagonal * 1.5),
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

  Widget categoryItem(Category category) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedCategory = category.name;
          commandesQuery(category.name);
        });
      },
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.diagonal * 1.5),
        child: Column(
          children: [
            Text(
              category.name,
              style: TextStyle(
                  color: selectedCategory == category.name
                      ? Color(Styling.textColor)
                      : Color(Styling.textColor).withOpacity(0.3),
                  fontWeight: selectedCategory == category.name
                      ? FontWeight.bold
                      : FontWeight.normal),
            ),
            if (selectedCategory == category.name)
              Container(
                height: 2,
                width: SizeConfig.diagonal * 2,
                color: Color(Styling.accentColor),
              ),
          ],
        ),
      ),
    );
  }

  void itemAvailability(bool isEnabled, MenuItem menuItem) async {
    int value;
    if (isEnabled)
      value = 1;
    else
      value = 0;

    try {
      await widget.db.updateAvailability(menuItem.id, value);
    } on Exception catch (e) {
      print('Error: $e');
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }
}
