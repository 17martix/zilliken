import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:zilliken/Components/ZElevatedButton.dart';
import 'package:zilliken/Components/ZTextField.dart';
import 'package:zilliken/Helpers/SizeConfig.dart';
import 'package:zilliken/Helpers/Styling.dart';
import 'package:zilliken/Helpers/Utils.dart';
import 'package:zilliken/Models/Fields.dart';
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
  final DateFormat formatter = DateFormat('dd/MM/yy HH:mm');

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
  Query<Map<String, dynamic>> item = FirebaseFirestore.instance
      .collection(Fields.stock)
      .orderBy(Fields.quantity, descending: false);

  num? quantity;

  /*bool isLoading = false;
  bool hasMore = true;
  int documentLimit = 5;
  ScrollController _scrollController = ScrollController();
  DocumentSnapshot? lastDocument;
  late Query<Map<String, dynamic>> stockRef;
  List<DocumentSnapshot<Map<String, dynamic>>> items = [];*/

  @override
  void initState() {
    super.initState();

    /*stockQuery();
    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.20;
      if (maxScroll - currentScroll <= delta) {
        stockQuery();
      }
    });*/
  }

  /* void stockQuery() {
    if (!hasMore) {
      return;
    }

    if (isLoading == true) {
      return;
    }

    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    if (lastDocument == null) {
      stockRef = widget.db.databaseReference
          .collection(Fields.stock)
          .orderBy(Fields.date, descending: false)
          .limit(documentLimit);
    } else {
      stockRef = widget.db.databaseReference
          .collection(Fields.stock)
          .orderBy(Fields.date, descending: false)
          .startAfterDocument(lastDocument!)
          .limit(documentLimit);
    }

    stockRef.get().then((QuerySnapshot<Map<String, dynamic>> snapshot) {
      if (snapshot.docs.length < documentLimit) {
        hasMore = false;
      }

      if (snapshot.docs.length > 0)
        lastDocument = snapshot.docs[snapshot.docs.length - 1];

      if (mounted) {
        setState(() {
          for (int i = 0; i < snapshot.docs.length; i++) {
            Object? exist = items.firstWhereOrNull((Object element) {
              if (element is DocumentSnapshot<Map<String, dynamic>>) {
                bool isEqual = element.id == snapshot.docs[i].id;
                return isEqual;
              } else {
                return false;
              }
            });

            if (exist == null) {
              items.add(snapshot.docs[i]);
            }
          }

          isLoading = false;
        });
      }
    });
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: itemStream(),
      floatingActionButton: CircleAvatar(
        radius: SizeConfig.diagonal * 3.5,
        backgroundColor: Color(Styling.accentColor),
        child: IconButton(
          color: Color(Styling.primaryBackgroundColor),
          icon: Icon(Icons.add, size: SizeConfig.diagonal * 2.5),
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
            ) /*.then((value) {
              hasMore = true;
              stockQuery();
            })*/
                ;
          },
        ),
      ),
    );
  }

  Widget itemStream() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: item.snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.data == null || snapshot.data!.docs.isEmpty)
            return Center(
              child: ZText(content: ''),
            );

          return ListView.builder(
              physics: ScrollPhysics(),
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
    /* return ListView(
      controller: _scrollController,
      children: [
        items.length == 0
            ? Center(
                child: ZText(content: ""),
              )
            : Column(
                children: items
                    .map((DocumentSnapshot<Map<String, dynamic>> document) {
                  Stock stock = Stock.buildObject(document);
                  return itemTile(stock);
                }).toList(),
              ),
        isLoading
            ? Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(SizeConfig.diagonal * 1),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation(Color(Styling.accentColor)),
                  ),
                ),
              )
            : Container()
      ],
    );*/
  }

  Widget itemTile(Stock stock) {
    return Padding(
      padding: EdgeInsets.only(bottom: SizeConfig.diagonal * 1),
      child: Slidable(
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
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cancel,
                        size: SizeConfig.diagonal * 2.5,
                      ),
                      ZText(
                        content: I18n.of(context).cancelOnly,
                        color: Color(Styling.primaryBackgroundColor),
                      ),
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
                                    Padding(
                                      padding: EdgeInsets.only(
                                        top: SizeConfig.diagonal * 4,
                                        bottom: SizeConfig.diagonal * 1.5,
                                      ),
                                      child: SizedBox(
                                        height: SizeConfig.diagonal * 2.5,
                                        child: ZText(
                                          content: I18n.of(context).refillTitle,
                                        ),
                                      ),
                                    ),
                                    ZTextField(
                                      hint: '${stock.quantity} ${stock.unit}',
                                      onSaved: (value) {
                                        if (value != null) {
                                          if (mounted) {
                                            setState(() {
                                              quantity = num.parse(value);
                                            });
                                          }
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
                                              await widget.db
                                                  .updateInventoryItem(
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
                                              if (mounted) {
                                                setState(() {
                                                  _formKey.currentState!
                                                      .reset();
                                                });
                                              }

                                              Navigator.of(context).pop();
                                            } on Exception catch (e) {
                                              //print('Error: $e');

                                              EasyLoading.dismiss();
                                              if (mounted) {
                                                setState(() {
                                                  _formKey.currentState!
                                                      .reset();
                                                });
                                              }

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
                      BorderRadius.circular(SizeConfig.diagonal * 1.5),
                ),
                elevation: 8,
                child: Container(
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.upgrade_rounded,
                        size: SizeConfig.diagonal * 2.5,
                      ),
                      ZText(
                        content: I18n.of(context).refillStock,
                        color: Color(Styling.primaryBackgroundColor),
                      ),
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.link,
                        size: SizeConfig.diagonal * 2.5,
                      ),
                      ZText(
                        content: I18n.of(context).linkToMenu,
                        color: Color(Styling.primaryBackgroundColor),
                      ),
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
          child: Column(
            children: [
              Card(
                color: Colors.white.withOpacity(0.7),
                margin: EdgeInsets.symmetric(
                  horizontal: SizeConfig.diagonal * 0.9,
                ),
                elevation: 8,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(SizeConfig.diagonal * 1.5)),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.diagonal * 1.5,
                    vertical: SizeConfig.diagonal * 1,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      // left: SizeConfig.diagonal * 1,
                                      right: SizeConfig.diagonal * 2),
                                  child: Icon(
                                    Icons.inventory_outlined,
                                    size: 25,
                                    color: Color(Styling.accentColor),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              bottom: SizeConfig.diagonal * 1),
                                          child: ZText(
                                            content: '${stock.name}',
                                            fontWeight: FontWeight.bold,
                                            fontSize: SizeConfig.diagonal * 1.7,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              bottom: SizeConfig.diagonal * 1),
                                          child: ZText(
                                              content:
                                                  '${stock.quantity} ${stock.unit} ' +
                                                      I18n.of(context).inStock),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              bottom: SizeConfig.diagonal * 1),
                                          child: ZText(
                                              content:
                                                  '${stock.usedSince} ${stock.unit} /' +
                                                      '${stock.quantity + stock.usedSince} ${stock.unit} ' +
                                                      I18n.of(context).used),
                                        ),
                                        if (stock.date != null)
                                          ZText(
                                              content:
                                                  '${I18n.of(context).refilledAt} ${widget.formatter.format(stock.date!.toDate())}'),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                                left: SizeConfig.diagonal * 1,
                                top: SizeConfig.diagonal * 1),
                            child: SleekCircularSlider(
                                max: (stock.quantity / 100) +
                                    (stock.usedSince / 100),
                                initialValue: stock.quantity / 100,
                                appearance: CircularSliderAppearance(
                                  customColors: CustomSliderColors(
                                      trackColor: Color(Styling.accentColor),
                                      progressBarColors: [
                                        Colors.blue,
                                        Colors.yellow,
                                        Colors.red,
                                      ]),
                                  infoProperties: InfoProperties(
                                    mainLabelStyle: TextStyle(
                                      fontSize: SizeConfig.diagonal * 1.5,
                                    ),
                                    modifier: (percentage) {
                                      double pt = (stock.quantity * 100) /
                                          (stock.quantity + stock.usedSince);
                                      return "${pt.toInt()}%";
                                    },
                                    bottomLabelText: I18n.of(context).remaining,
                                    bottomLabelStyle: TextStyle(
                                      fontSize: SizeConfig.diagonal * 1.35,
                                    ),
                                  ),
                                  size: SizeConfig.diagonal * 11,
                                  spinnerMode: false,
                                )),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
                                    Padding(
                                      padding: EdgeInsets.only(
                                        top: SizeConfig.diagonal * 4,
                                        bottom: SizeConfig.diagonal * 1.5,
                                      ),
                                      child: SizedBox(
                                        height: SizeConfig.diagonal * 2.5,
                                        child: ZText(
                                          content: I18n.of(context).updateTitle,
                                        ),
                                      ),
                                    ),
                                    ZTextField(
                                      hint: '${stock.usedSince} ${stock.unit}',
                                      onSaved: (value) {
                                        if (value != null) {
                                          if (mounted) {
                                            setState(() {
                                              quantity = num.parse(value);
                                            });
                                          }
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
                                              if (mounted) {
                                                setState(() {
                                                  _formKey.currentState!
                                                      .reset();
                                                });
                                              }

                                              Navigator.of(context).pop();
                                            } on Exception catch (e) {
                                              //print('Error: $e');

                                              EasyLoading.dismiss();
                                              if (mounted) {
                                                setState(() {
                                                  _formKey.currentState!
                                                      .reset();
                                                });
                                              }

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
              },
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(SizeConfig.diagonal * 1.5),
                ),
                child: Container(
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.update,
                        size: SizeConfig.diagonal * 2.5,
                      ),
                      ZText(
                        content: I18n.of(context).updateStock,
                        color: Color(Styling.primaryBackgroundColor),
                      ),
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
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delete_forever_sharp,
                        size: SizeConfig.diagonal * 2.5,
                      ),
                      ZText(
                        content: I18n.of(context).delete,
                        color: Color(Styling.primaryBackgroundColor),
                      ),
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
      ),
    );
  }
}
