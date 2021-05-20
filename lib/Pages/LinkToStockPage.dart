import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
  List<MenuItem>? itemsToSend = [];
  // List<MenuItem>? itemsToRemove = [];

  final _formKey = GlobalKey<FormState>();

  num? quantity;

  @override
  void initState() {
    super.initState();

    waitForItems();
  }

  void waitForItems() {
    widget.db.getMenuItems(widget.stock.id!).then((value) {
      /*value.forEach((element) {
        if (element.isChecked!) {
          itemsToSend.add(element);
        }
      });*/

      setState(() {
        itemList = value;
      });
      // log("new length is ${itemList.length}");
    });
    // itemList.sortByCompare(
    //     (element) => element.name, (a, b) => a!.length.compareTo(b!.length));
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
            child: ZText(content: I18n.of(context).linkDescription),
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
                  EasyLoading.show(status: I18n.of(context).loading);
                  bool isOnline = await hasConnection();
                  if (!isOnline) {
                    EasyLoading.dismiss();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: ZText(content: I18n.of(context).noInternet),
                      ),
                    );
                  } else {
                    try {
                      await widget.db.linkToStock(itemsToSend!, widget.stock);
                      log('itemsToSend: ${itemsToSend}');
                      // log('itemsToRemove: ${itemsToRemove}');
                      /*  itemsToSend.clear();
                      itemsToRemove.clear();*/

                      EasyLoading.dismiss();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: ZText(
                              content: I18n.of(context).operationSucceeded),
                        ),
                      );
                    } on Exception catch (e) {
                      EasyLoading.dismiss();

                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: ZText(content: e.toString()),
                      ));
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
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actions: [
        Padding(
          padding: EdgeInsets.only(left: SizeConfig.diagonal * 0.1),
          child: SlideAction(
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SizeConfig.diagonal * 1.5),
              ),
              child: Container(
                height: SizeConfig.diagonal * 6.3,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cancel,
                      size: SizeConfig.diagonal * 2.5,
                    ),
                    ZText(content: I18n.of(context).cancelOnly),
                  ],
                ),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius:
                      BorderRadius.circular(SizeConfig.diagonal * 1.5),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: SizeConfig.diagonal * 0.1),
          child: SlideAction(
            onTap: () {
              if (menuItem.isChecked!) {
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
                                          setState(() {
                                            menuItem.quantity =
                                                num.parse(value);
                                          });
                                        }
                                      },
                                      validator: (value) => value!.isEmpty
                                          ? I18n.of(context).requit
                                          : null,
                                      icon: Icons.restaurant,
                                    ),
                                    ZElevatedButton(
                                      onpressed: () {
                                        final form = _formKey.currentState;

                                        if (form!.validate()) {
                                          form.save();

                                          itemsToSend!.removeWhere((element) =>
                                              element.id == menuItem.id);
                                          itemsToSend!.add(menuItem);

                                          Navigator.of(context).pop();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: ZText(
                                                      content: I18n.of(context)
                                                          .added)));
                                          // }
                                        }
                                      },
                                      child: ZText(
                                        content: I18n.of(context).addItem,
                                        color: Color(
                                            Styling.primaryBackgroundColor),
                                      ),
                                      bottomPadding: SizeConfig.diagonal * 0.3,
                                    ),
                                    IconButton(
                                        color: Colors.red,
                                        icon: Icon(
                                          Icons.cancel_sharp,
                                        ),
                                        iconSize: SizeConfig.diagonal * 5,
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        })
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
            },
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SizeConfig.diagonal * 1.5),
              ),
              child: Container(
                height: SizeConfig.diagonal * 6.3,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: SizeConfig.diagonal * 2.5,
                    ),
                    ZText(
                      content: I18n.of(context).edit,
                      color: Colors.white,
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                  color: Color(Styling.primaryColor),
                  borderRadius:
                      BorderRadius.circular(SizeConfig.diagonal * 1.5),
                ),
              ),
            ),
          ),
        ),
      ],
      secondaryActions: [
        Padding(
          padding: EdgeInsets.only(left: SizeConfig.diagonal * 0.1),
          child: SlideAction(
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SizeConfig.diagonal * 1.5),
              ),
              child: Container(
                height: SizeConfig.diagonal * 6.3,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.adjust,
                      size: SizeConfig.diagonal * 2.5,
                    ),
                    ZText(content: I18n.of(context).adjust),
                  ],
                ),
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius:
                      BorderRadius.circular(SizeConfig.diagonal * 1.5),
                ),
              ),
            ),
          ),
        ),
      ],
      child: Container(
        width: double.infinity,
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SizeConfig.diagonal * 1.5)),
          child: CheckboxListTile(
            activeColor: Color(Styling.accentColor),
            title: ZText(content: menuItem.name),
            //subtitle: ZText(content: '${menuItem.quantity} ${widget.stock.unit}'),
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
                                          setState(() {
                                            menuItem.quantity =
                                                num.parse(value);
                                          });
                                        }
                                      },
                                      validator: (value) => value!.isEmpty
                                          ? I18n.of(context).requit
                                          : null,
                                      icon: Icons.restaurant,
                                    ),
                                    ZElevatedButton(
                                      onpressed: () {
                                        final form = _formKey.currentState;

                                        if (form!.validate()) {
                                          form.save();

                                          itemsToSend!.removeWhere((element) =>
                                              element.id == menuItem.id);
                                          itemsToSend!.add(menuItem);

                                          Navigator.of(context).pop();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: ZText(
                                                      content: I18n.of(context)
                                                          .added)));
                                          // }
                                        }
                                      },
                                      child: ZText(
                                        content: I18n.of(context).addItem,
                                        color: Color(
                                            Styling.primaryBackgroundColor),
                                      ),
                                      bottomPadding: SizeConfig.diagonal * 0.3,
                                    ),
                                    IconButton(
                                        color: Colors.red,
                                        icon: Icon(
                                          Icons.cancel_sharp,
                                        ),
                                        iconSize: SizeConfig.diagonal * 5,
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          setState(() {
                                            menuItem.isChecked = false;
                                          });
                                        })
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
              } else {
                log('else is executed');

                /*  menuItem.condiments!
                  .removeWhere((element) => element.id == menuItem.id);
              itemsToSend.removeWhere((element) => element.id == menuItem.id);*/

                /*MenuItem item = itemsToSend
                  .firstWhere((element) => element.id == menuItem.id);
              item.condiments!
                  .removeWhere((element) => element.id == widget.stock.id);
              if (item.condiments!.isEmpty) {
                item.condiments = null;
              }*/

                menuItem.condiments!.removeWhere(
                    (condiment) => condiment.id == widget.stock.id);
                if (menuItem.condiments!.isEmpty) {
                  menuItem.condiments = null;
                }
                menuItem.quantity = null;

                itemsToSend!
                    .removeWhere((element) => element.id == menuItem.id);
                itemsToSend!.add(menuItem);

                //itemsToRemove!.add(menuItem);
              }
            },
          ),
        ),
      ),
    );
  }
}
