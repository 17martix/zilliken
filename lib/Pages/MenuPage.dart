import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:zilliken/Components/ZElevatedButton.dart';
import 'package:zilliken/Components/ZTextField.dart';
import 'package:zilliken/FirebaseImage/firebase_image.dart';
import 'package:zilliken/Helpers/NumericStepButton.dart';
import 'package:zilliken/Helpers/SizeConfig.dart';
import "package:zilliken/Helpers/Styling.dart";
import 'package:zilliken/Helpers/Utils.dart';
import 'package:zilliken/Models/Category.dart';
import 'package:zilliken/Models/Fields.dart';
import 'package:zilliken/Models/MenuItem.dart';
import 'package:zilliken/Models/OrderItem.dart';
import 'package:zilliken/Models/Stock.dart';
import 'package:zilliken/Services/Authentication.dart';
import 'package:zilliken/Services/Database.dart';
import 'package:zilliken/Services/Messaging.dart';
import 'package:file_picker/file_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:collection/collection.dart';

import 'package:zilliken/i18n.dart';

import '../Components/ZText.dart';
import 'CartPage.dart';

class MenuPage extends StatefulWidget {
  final Authentication auth;
  final Database db;
  final String userId;
  final String userRole;
  final List<OrderItem>? clientOrder;
  final Messaging messaging;

  MenuPage({
    required this.auth,
    required this.db,
    required this.userId,
    required this.userRole,
    this.clientOrder,
    required this.messaging,
  });

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  late Query<Map<String, dynamic>> commandes;
  var categories = FirebaseFirestore.instance
      .collection(Fields.category)
      .orderBy(Fields.rank, descending: false);
  String selectedCategory = Fields.boissonsChaudes;
  List<OrderItem> clientOrder = [];

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  int _itemorCategory = 0;
  //MenuItem? _menuItem;
  //Category? _cat;

  bool _isCategoryLoaded = false;
  final _formKey = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();
  final _catformKey = GlobalKey<FormState>();
  List<String> _catList = [];
  MenuItem? newMenuItem;

  String? category;
  String? name;
  int? price;
  String? _catName;
  String? newName;
  int? newPrice;
  String? newId;

  List<Stock> stockList = [];

  // String? _stockId;

  @override
  void initState() {
    super.initState();
    log("mon id est ${widget.userId}");
    if (mounted) {
      setState(() {
        commandesQuery(selectedCategory);
      });
    }

    if (widget.clientOrder != null &&
        widget.clientOrder!.length > 0) if (mounted) {
      setState(() {
        clientOrder = widget.clientOrder!;
      });
    }

    widget.db.getCategories().then((value) {
      _catList.addAll(value);
      category = _catList[0];
      _isCategoryLoaded = true;
    });

    widget.db.getStock().then((value) {
      stockList = value;
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
      body: body(),
    );
  }

  Widget body() {
    return Stack(
      children: [
        Column(
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
        ),
      ],
    );
  }

  Widget addItemCategory() {
    return Column(
      children: [
        //chooseCategoryOrItems(),
        if (widget.userRole == Fields.developer ||
            widget.userRole == Fields.admin)
          ZElevatedButton(
            child: ZText(
              content: I18n.of(context).loadData,
              fontSize: SizeConfig.diagonal * 1.5,
              color: Color(Styling.primaryBackgroundColor),
            ),
            bottomPadding: SizeConfig.diagonal * 1,
            topPadding: SizeConfig.diagonal * 1,
            onpressed: loadData,
          ),
      ],
    );
  }

  Widget chooseCategoryOrItems() {
    return Container(
      padding: EdgeInsets.all(SizeConfig.diagonal * 1),
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ZText(
            content: I18n.of(context).addWhat,
            fontWeight: FontWeight.bold,
            fontSize: SizeConfig.diagonal * 1.5,
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
              ZText(
                  content: I18n.of(context).item,
                  fontSize: SizeConfig.diagonal * 1.5),
              new Radio(
                value: 1,
                groupValue: _itemorCategory,
                onChanged: _handleValueChange,
              ),
              ZText(
                content: I18n.of(context).category,
                fontSize: SizeConfig.diagonal * 1.5,
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
                        onSaved: (value) => name = value,
                        validator: (value) => value == null || value.isEmpty
                            ? I18n.of(context).requit
                            : null,
                        keyboardType: TextInputType.text,
                        icon: Icons.restaurant_menu,
                        obsecure: false,
                        hint: I18n.of(context).itemName,
                      ),
                      ZTextField(
                        onSaved: (value) {
                          if (value != null) {
                            price = int.parse(value);
                          }
                        },
                        validator: (value) => value == null || value.isEmpty
                            ? I18n.of(context).requit
                            : null,
                        keyboardType: TextInputType.number,
                        icon: Icons.monetization_on,
                        obsecure: false,
                        hint: I18n.of(context).itemPrice,
                      ),
                      if (_isCategoryLoaded)
                        DropdownButton<String>(
                          value: category,
                          icon: Icon(Icons.arrow_drop_down),
                          iconSize: 24,
                          elevation: 16,
                          style: TextStyle(
                            color: Color(Styling.accentColor),
                            fontSize: SizeConfig.diagonal * 1.5,
                          ),
                          onChanged: (String? newValue) {
                            if (mounted) {
                              setState(() {
                                category = newValue;
                              });
                            }
                          },
                          items: _catList
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: ZText(
                                content: value,
                                fontSize: SizeConfig.diagonal * 1.5,
                              ),
                            );
                          }).toList(),
                        ),
                      ZElevatedButton(
                        child: ZText(
                          content: I18n.of(context).addItem,
                          fontSize: SizeConfig.diagonal * 1.5,
                          color: Color(Styling.primaryBackgroundColor),
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
                        onSaved: (value) => _catName = value,
                        validator: (value) => value == null || value.isEmpty
                            ? I18n.of(context).requit
                            : null,
                        keyboardType: TextInputType.text,
                        icon: Icons.category,
                        obsecure: false,
                        hint: I18n.of(context).categoryName,
                      ),
                      ZElevatedButton(
                        child: ZText(
                          content: I18n.of(context).addItem,
                          fontSize: SizeConfig.diagonal * 2,
                          color: Color(Styling.primaryBackgroundColor),
                        ),
                        bottomPadding: SizeConfig.diagonal * 1,
                        onpressed: saveCategory,
                      ),
                    ],
                  ),
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
                  messaging: widget.messaging,
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
              title: ZText(
                content: numberItems(context, clientOrder),
                color: Color(Styling.primaryBackgroundColor),
                fontSize: SizeConfig.diagonal * 1.5,
              ),
              subtitle: ZText(
                content: priceItems(context, clientOrder),
                color: Color(Styling.primaryBackgroundColor),
                fontWeight: FontWeight.bold,
                fontSize: SizeConfig.diagonal * 1.5,
              ),
              trailing: ZText(
                content: I18n.of(context).vOrder,
                color: Color(Styling.primaryBackgroundColor),
                fontSize: SizeConfig.diagonal * 1.5,
              ),
            ),
          ),
        ));
  }

  bool validateAndSaveCategory() {
    final form = _catformKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void loadData() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['.csv'],
    );

    if (result != null) {
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
          List<File> files = result.paths.map((path) => File(path!)).toList();
          File? menu;
          File? category;

          for (int i = 0; i < files.length; i++) {
            PlatformFile platformFile = result.files[i];
            log(platformFile.name!);
            if (platformFile.name == 'menu.csv') {
              menu = files[i];
            }

            if (platformFile.name == 'category.csv') {
              category = files[i];
            }
          }

          if (menu == null || category == null) {
            EasyLoading.dismiss();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: ZText(content: "menu or category null"),
              ),
            );
          } else {
            await widget.db.sendData(menu, category);
            EasyLoading.dismiss();
          }
        } on Exception catch (e) {
          //print('Error: $e');
          EasyLoading.dismiss();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: ZText(content: e.toString()),
            ),
          );
        }
      }
    } else {
      // User canceled the picker
    }

/*
    setState(() {
      _isLoading = true;
    });

    bool isOnline = await DataConnectionChecker().hasConnection;
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
    }*/
  }

  void saveCategory() async {
    if (validateAndSaveCategory()) {
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
          await widget.db.addCategoy(Category(
            name: _catName!,
          ));

          _catList.clear();
          widget.db.getCategories().then((value) {
            if (mounted) {
              setState(() {
                _catList.addAll(value);
                category = _catList[0];
                _isCategoryLoaded = true;
              });
            }
          });

          EasyLoading.dismiss();

          if (mounted) {
            setState(() {
              _catformKey.currentState!.reset();
            });
          }
        } on Exception catch (e) {
          //print('Error: $e');
          EasyLoading.dismiss();
          if (mounted) {
            setState(() {
              _catformKey.currentState!.reset();
            });
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: ZText(content: e.toString()),
            ),
          );
        }
      }
    }
  }

  bool validateAndSaveItem() {
    final form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void saveItem() async {
    if (validateAndSaveItem()) {
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
          MenuItem menuItem = MenuItem(
            category: category,
            name: name!,
            price: price!,
          );
          await widget.db.addItem(menuItem);

          EasyLoading.dismiss();

          if (mounted) {
            setState(() {
              _formKey.currentState!.reset();
            });
          }
        } on Exception catch (e) {
          //print('Error: $e');

          EasyLoading.dismiss();
          if (mounted) {
            setState(() {
              _formKey.currentState!.reset();
            });
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: ZText(content: e.toString()),
            ),
          );
        }
      }
    }
  }

  void _handleValueChange(int? value) {
    if (mounted) {
      setState(() {
        _itemorCategory = value!;
      });
    }
  }

  Widget categoryList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: categories.snapshots(),
      builder: (BuildContext context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.data == null)
          return Center(
            child: ZText(content: ""),
          );

        return Container(
          margin: EdgeInsets.symmetric(horizontal: SizeConfig.diagonal * 1),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: snapshot.data!.docs
                  .map((DocumentSnapshot<Map<String, dynamic>> document) {
                Category category = Category.buildObject(document);
                return categoryItem(category);
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget menulist() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: commandes.snapshots(),
      builder: (BuildContext context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.data == null)
          return Center(
            child: ZText(content: ""),
          );

        /*return AnimatedList(
            initialItemCount: snapshot.data.docs.length,
            itemBuilder: (context, index, animation) {
              MenuItem menu = MenuItem();
              menu.buildObject(snapshot.data.docs[index]);
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(-1, 0),
                  end: Offset(0, 0),
                ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.bounceIn,
                    reverseCurve: Curves.bounceOut)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //if (menu.rank == 1) categoryRow(menu),
                    item(menu),
                  ],
                ),
              );
            });*/
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            MenuItem menu = MenuItem.buildObject(snapshot.data!.docs[index]);
            bool isDisplayed = true;
            if (menu.condiments != null) {
              menu.condiments!.forEach((menuStock) {
                Stock? stock = stockList.firstWhereOrNull(
                    (stockElement) => stockElement.id == menuStock.id);

                if (stock != null) {
                  if (stock.quantity < menuStock.quantity) {
                    isDisplayed = false;
                    return;
                  }
                }
              });
            }
            // num q;
            // _stockId = menu.condiments!.elementAt(0).buildStringFromObject(q);
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                isDisplayed
                    ?
                    //if (menu.rank == 1) categoryRow(menu),
                    item(menu)
                    : Container(),
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
          ZText(
            content: menu.category!,
            color: Color(Styling.primaryColor),
            fontWeight: FontWeight.bold,
            fontSize: SizeConfig.diagonal * 1.8,
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
      color: Colors.white.withOpacity(0.7),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeConfig.diagonal * 1.5)),
      elevation: 2,
      child: Row(
        children: [
          InkWell(
            onLongPress: (widget.userRole == Fields.developer ||
                    widget.userRole == Fields.admin)
                ? () => changeImage(menu.imageName!)
                : () {},
            child: Container(
              decoration: BoxDecoration(
                // color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(SizeConfig.diagonal * 1.5),
                image: DecorationImage(
                  image: FirebaseImage(
                    '${widget.db.firebaseBucket}/images/${menu.imageName}',
                    cacheRefreshStrategy: CacheRefreshStrategy.NEVER,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              height: SizeConfig.diagonal * 10,
              width: SizeConfig.diagonal * 10,
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: (widget.userRole == Fields.admin ||
                      widget.userRole == Fields.developer)
                  ? () {
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
                                      key: _formKey1,
                                      autovalidateMode:
                                          AutovalidateMode.disabled,
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: SizeConfig.diagonal * 5,
                                                bottom:
                                                    SizeConfig.diagonal * 3),
                                            child: ZText(
                                                content: I18n.of(context)
                                                    .editMenuItem),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                              bottom: SizeConfig.diagonal * 1,
                                            ),
                                            child: ZTextField(
                                              hint: I18n.of(context).itemName,
                                              onSaved: (value) {
                                                if (value != null) {
                                                  newName = value;
                                                }
                                              },
                                              validator: (value) =>
                                                  value == null || value.isEmpty
                                                      ? I18n.of(context).requit
                                                      : null,
                                              icon: Icons.short_text_sharp,
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                              bottom: SizeConfig.diagonal * 1,
                                            ),
                                            child: ZTextField(
                                              hint: I18n.of(context).itemPrice,
                                              onSaved: (value) {
                                                if (value != null) {
                                                  newPrice = int.parse(value);
                                                }
                                              },
                                              validator: (value) =>
                                                  value == null || value.isEmpty
                                                      ? I18n.of(context).requit
                                                      : null,
                                              icon: Icons.price_check_sharp,
                                            ),
                                          ),
                                          ZElevatedButton(
                                            onpressed: () async {
                                              final form =
                                                  _formKey1.currentState;

                                              if (form!.validate()) {
                                                form.save();
                                                newId = menu.id;
                                                EasyLoading.show(
                                                    status: I18n.of(context)
                                                        .loading);
                                                bool isOnline =
                                                    await hasConnection();
                                                if (!isOnline) {
                                                  EasyLoading.dismiss();
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: ZText(
                                                          content:
                                                              I18n.of(context)
                                                                  .noInternet),
                                                    ),
                                                  );
                                                } else {
                                                  try {
                                                    MenuItem menuItem =
                                                        MenuItem(
                                                            name: newName!,
                                                            price: newPrice!);
                                                    await this
                                                        .widget
                                                        .db
                                                        .updateDetails(
                                                            menuItem);
                                                    EasyLoading.dismiss();
                                                    Navigator.of(context).pop();
                                                  } on Exception catch (e) {
                                                    EasyLoading.dismiss();
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                      content: ZText(
                                                          content:
                                                              e.toString()),
                                                    ));
                                                  }
                                                }
                                              }
                                            },
                                            child: ZText(
                                              content: I18n.of(context).save,
                                              color: Color(Styling
                                                  .primaryBackgroundColor),
                                            ),
                                            bottomPadding:
                                                SizeConfig.diagonal * 0.3,
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
                    }
                  : () {},
              child: Container(
                padding: EdgeInsets.all(SizeConfig.diagonal * 1),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ZText(
                      content: menu.name,
                      textAlign: TextAlign.left,
                      //overflow: TextOverflow.ellipsis,

                      color: Color(Styling.textColor),
                      fontWeight: FontWeight.bold,

                      fontSize: SizeConfig.diagonal * 1.5,
                    ),
                    SizedBox(width: SizeConfig.diagonal * 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 1,
                          child: ZText(
                            content:
                                "${formatNumber(menu.price)} ${I18n.of(context).fbu}",
                            textAlign: TextAlign.left,

                            color: Color(Styling.accentColor),
                            fontWeight: FontWeight.bold,
                            fontSize: SizeConfig.diagonal * 1.5,
                            //fontFamily: "assets/Cochin.ttf",
                          ),
                        ),
                        widget.userRole != Fields.client
                            ? Expanded(
                                flex: 1,
                                child: SwitchListTile(
                                  activeColor: Color(Styling.accentColor),
                                  value: menu.availability == 1 ? true : false,
                                  onChanged: (isEnabled) =>
                                      itemAvailability(isEnabled, menu),
                                ),
                              )
                            : isAlreadyOnTheOrder(clientOrder, menu.id!)
                                ? Expanded(
                                    flex: 1,
                                    child: NumericStepButton(
                                      counter:
                                          findOrderItem(clientOrder, menu.id!)
                                              .count,
                                      maxValue: 20,
                                      onChanged: (value) {
                                        OrderItem orderItem = findOrderItem(
                                            clientOrder, menu.id!);
                                        if (value == 0) {
                                          if (mounted) {
                                            setState(() {
                                              clientOrder.remove(orderItem);
                                            });
                                          }
                                          //order.remove(orderItem);
                                        } else {
                                          if (mounted) {
                                            setState(() {
                                              orderItem.count = value;
                                            });
                                          }
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
                                            if (mounted) {
                                              setState(() {
                                                clientOrder.add(OrderItem(
                                                  menuItem: menu,
                                                  count: 1,
                                                ));
                                              });
                                            }
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Color(Styling.accentColor),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      SizeConfig.diagonal * 3),
                                              border: Border.all(
                                                color:
                                                    Color(Styling.accentColor),
                                              ),
                                            ),
                                            margin: EdgeInsets.all(
                                                SizeConfig.diagonal * 1),
                                            padding: EdgeInsets.all(
                                                SizeConfig.diagonal * 1),
                                            child: Row(
                                              children: [
                                                ZText(
                                                    content: I18n.of(context)
                                                        .addItem,
                                                    color: Colors.white,
                                                    fontSize:
                                                        SizeConfig.diagonal *
                                                            1.5),
                                                SizedBox(
                                                    width: SizeConfig.diagonal *
                                                        0.5),
                                                Icon(
                                                  Icons.add,
                                                  size:
                                                      SizeConfig.diagonal * 1.5,
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
          ),
        ],
      ),
    );
  }

  Widget categoryItem(Category category) {
    return InkWell(
      onLongPress: (widget.userRole == Fields.developer ||
              widget.userRole == Fields.admin)
          ? () => changeImage(category.imageName!)
          : () {},
      onTap: () {
        if (mounted) {
          setState(() {
            selectedCategory = category.name;
            commandesQuery(category.name);
          });
        }
      },
      child: Container(
        width: SizeConfig.diagonal * 25,
        height: SizeConfig.diagonal * 15,
        margin: EdgeInsets.all(SizeConfig.diagonal * 0.5),
        decoration: BoxDecoration(
          image: DecorationImage(
              image: /*AssetImage("assets/frites.jpg"),*/
                  FirebaseImage(
                '${widget.db.firebaseBucket}/images/${category.imageName}',
                cacheRefreshStrategy: CacheRefreshStrategy.NEVER,
              ),
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
            child: ZText(
                content: category.name,
                textAlign: TextAlign.center,
                fontSize: SizeConfig.diagonal * 2,
                color: Colors.white,
                fontWeight: selectedCategory == category.name
                    ? FontWeight.bold
                    : FontWeight.normal),
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
      await widget.db.updateAvailability(menuItem.id!, value);
    } on Exception catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: ZText(content: e.toString()),
        ),
      );
    }
  }

  void changeImage(String name) async {
    List<Asset>? images;

    if (mounted) {
      setState(() {
        images = [];
      });
    }

    List<Asset>? resultList;
    String error;

    try {
      resultList = await MultiImagePicker.pickImages(
        enableCamera: true,
        maxImages: 1,
        materialOptions: MaterialOptions(
          //actionBarTitle: "Action bar",
          allViewTitle: I18n.of(context).pickImages,
          actionBarColor: "#122F41",
          actionBarTitleColor: "#ffffff",
          lightStatusBar: false,
          statusBarColor: '#122F41',
          startInAllView: true,
          selectCircleStrokeColor: "#C49A6C",
          selectionLimitReachedText: I18n.of(context).cantSelect,
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }

    if (!mounted) {
      return;
    }

    if (mounted) {
      setState(() {
        images = resultList;
      });
    }

    if (images != null && images!.length > 0) {
      EasyLoading.show(status: I18n.of(context).loading);
      bool isOnline = await hasConnection();
      if (!isOnline) {
        EasyLoading.dismiss();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: ZText(content: I18n.of(context).noInternet)));
      } else {
        try {
          await widget.db.updateImage(context, images!, name);
          EasyLoading.dismiss();
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: ZText(content: I18n.of(context).photoChanged)));
        } on Exception catch (e) {
          EasyLoading.dismiss();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: ZText(content: e.toString()),
            ),
          );
        }
      }
    }
  }
}
