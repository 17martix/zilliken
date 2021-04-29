import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:zilliken/Components/ZAppBar.dart';
import 'package:zilliken/Components/ZRaisedButton.dart';
import 'package:zilliken/Components/ZTextField.dart';
import 'package:zilliken/Helpers/SizeConfig.dart';
import 'package:zilliken/Helpers/Styling.dart';
import 'package:zilliken/Helpers/Utils.dart';
import 'package:zilliken/Models/Fields.dart';
import 'package:zilliken/Models/Condiments.dart';
import 'package:zilliken/Models/MenuItem.dart';
import 'package:zilliken/Models/Stock.dart';
import 'package:zilliken/Services/Authentication.dart';
import 'package:zilliken/Services/Database.dart';
import 'package:zilliken/Services/Messaging.dart';
import 'package:zilliken/i18n.dart';

class LinkToMenu extends StatefulWidget {
  final Authentication auth;
  final Database db;
  final Messaging messaging;
  final String userId;
  final String userRole;
  final Stock stock;

  LinkToMenu({
    this.auth,
    this.db,
    this.messaging,
    this.userId,
    this.userRole,
    this.stock,
  });
  @override
  _ConnectToMenuState createState() => _ConnectToMenuState();
}

class _ConnectToMenuState extends State<LinkToMenu> {
  List<MenuItem> itemList = [];
  List<String> itemsToSend = [];

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  num quantity;
  // String name;
  // String id;

  @override
  void initState() {
    super.initState();

    waitForItems();
  }

  void waitForItems() {
    widget.db.getMenuItems(widget.stock.id).then((value) {
      setState(() {
        itemList = value;
      });
      log("new length is ${itemList.length}");
    });
  }

  void backFunction() {
    Navigator.of(context).pop();
  }

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
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: SizeConfig.diagonal * 0.9),
          child: ZTextField(
            outsidePrefix: Padding(
              padding: EdgeInsets.only(left: SizeConfig.diagonal * 1),
              child: Icon(Icons.search),
            ),
          ),
        ),
        Container(
          height: SizeConfig.diagonal * 5,
          child: Center(
            child: Text('Choose any meal that requires this item'),
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: itemsList(),
              ),
              ZRaisedButton(
                onpressed: () async {
                  EasyLoading.show(status: I18n.of(context).loading);
                  bool isOnline = await hasConnection();
                  if (!isOnline) {
                    EasyLoading.dismiss();

                    _scaffoldKey.currentState.showSnackBar(SnackBar(
                      content: Text(I18n.of(context).noInternet),
                    ));
                  } else {
                    try {
                      await widget.db.linkToStock(itemsToSend, widget.stock);

                      EasyLoading.dismiss();

                      _scaffoldKey.currentState.showSnackBar(SnackBar(
                        content: Text(I18n.of(context).messageSent),
                      ));
                    } on Exception catch (e) {
                      EasyLoading.dismiss();

                      _scaffoldKey.currentState.showSnackBar(SnackBar(
                        content: Text(e.toString()),
                      ));
                    }
                  }
                },
                textIcon: Text(I18n.of(context).save),
                bottomPadding: SizeConfig.diagonal * 0.8,
                topPadding: SizeConfig.diagonal * 0.8,
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget itemsList() {
    log("length is ${itemList.length}");
    return ListView.builder(
        shrinkWrap: true,
        //physics: BouncingScrollPhysics(),
        itemCount: itemList.length,
        itemBuilder: (BuildContext context, index) {
          return itemTile(itemList[index]);
        });
  }

  Widget itemTile(MenuItem menuItem) {
    return Container(
      width: double.infinity,
      height: menuItem.isChecked
          ? SizeConfig.diagonal * 15
          : SizeConfig.diagonal * 8,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SizeConfig.diagonal * 1.5)),
        child: Column(
          children: [
            CheckboxListTile(
              activeColor: Color(Styling.accentColor),
              title: Text(menuItem.name),
              value: menuItem.isChecked,
              onChanged: (value) {
                setState(() {
                  menuItem.isChecked = value;
                  if (menuItem.isChecked) {
                    if (!itemsToSend.contains(menuItem.id)) {
                      itemsToSend.add(menuItem.id);
                    }
                  } else {
                    if (itemsToSend.contains(menuItem.id)) {
                      itemsToSend.remove(menuItem.id);
                    }
                  }
                });
              },
            ),
            Padding(
              padding: EdgeInsets.only(right: SizeConfig.diagonal * 4),
              child: menuItem.isChecked
                  ? ZTextField(
                      validator: (value) =>
                          value.isEmpty ? I18n.of(context).requit : null,
                      onSaved: (newValue) {
                        quantity = num.parse(newValue);
                      },
                      outsidePrefix: Padding(
                        padding:
                            EdgeInsets.only(left: SizeConfig.diagonal * 0.5),
                        child: Text('Qty needed :'),
                      ),
                      elevation: 1.3,
                    )
                  : null,
            )
          ],
        ),
      ),
    );
  }
}
