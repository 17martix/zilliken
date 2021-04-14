import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:zilliken/Components/ZAppBar.dart';
import 'package:zilliken/Components/ZRaisedButton.dart';
import 'package:zilliken/Components/ZTextField.dart';
import 'package:zilliken/Helpers/SizeConfig.dart';
import 'package:zilliken/Helpers/Styling.dart';
import 'package:zilliken/Helpers/Utils.dart';
import 'package:zilliken/Models/Category.dart';
import 'package:zilliken/Models/Stock.dart';
import 'package:zilliken/Services/Authentication.dart';
import 'package:zilliken/Services/Database.dart';
import 'package:zilliken/Services/Messaging.dart';
import 'package:zilliken/i18n.dart';

class NewItemPage extends StatefulWidget {
  final Authentication auth;
  final Database db;
  final Messaging messaging;
  final String userId;
  final String userRole;

  NewItemPage({
    this.auth,
    this.db,
    this.messaging,
    this.userId,
    this.userRole,
  });
  @override
  _NewItemPageState createState() => _NewItemPageState();
}

class _NewItemPageState extends State<NewItemPage> {
  void backFunction() {
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  NewItemPage newItemPage = NewItemPage();
  Stock newStockValue = Stock();

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
                  child: Text(I18n.of(context).itemDescription),
                ),
              ),
              ZTextField(
                outsidePrefix: Text(I18n.of(context).name + ' :'),
                onSaved: (value) => newStockValue.name = value,
                validator: (value) =>
                    value.isEmpty ? I18n.of(context).requit : null,
              ),
              SizedBox(
                height: SizeConfig.diagonal * 3,
              ),
              ZTextField(
                outsidePrefix: Text(I18n.of(context).quantity + ' :'),
                onSaved: (value) => newStockValue.quantity = num.parse(value),
                validator: (value) =>
                    value.isEmpty ? I18n.of(context).requit : null,
              ),
              SizedBox(
                height: SizeConfig.diagonal * 3,
              ),
              ZTextField(
                outsidePrefix: Text(I18n.of(context).unit + ' :'),
                onSaved: (value) => newStockValue.unit = value,
                validator: (value) =>
                    value.isEmpty ? I18n.of(context).requit : null,
              ),
              SizedBox(
                height: SizeConfig.diagonal * 2,
              ),
              ZRaisedButton(
                onpressed: saveItem,
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

  void saveItem() async {
    final form = _formKey.currentState;

    if (form.validate()) {
      form.save();
      EasyLoading.show(status: I18n.of(context).loading);

      bool isOnline = await hasConnection();
      if (!isOnline) {
        EasyLoading.dismiss();

        _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: Text(I18n.of(context).noInternet),
          ),
        );
      } else {
        try {
          setState(() {
            newStockValue.usedSince = 0;
            newStockValue.usedTotal = 0;
          });
          await widget.db.addInventoryItem(context, newStockValue);

          EasyLoading.dismiss();

          setState(() {
            _formKey.currentState.reset();
          });
        } on Exception catch (e) {
          //print('Error: $e');

          EasyLoading.dismiss();
          setState(() {
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
}
