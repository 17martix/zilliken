import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zilliken/Components/ZAppBar.dart';
import 'package:zilliken/Components/ZRaisedButton.dart';
import 'package:zilliken/Components/ZTextField.dart';
import 'package:zilliken/Helpers/SizeConfig.dart';
import 'package:zilliken/Helpers/Styling.dart';
import 'package:zilliken/Models/Fields.dart';
import 'package:zilliken/Models/MenuItem.dart';
import 'package:zilliken/Models/Stock.dart';
import 'package:zilliken/Services/Authentication.dart';
import 'package:zilliken/Services/Database.dart';
import 'package:zilliken/Services/Messaging.dart';
import 'package:intl/intl.dart';
import 'package:zilliken/i18n.dart';

class ItemEditPage extends StatefulWidget {
  final Authentication auth;
  final Database db;
  final Messaging messaging;
  final String userId;
  final String userRole;
  final DateFormat formatter = DateFormat();
  MenuItem newItem = MenuItem();

  ItemEditPage({
    this.auth,
    this.db,
    this.messaging,
    this.userId,
    this.userRole,
  });
  @override
  _ItemEditPageState createState() => _ItemEditPageState();
}

class _ItemEditPageState extends State<ItemEditPage> {
  @override
  void initState() {
    super.initState();
    //widget.db.getMenuItemName(id).then((value) {});
  }

  void backFunction() {
    Navigator.of(context).pop();
  }

  var _formKey = GlobalKey<FormState>();
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  Stock stock = Stock();
  MenuItem menuItem = MenuItem();
  List<String> unitList = [
    'Kilogram(s)',
    'Liter(s)',
    'Box(es)',
    'Bottle(s)',
    'Item(s)',
    'gram(s)'
  ];

  String selectedValue;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: buildAppBar(
          context, widget.auth, true, null, backFunction, null, null),
      body: body(),
    );
  }

  Widget body() {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: SizeConfig.diagonal * 0.9),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                height: SizeConfig.diagonal * 15,
                child: Center(
                  child: Text(I18n.of(context).itemEditing),
                ),
              ),
              ZTextField(
                outsidePrefix: Text(I18n.of(context).quantity + ' :'),
                //onSaved: (value) => newStockValue.name = value,
                validator: (value) =>
                    value.isEmpty ? I18n.of(context).requit : null,
              ),
              SizedBox(
                height: SizeConfig.diagonal * 3,
              ),
              ZTextField(
                outsidePrefix: Text(I18n.of(context).unit + ' :'),
                //onSaved: (value) => newStockValue.quantity = num.parse(value),
                validator: (value) =>
                    value.isEmpty ? I18n.of(context).requit : null,
              ),
              SizedBox(
                height: SizeConfig.diagonal * 3,
              ),
              DropdownButton(
                  hint: Text('Select the Unit'),
                  value: selectedValue,
                  items: unitList.map((String value) {
                    return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                        ));
                  }).toList(),
                  onChanged: (String val) {
                    setState(() {
                      selectedValue = val;
                    });
                  }),
              SizedBox(
                height: SizeConfig.diagonal * 2,
              ),
              Container(
                height: SizeConfig.diagonal * 5,
                child: Center(
                  child: Text('Choose any meal that requires this item'),
                ),
              ),
              SizedBox(
                height: SizeConfig.diagonal * 2,
              ),
              ZRaisedButton(
                onpressed: () {},
                textIcon: Text(
                  I18n.of(context).save,
                  style: TextStyle(color: Color(Styling.textColor)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
