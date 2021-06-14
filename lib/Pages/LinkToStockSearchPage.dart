import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:zilliken/Components/ZElevatedButton.dart';
import 'package:zilliken/Components/ZText.dart';
import 'package:zilliken/Components/ZTextField.dart';
import 'package:zilliken/Helpers/SizeConfig.dart';
import 'package:zilliken/Helpers/Styling.dart';
import 'package:zilliken/Models/MenuItem.dart';
import 'package:zilliken/Models/Stock.dart';
import 'package:zilliken/Services/Authentication.dart';
import 'package:zilliken/Services/Database.dart';
import 'package:zilliken/i18n.dart';
import 'package:collection/collection.dart';

class LinkToStockSearchPage extends StatefulWidget {
  final Authentication auth;
  final Database db;
  final String userId;
  final String userRole;
  final bool isLoading;
  final List<DocumentSnapshot<Map<String, dynamic>>> searchList;
  final String noResult;
  List<MenuItem>? itemsToSend;
  GlobalKey<FormState> formKey;
  Stock stock;

  LinkToStockSearchPage({
    required this.auth,
    required this.db,
    required this.userId,
    required this.userRole,
    required this.isLoading,
    required this.noResult,
    required this.searchList,
    required this.itemsToSend,
    required this.formKey,
    required this.stock,
  });

  @override
  _LinkToStockSearchPageState createState() => _LinkToStockSearchPageState();
}

class _LinkToStockSearchPageState extends State<LinkToStockSearchPage> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Expanded(
      child: resultView(),
    );
  }

  Widget resultView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        widget.searchList.length == 0
            ? Center(
                child: ZText(
                  content: widget.noResult,
                  fontSize: SizeConfig.diagonal * 2,
                  color: Color(Styling.primaryColor),
                  fontWeight: FontWeight.w700,
                ),
              )
            : ListView(
                shrinkWrap: true,
                children: widget.searchList
                    .map((DocumentSnapshot<Map<String, dynamic>> document) {
                  MenuItem menuItem = MenuItem.buildObject(document);
                  Stock? stock;
                  if (menuItem.condiments != null) {
                    stock = menuItem.condiments!.firstWhereOrNull((condiment) {
                      return condiment.id == widget.stock.id;
                    });

                    if (stock == null) {
                      menuItem.isChecked = false;
                    } else {
                      menuItem.isChecked = true;
                    }
                  } else {
                    menuItem.isChecked = false;
                  }
                  return itemTile(menuItem);
                }).toList(),
              ),
        widget.isLoading
            ? Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(SizeConfig.diagonal * 1),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : Container()
      ],
    );
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
                  transitionBuilder: (context, a1, a2, w) {
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
                                key: widget.formKey,
                                autovalidateMode: AutovalidateMode.disabled,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: SizeConfig.diagonal * 2.5,
                                    ),
                                    ZTextField(
                                      hint:
                                          "${I18n.of(context).quantity}",
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
                                        final form =
                                            widget.formKey.currentState;

                                        if (form!.validate()) {
                                          form.save();
                                          widget.itemsToSend!.removeWhere(
                                              (element) =>
                                                  element.id == menuItem.id);
                                          widget.itemsToSend!.add(menuItem);

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
                  transitionBuilder: (context, a1, a2, w) {
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
                                key: widget.formKey,
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
                                        final form =
                                            widget.formKey.currentState;

                                        if (form!.validate()) {
                                          form.save();

                                          widget.itemsToSend!.removeWhere(
                                              (element) =>
                                                  element.id == menuItem.id);
                                          widget.itemsToSend!.add(menuItem);

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

                widget.itemsToSend!
                    .removeWhere((element) => element.id == menuItem.id);
                widget.itemsToSend!.add(menuItem);

                //itemsToRemove!.add(menuItem);
              }
            },
          ),
        ),
      ),
    );
  }
}
