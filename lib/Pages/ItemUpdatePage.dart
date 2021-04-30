import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:zilliken/Components/ZAppBar.dart';
import 'package:zilliken/Components/ZElevatedButton.dart';
import 'package:zilliken/Components/ZTextField.dart';
import 'package:zilliken/Helpers/SizeConfig.dart';
import 'package:zilliken/Helpers/Styling.dart';
import 'package:zilliken/Helpers/Utils.dart';
import 'package:zilliken/Models/Fields.dart';
import 'package:zilliken/Models/MenuItem.dart';
import 'package:zilliken/Models/Stock.dart';
import 'package:zilliken/Services/Authentication.dart';
import 'package:zilliken/Services/Database.dart';
import 'package:zilliken/Services/Messaging.dart';
import 'package:intl/intl.dart';
import 'package:zilliken/i18n.dart';

class ItemUpdatePage extends StatefulWidget {
  final Authentication auth;
  final Database db;
  final Messaging messaging;
  final String userId;
  final String userRole;
  final DateFormat formatter = DateFormat();
  final Stock stock;

  ItemUpdatePage({
  required  this.auth,
   required this.db,
   required this.messaging,
   required this.userId,
  required  this.userRole,
   required this.stock,
  });
  @override
  _ItemEditPageState createState() => _ItemEditPageState();
}

class _ItemEditPageState extends State<ItemUpdatePage> {
  // @override
  // void initState() {
  //   super.initState();
  //   //widget.db.getMenuItemName(id).then((value) {});
  // }

  void backFunction() {
    Navigator.of(context).pop();
  }

  var _formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      key: _scaffoldKey,
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
             /* ZTextField(
                outsidePrefix: Text(I18n.of(context).quantity + ' :'),
                onSaved: (value) => widget.stock.quantity = num.parse(value),
                validator: (value) =>
                  ( value==null || value.isEmpty) ? I18n.of(context).requit : null,
              ),*/
              SizedBox(
                height: SizeConfig.diagonal * 3,
              ),
              // ZTextField(
              //   outsidePrefix: Text(I18n.of(context).unit + ' :'),
              //   //onSaved: (value) => newStockValue.quantity = num.parse(value),
              //   validator: (value) =>
              //       value.isEmpty ? I18n.of(context).requit : null,
              // ),
              // SizedBox(
              //   height: SizeConfig.diagonal * 3,
              // ),

              ZElevatedButton(
                onpressed: itemUpdate,
                child: Text(
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

  void itemUpdate() async {
    final form = _formKey.currentState;

    if (form!.validate()) {
      form.save();
      EasyLoading.show(status: I18n.of(context).loading);

      bool isOnline = await hasConnection();
      if (!isOnline) {
        EasyLoading.dismiss();

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(I18n.of(context).noInternet),
          ),
        );
      } else {
        try {
          await widget.db.updateInventoryItem(context, widget.stock);

          EasyLoading.dismiss();

          setState(() {
            _formKey.currentState!.reset();
          });
        } on Exception catch (e) {
          EasyLoading.dismiss();
          setState(() {
            _formKey.currentState!.reset();
          });

         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
            ),
          );
        }
      }
    }
  }
}
