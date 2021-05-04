import 'dart:developer';

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
import 'package:zilliken/Models/Condiment.dart';
import 'package:zilliken/Models/MenuItem.dart';
import 'package:zilliken/Models/Stock.dart';
import 'package:zilliken/Services/Authentication.dart';
import 'package:zilliken/Services/Database.dart';
import 'package:zilliken/Services/Messaging.dart';
import 'package:zilliken/i18n.dart';
import 'package:collection/collection.dart';

import '../Components/ZText.dart';
import '../Models/MenuItem.dart';
import '../Models/MenuItem.dart';

class LinkToMenu extends StatefulWidget {
  final Authentication auth;
  final Database db;
  final Messaging messaging;
  final String userId;
  final String userRole;
  final Stock stock;

  LinkToMenu({
    required this.auth,
    required this.db,
    required this.messaging,
    required this.userId,
    required this.userRole,
    required this.stock,
  });
  @override
  _ConnectToMenuState createState() => _ConnectToMenuState();
}

class _ConnectToMenuState extends State<LinkToMenu> {
  List<MenuItem> itemList = [];
  List<MenuItem> itemsToSend = [];

  final _formKey = GlobalKey<FormState>();

  num? quantity;

  @override
  void initState() {
    super.initState();

    waitForItems();
  }

  void waitForItems() {
    widget.db.getMenuItems(widget.stock.id!).then((value) {
      value.forEach((menuItem) {
        if (menuItem.condiments != null) {
          Stock? exist = menuItem.condiments!
              .firstWhereOrNull((element) => element.id == widget.stock.id);
          if (exist != null) {
            menuItem.controller.text = '${exist.quantity}';
          }
        }
      });

      setState(() {
        itemList = value;
      });
      // log("new length is ${itemList.length}");
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
            child: ZText(content: 'Choose any meal that requires this item'),
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: itemsList(),
              ),
              ZElevatedButton(
                onpressed: () async {
                  final form = _formKey.currentState;

                  if (form!.validate()) {
                    form.save();
                    EasyLoading.show(status: I18n.of(context).loading);
                    bool isOnline = await hasConnection();
                    if (!isOnline) {
                      EasyLoading.dismiss();

                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: ZText(content: I18n.of(context).noInternet),
                      ));
                    } else {
                      try {
                        await widget.db.linkToStock(itemsToSend, widget.stock);

                        EasyLoading.dismiss();

                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: ZText(
                              content: I18n.of(context).operationSucceeded),
                        ));
                      } on Exception catch (e) {
                        EasyLoading.dismiss();

                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: ZText(content: e.toString()),
                        ));
                      }
                    }
                  }
                },
                child: ZText(
                  content: I18n.of(context).save,
                  color: Color(Styling.primaryBackgroundColor),
                ),
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
    // log("length is ${itemList.length}");
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
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SizeConfig.diagonal * 1.5)),
        child: CheckboxListTile(
          activeColor: Color(Styling.accentColor),
          title: ZText(content: menuItem.name),
          value: menuItem.isChecked,
          onChanged: (value) {
            setState(() {
              menuItem.isChecked = value;
            });
            if (value!) {
              showGeneralDialog(
                context: context,
                barrierColor: Colors.black.withOpacity(0.5),
                transitionBuilder: (context, a1, a2, widget) {
                  return Transform.scale(
                    scale: a1.value,
                    child: Opacity(
                      opacity: a1.value,
                      child: Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            SizeConfig.diagonal * 1.5,
                          ),
                        ),
                        child: Container(
                          padding: EdgeInsets.only(
                              left: SizeConfig.diagonal * 0.9,
                              right: SizeConfig.diagonal * 0.9),
                          //height: SizeConfig.diagonal * 32,
                          //color: Colors.amber,
                          child: SingleChildScrollView(
                            child: Form(
                              key: _formKey,
                              autovalidateMode: AutovalidateMode.disabled,
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: SizeConfig.diagonal * 2.5,
                                  ),
                                  ZTextField(
                                    hint: I18n.of(context).quantity,
                                    controller: menuItem.controller,
                                    onSaved: (value) {
                                      if (value != null) {
                                        menuItem.quantity = num.parse(value);
                                      }
                                    },
                                    validator: (value) =>
                                        value == null || value.isEmpty
                                            ? I18n.of(context).requit
                                            : null,
                                    icon: Icons.restaurant,
                                  ),
                                  ZElevatedButton(
                                    onpressed: () {
                                      final form = _formKey.currentState;

                                      if (form!.validate()) {
                                        form.save();

                                        // MenuItem? exists = itemsToSend
                                        //     .firstWhereOrNull((element) =>
                                        //         element.id == menuItem.id);
                                        // if (exists == null) {
                                        //   itemsToSend.add(menuItem);
                                        // } else {
                                        menuItem.condiments!.firstWhereOrNull(
                                            (element) =>
                                                element.id == menuItem.id);
                                        itemsToSend.removeWhere((element) =>
                                            element.id == menuItem.id);

                                        Navigator.of(context).pop();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: ZText(
                                                    content: I18n.of(context)
                                                        .operationSucceeded)));
                                        // }
                                      }
                                    },
                                    child: ZText(
                                      content: I18n.of(context).save,
                                      color:
                                          Color(Styling.primaryBackgroundColor),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                barrierDismissible: false,
                barrierLabel: '',
                transitionDuration: Duration(milliseconds: 300),
                pageBuilder: (context, animation1, animation2) {
                  return Container();
                },
              );
            }

            if (menuItem.isChecked!) {
              MenuItem? exist = itemsToSend
                  .firstWhereOrNull((element) => element.id == menuItem.id);
              if (exist == null) {
                itemsToSend.add(menuItem);
              }
            } else {
              menuItem.condiments!
                  .removeWhere((element) => element.id == menuItem.id);
              itemsToSend.removeWhere((element) => element.id == menuItem.id);
            }
          },
        ),
      ),
    );
  }
}
