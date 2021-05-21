import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:zilliken/Components/ZElevatedButton.dart';
import 'package:zilliken/Components/ZTextField.dart';
import 'package:zilliken/Helpers/SizeConfig.dart';
import 'package:zilliken/Helpers/Styling.dart';
import 'package:zilliken/Helpers/Utils.dart';
import 'package:zilliken/Models/Fields.dart';
import 'package:zilliken/Models/MenuItem.dart';
import 'package:zilliken/Models/Stock.dart';
import 'package:zilliken/Pages/LinkToStockPage.dart';
import 'package:zilliken/Pages/NewItemPage.dart';
import 'package:zilliken/Services/Authentication.dart';
import 'package:zilliken/Services/Database.dart';
import 'package:zilliken/Services/Messaging.dart';
import 'package:zilliken/i18n.dart';
import 'package:intl/intl.dart';

import '../Components/ZText.dart';

class StockPage extends StatefulWidget {
  final Authentication auth;
  final Database db;
  final Messaging messaging;
  final String userId;
  final String userRole;
  final DateFormat formatter = DateFormat();

  StockPage({
    required this.auth,
    required this.db,
    required this.messaging,
    required this.userId,
    required this.userRole,
  });

  @override
  _StockPageState createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  final _formKey = GlobalKey<FormState>();
  CollectionReference item =
      FirebaseFirestore.instance.collection(Fields.stock);

  num? quantity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: itemStream(),
      floatingActionButton: CircleAvatar(
        radius: SizeConfig.diagonal * 3.5,
        backgroundColor: Color(Styling.accentColor),
        child: IconButton(
          color: Color(Styling.textColor),
          icon: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewItemPage(
                  db: widget.db,
                  auth: widget.auth,
                  userId: widget.userId,
                  userRole: widget.userRole,
                  messaging: widget.messaging,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget itemStream() {
    return StreamBuilder<QuerySnapshot>(
        stream: item.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.data == null)
            return Center(
              child: ZText(content: ''),
            );

          return ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (BuildContext context, index) {
                Stock stock = Stock.buildObject(snapshot.data!.docs[index]);
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    itemTile(stock),
                  ],
                );
              });
        });
  }

  Widget itemTile(Stock stock) {
    // List<MenuItem> menuItem = [];

    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actions: [
        Padding(
          padding: EdgeInsets.only(left: SizeConfig.diagonal * 0.3),
          child: SlideAction(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(SizeConfig.diagonal * 1.5)),
              elevation: 8,
              child: Container(
                height: SizeConfig.diagonal * 11.3,
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
                  color: Colors.deepOrange,
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
                              key: _formKey,
                              autovalidateMode: AutovalidateMode.disabled,
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: SizeConfig.diagonal * 2.5,
                                  ),
                                  ZTextField(
                                    hint: '${stock.quantity} ${stock.unit}',
                                    onSaved: (value) {
                                      if (value != null) {
                                        setState(() {
                                          quantity = num.parse(value);
                                        });
                                      }
                                    },
                                    validator: (value) => value!.isEmpty
                                        ? I18n.of(context).requit
                                        : null,
                                  ),
                                  ZElevatedButton(
                                    onpressed: () async {
                                      final form = _formKey.currentState;

                                      if (form!.validate()) {
                                        form.save();
                                        EasyLoading.show(
                                            status: I18n.of(context).loading);

                                        bool isOnline = await hasConnection();
                                        if (!isOnline) {
                                          EasyLoading.dismiss();

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: ZText(
                                                  content: I18n.of(context)
                                                      .noInternet),
                                            ),
                                          );
                                        } else {
                                          try {
                                            Stock newStock = Stock(
                                              id: stock.id,
                                              name: stock.name,
                                              quantity: quantity!,
                                              unit: stock.unit,
                                              usedSince: stock.usedSince,
                                              usedTotal: stock.usedTotal,
                                            );
                                            await widget.db.updateInventoryItem(
                                                context, newStock);

                                            EasyLoading.dismiss();
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: ZText(
                                                    content: I18n.of(context)
                                                        .operationSucceeded),
                                              ),
                                            );

                                            setState(() {
                                              _formKey.currentState!.reset();
                                            });

                                            Navigator.of(context).pop();
                                          } on Exception catch (e) {
                                            //print('Error: $e');

                                            EasyLoading.dismiss();
                                            setState(() {
                                              _formKey.currentState!.reset();
                                            });

                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: ZText(
                                                    content: e.toString()),
                                              ),
                                            );
                                          }
                                        }
                                      }
                                    },
                                    child: ZText(
                                      content: I18n.of(context).save,
                                      color:
                                          Color(Styling.primaryBackgroundColor),
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
                                      }),
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
            },
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(SizeConfig.diagonal * 1.5)),
              elevation: 8,
              child: Container(
                height: SizeConfig.diagonal * 11.3,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.update,
                      size: SizeConfig.diagonal * 2.5,
                    ),
                    ZText(content: I18n.of(context).update),
                  ],
                ),
                decoration: BoxDecoration(
                  color: Colors.blue,
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LinkToMenu(
                    db: widget.db,
                    auth: widget.auth,
                    userId: widget.userId,
                    userRole: widget.userRole,
                    messaging: widget.messaging,
                    stock: stock,
                  ),
                ),
              );
            },
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(SizeConfig.diagonal * 1.5)),
              elevation: 8,
              child: Container(
                width: double.infinity,
                height: SizeConfig.diagonal * 11.3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.link,
                      size: SizeConfig.diagonal * 2.5,
                    ),
                    ZText(content: I18n.of(context).linkToMenu),
                  ],
                ),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius:
                      BorderRadius.circular(SizeConfig.diagonal * 1.5),
                ),
              ),
            ),
          ),
        ),
      ],
      child: Container(
        height: SizeConfig.diagonal * 12,
        child: Card(
          margin: EdgeInsets.symmetric(
              horizontal: SizeConfig.diagonal * 0.9,
              vertical: SizeConfig.diagonal * 0.4),
          elevation: 8,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SizeConfig.diagonal * 1.5)),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.diagonal * 1.5,
                vertical: SizeConfig.diagonal * 1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ZText(
                  content: I18n.of(context).name + ' : ${stock.name}',
                  textAlign: TextAlign.start,
                ),
                ZText(
                    content: I18n.of(context).quantity +
                        ' : ${stock.quantity} ${stock.unit}'),
                ZText(
                    content: I18n.of(context).used +
                        ' : ${stock.usedSince} ${stock.unit}'),
                ZText(
                    content: '${widget.formatter.format(stock.date!.toDate())}')
              ],
            ),
          ),
        ),
      ),
      secondaryActions: [
        Padding(
          padding: EdgeInsets.only(left: SizeConfig.diagonal * 0.1),
          child: SlideAction(
            onTap: () {
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
                              key: _formKey,
                              autovalidateMode: AutovalidateMode.disabled,
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: SizeConfig.diagonal * 2.5,
                                  ),
                                  ZTextField(
                                    hint: '${stock.usedSince} ${stock.unit}',
                                    onSaved: (value) {
                                      if (value != null) {
                                        setState(() {
                                          quantity = num.parse(value);
                                        });
                                      }
                                    },
                                    validator: (value) => value!.isEmpty
                                        ? I18n.of(context).requit
                                        : null,
                                  ),
                                  ZElevatedButton(
                                    onpressed: () async {
                                      final form = _formKey.currentState;

                                      if (form!.validate()) {
                                        form.save();
                                        EasyLoading.show(
                                            status: I18n.of(context).loading);

                                        bool isOnline = await hasConnection();
                                        if (!isOnline) {
                                          EasyLoading.dismiss();

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: ZText(
                                                  content: I18n.of(context)
                                                      .noInternet),
                                            ),
                                          );
                                        } else {
                                          try {
                                            Stock newStock = Stock(
                                                id: stock.id,
                                                name: stock.name,
                                                quantity: quantity!,
                                                unit: stock.unit,
                                                usedSince: stock.usedSince,
                                                usedTotal: stock.usedTotal);

                                            await widget.db.manualAdjust(
                                                context, newStock);

                                            EasyLoading.dismiss();
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: ZText(
                                                    content: I18n.of(context)
                                                        .operationSucceeded),
                                              ),
                                            );

                                            setState(() {
                                              _formKey.currentState!.reset();
                                            });

                                            Navigator.of(context).pop();
                                          } on Exception catch (e) {
                                            //print('Error: $e');

                                            EasyLoading.dismiss();
                                            setState(() {
                                              _formKey.currentState!.reset();
                                            });

                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: ZText(
                                                    content: e.toString()),
                                              ),
                                            );
                                          }
                                        }
                                      }
                                    },
                                    child: ZText(
                                      content: I18n.of(context).save,
                                      color:
                                          Color(Styling.primaryBackgroundColor),
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
            },
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SizeConfig.diagonal * 1.5),
              ),
              child: Container(
                height: SizeConfig.diagonal * 11.3,
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
        Padding(
          padding: EdgeInsets.only(right: SizeConfig.diagonal * 0.3),
          child: SlideAction(
            onTap: () async {
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
                  await widget.db.deleteStockItem(context, stock);
                  EasyLoading.dismiss();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          ZText(content: I18n.of(context).operationSucceeded),
                    ),
                  );
                } on Exception catch (e) {
                  EasyLoading.dismiss();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: ZText(content: e.toString()),
                    ),
                  );
                }
              }
            },
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(SizeConfig.diagonal * 1.5)),
              elevation: 8,
              child: Container(
                height: SizeConfig.diagonal * 11.3,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.delete_forever_sharp,
                      size: SizeConfig.diagonal * 2.5,
                    ),
                    ZText(content: I18n.of(context).delete),
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
        )
      ],
    )

        /*Card(
      margin: EdgeInsets.symmetric(
          horizontal: SizeConfig.diagonal * 0.9,
          vertical: SizeConfig.diagonal * 0.3),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeConfig.diagonal * 1.5)),
      elevation: 8,
      child: ListTile(
        onTap: () {},
        leading: Icon(
          Icons.food_bank,
          size: SizeConfig.diagonal * 4,
        ),
        title: Text(stock.name),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(I18n.of(context).quantity +
                ' : ' +
                '${stock.quantity}' +
                ' ' +
                stock.unit),
            Text(I18n.of(context).used + ' : ' + '${stock.usedSince}'),
          ],
        ),
      ),
    )*/
        ;
  }
}
