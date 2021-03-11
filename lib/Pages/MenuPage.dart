import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:zilliken/Components/ZCircularProgress.dart';
import 'package:zilliken/Components/ZRaisedButton.dart';
import 'package:zilliken/Components/ZTextField.dart';
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
  final List<OrderItem> clientOrder;

  MenuPage({
    this.auth,
    this.db,
    this.userId,
    this.userRole,
    this.clientOrder,
  });

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  var commandes;
  var categories = FirebaseFirestore.instance
      .collection(Fields.category)
      .orderBy(Fields.rank, descending: false);
  String selectedCategory = Fields.boissonsChaudes;
  List<OrderItem> clientOrder = List<OrderItem>();

  final _scaffoldKey = GlobalKey<ScaffoldState>();
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
      if (widget.clientOrder != null && widget.clientOrder.length > 0)
        setState(() {
          clientOrder = widget.clientOrder;
        });
    });

    _isLoading = false;

    widget.db.getCategories().then((value) {
      _catList.addAll(value);
      _menuItem.category = _catList[0];
      _isCategoryLoaded = true;
    });

    //if (clientOrder.length > 0)
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

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    //_yOffset = SizeConfig.diagonal * 100;
    return Scaffold(
      backgroundColor: Colors.transparent,
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
          if (widget.userRole == Fields.developer)
            ZRaisedButton(
              textIcon: Text(
                I18n.of(context).loadData,
                style: TextStyle(
                  fontSize: SizeConfig.diagonal * 1.5,
                  color: Color(Styling.primaryBackgroundColor),
                ),
              ),
              bottomPadding: SizeConfig.diagonal * 1,
              onpressed: loadData,
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
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SizeConfig.diagonal * 1.5)),
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

  void loadData() async {
    setState(() {
      _isLoading = true;
    });

bool isOnline= await DataConnectionChecker().hasConnection;
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
        await widget.db.loadData();

        setState(() {
          _isLoading = false;
        });
      } on Exception catch (e) {
        //print('Error: $e');
        setState(() {
          _isLoading = false;
        });

        _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }
    }
  }

  void saveCategory() async {
    if (validateAndSaveCategory()) {
      setState(() {
        _isLoading = true;
      });

bool isOnline= await DataConnectionChecker().hasConnection;
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

bool isOnline= await DataConnectionChecker().hasConnection;
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

        return Container(
          margin: EdgeInsets.symmetric(horizontal: SizeConfig.diagonal * 1),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: snapshot.data.docs.map((DocumentSnapshot document) {
                Category category = Category();
                category.buildObject(document);
                return categoryItem(category);
              }).toList(),
            ),
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

        return ListView.builder(
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context, index) {
            MenuItem menu = MenuItem();
            menu.buildObject(snapshot.data.docs[index]);
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //if (menu.rank == 1) categoryRow(menu),
                item(menu),
              ],
            );
          },
        );

        /* return ListView(
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
        );*/
      },
    );
  }

  Widget categoryRow(MenuItem menu) {
    return Container(
      margin: EdgeInsets.only(top: SizeConfig.diagonal * 3),
      child: Column(
        children: [
          Text(
            menu.category,
            style: TextStyle(
              color: Color(Styling.primaryColor),
              fontWeight: FontWeight.bold,
              fontSize: SizeConfig.diagonal * 1.8,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.diagonal * 2,
                vertical: SizeConfig.diagonal * 0.5),
            child: Divider(height: 2.0, color: Color(Styling.primaryColor)),
          ),
        ],
      ),
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
                          "${menu.price} ${I18n.of(context).fbu}",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Color(Styling.textColor),
                            fontWeight: FontWeight.normal,
                            fontSize: SizeConfig.diagonal * 1.5,
                          ),
                        ),
                      ),
                      widget.userRole == Fields.chef ||
                              widget.userRole == Fields.admin ||
                              widget.userRole == Fields.developer
                          ? Expanded(
                              flex: 1,
                              child: SwitchListTile(
                                activeColor: Color(Styling.accentColor),
                                value: menu.availability == 1 ? true : false,
                                onChanged: (isEnabled) =>
                                    itemAvailability(isEnabled, menu),
                              ),
                            )
                          : isAlreadyOnTheOrder(clientOrder, menu.id)
                              ? Expanded(
                                  flex: 1,
                                  child: NumericStepButton(
                                    counter: findOrderItem(clientOrder, menu.id)
                                        .count,
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
                                                        SizeConfig.diagonal *
                                                            1.5),
                                              ),
                                              SizedBox(
                                                  width: SizeConfig.diagonal *
                                                      0.5),
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

  Widget categoryItem(Category category) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedCategory = category.name;
          commandesQuery(category.name);
        });
      },
      child: Container(
        width: SizeConfig.diagonal * 25,
        height: SizeConfig.diagonal * 15,
        margin: EdgeInsets.all(SizeConfig.diagonal * 0.5),
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/${category.imageName}'),
              colorFilter: selectedCategory != category.name
                  ? ColorFilter.mode(Colors.white, BlendMode.saturation)
                  : null,
              fit: BoxFit.cover),
          color: selectedCategory == category.name
              ? Color(Styling.accentColor)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(SizeConfig.diagonal * 3),
        ),
        child: Container(
          padding: EdgeInsets.all(SizeConfig.diagonal * 0.5),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(SizeConfig.diagonal * 3),
          ),
          child: Center(
            child: Text(
              category.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: SizeConfig.diagonal * 2,
                  color: Colors.white,
                  fontWeight: selectedCategory == category.name
                      ? FontWeight.bold
                      : FontWeight.normal),
            ),
          ),
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
