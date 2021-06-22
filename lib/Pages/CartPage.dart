import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:zilliken/Components/ZAppBar.dart';
import 'package:zilliken/Components/ZCircularProgress.dart';
import 'package:zilliken/Components/ZElevatedButton.dart';
import 'package:zilliken/Components/ZFlatButton.dart';
import 'package:zilliken/Components/ZTextField.dart';
import 'package:zilliken/FirebaseImage/firebase_image.dart';
import 'package:zilliken/Helpers/NumericStepButton.dart';
import 'package:zilliken/Helpers/SizeConfig.dart';
import 'package:zilliken/Helpers/Styling.dart';
import 'package:zilliken/Helpers/Utils.dart';
import 'package:zilliken/Models/Address.dart';
import 'package:zilliken/Models/Fields.dart';
import 'package:zilliken/Models/MenuItem.dart';
import 'package:zilliken/Models/Order.dart';
import 'package:zilliken/Models/OrderItem.dart';
import 'package:zilliken/Models/UserProfile.dart';
import 'package:zilliken/Pages/SingleOrderPage.dart';
import 'package:zilliken/Services/Authentication.dart';
import 'package:zilliken/Services/Database.dart';
import 'package:zilliken/Services/Messaging.dart';
import '../Components/ZText.dart';
import '../i18n.dart';
import 'DashboardPage.dart';
import 'DisabledPage.dart';

class CartPage extends StatefulWidget {
  final List<OrderItem> clientOrder;
  final String userId;
  final String userRole;
  final Database db;
  final Authentication auth;
  final Messaging messaging;

  final kInitialPosition = LatLng(-3.3834389, 29.3616122);

  CartPage({
    required this.auth,
    required this.clientOrder,
    required this.db,
    required this.userId,
    required this.userRole,
    required this.messaging,
  });

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int restaurantOrRoomOrder = 0;
  TextEditingController _choiceController = TextEditingController();
  int tax = 0;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? tableAdress;
  String? phone;
  String? instruction;
  List<OrderItem>? clientOrder;
  List<Address> addressList = [];
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isTaxLoaded = false;
  int enabled = 1;

  var _phoneController = TextEditingController();
  var _instructionController = TextEditingController();

  String? addressName;
  GeoPoint? geoPoint;

  @override
  void initState() {
    super.initState();
    clientOrder = widget.clientOrder;
    widget.db.getTax().then((value) {
      setState(() {
        tax = value;
        _isTaxLoaded = true;
      });
    });

    widget.db.getAddressList(widget.userId).then((value) {
      setState(() {
        addressList = value;
      });
    });

    FirebaseFirestore.instance
        .collection(Fields.configuration)
        .doc(Fields.settings)
        .snapshots()
        .listen((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
      setState(() {
        enabled = documentSnapshot.data()![Fields.enabled];
      });
    });

    FirebaseFirestore.instance
        .collection(Fields.configuration)
        .doc(Fields.settings)
        .snapshots()
        .listen((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
      setState(() {
        enabled = documentSnapshot.data()![Fields.enabled];
      });
    });
  }

  void backFunction() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => DashboardPage(
          db: widget.db,
          auth: widget.auth,
          userId: widget.userId,
          userRole: widget.userRole,
          clientOrder: clientOrder,
          messaging: widget.messaging,
        ),
      ),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardPage(
              db: widget.db,
              auth: widget.auth,
              userId: widget.userId,
              userRole: widget.userRole,
              clientOrder: clientOrder,
              messaging: widget.messaging,
            ),
          ),
          (Route<dynamic> route) => false,
        );
        return false;
      },
      child: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage('assets/Zilliken.jpg'),
          fit: BoxFit.cover,
        )),
        child: Container(
          // color: Color(Styling.primaryBackgroundColor).withOpacity(0.7),
          child: enabled == 0
              ? DisabledPage(
                  auth: widget.auth,
                  db: widget.db,
                  userId: widget.userId,
                  userRole: widget.userRole,
                )
              : Scaffold(
                  backgroundColor: Colors.transparent,
                  key: _scaffoldKey,
                  appBar: buildAppBar(
                    context,
                    widget.auth,
                    true,
                    null,
                    backFunction,
                    null,
                    null,
                  ),
                  body: Stack(
                    children: [
                      body(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget body() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          orderItems(),
          order(),
          bill(),
        ],
      ),
    );
  }

  Widget order() {
    return Card(
      color: Colors.white.withOpacity(0.7),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeConfig.diagonal * 1.5)),
      elevation: 16,
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.diagonal * 1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            showOrder(),
            showChoice(),
            if (restaurantOrRoomOrder == 1 &&
                (addressList == null || addressList.length < 3) &&
                (_choiceController.text != null &&
                    _choiceController.text != '' &&
                    geoPoint != null &&
                    addressName != null &&
                    _phoneController.text != null &&
                    _phoneController.text != ''))
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  showSaveButton(),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget showSaveButton() {
    return FlatButton(
      child: Row(
        children: [
          ZText(content: I18n.of(context).saveAddress),
          SizedBox(width: SizeConfig.diagonal * 1),
          Icon(
            Icons.check,
            size: SizeConfig.diagonal * 2.5,
          ),
        ],
      ),
      onPressed: () async {
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
            Address address = Address(
              geoPoint: geoPoint!,
              addressName: addressName!,
              typedAddress: _choiceController.text,
              phoneNumber: _phoneController.text,
            );

            await widget.db.addAddress(widget.userId, address);

            setState(() {
              addressList.add(address);
            });
            EasyLoading.dismiss();
          } on Exception catch (e) {
            //print('Error: $e');
            EasyLoading.dismiss();
            setState(() {
              formKey.currentState!.reset();
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: ZText(content: e.toString()),
              ),
            );
          }
        }
      },
    );
  }

  Widget showSavedAddresses() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: addressList.map((address) {
            return addressItem(address);
          }).toList()),
    );
  }

  Widget addressItem(Address address) {
    return Padding(
      padding: EdgeInsets.only(right: SizeConfig.diagonal * 1),
      child: ZTextButton(
        onpressed: () {
          setState(() {
            _choiceController.text = address.typedAddress;
            addressName = address.addressName;
            geoPoint = address.geoPoint;
            _phoneController.text = address.phoneNumber;
          });
        },
        color: Color(Styling.primaryColor),
        child: Row(
          children: [
            ZText(
                content: address.addressName,
                color: Color(Styling.primaryColor),
                fontSize: SizeConfig.diagonal * 1.5),
            SizedBox(width: SizeConfig.diagonal * 1),
            PopupMenuButton(
              color: Color(Styling.primaryBackgroundColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SizeConfig.diagonal * 1.5),
              ),
              offset: Offset(-125, 40),
              itemBuilder: (context) => [
                PopupMenuItem(
                    child: ZText(content: I18n.of(context).delete), value: 0),
              ],
              onSelected: (value) async {
                switch (value) {
                  case 0:
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
                        await widget.db
                            .deleteAddress(widget.userId, address.id!);
                        setState(() {
                          addressList.removeWhere(
                              (element) => element.id == address.id);
                        });
                        EasyLoading.dismiss();
                      } on Exception catch (e) {
                        //print('Error: $e');
                        EasyLoading.dismiss();
                        setState(() {
                          formKey.currentState!.reset();
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: ZText(content: e.toString()),
                          ),
                        );
                      }
                    }
                    break;
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget orderItems() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.all(SizeConfig.diagonal * 1),
          child: ZText(
            content: I18n.of(context).orders,
            textAlign: TextAlign.center,
            color: Color(Styling.iconColor),
            fontSize: SizeConfig.diagonal * 1.5,
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(
              horizontal: SizeConfig.diagonal * 2,
              vertical: SizeConfig.diagonal * 1),
          width: double.infinity,
          height: 1,
          color: Color(Styling.primaryColor),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: clientOrder!.map((orderItem) {
            return item(orderItem.menuItem);
          }).toList(),
        ),
      ],
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
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SizeConfig.diagonal * 1.5),
              image: DecorationImage(
                image: //AssetImage("assets/${menu.imageName}"),
                    FirebaseImage(
                  '${widget.db.firebaseBucket}/images/${menu.imageName}',
                  cacheRefreshStrategy: CacheRefreshStrategy.NEVER,
                ),
                fit: BoxFit.cover,
              ),
            ),
            height: SizeConfig.diagonal * 10,
            width: SizeConfig.diagonal * 10,
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(SizeConfig.diagonal * 1),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ZText(
                    content: menu.name,
                    textAlign: TextAlign.left,
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
                          color: Color(Styling.textColor),
                          fontWeight: FontWeight.normal,
                          fontSize: SizeConfig.diagonal * 1.5,
                        ),
                      ),
                      isAlreadyOnTheOrder(clientOrder!, menu.id!)
                          ? Expanded(
                              flex: 1,
                              child: NumericStepButton(
                                counter:
                                    findOrderItem(clientOrder!, menu.id!).count,
                                maxValue: 20,
                                onChanged: (value) {
                                  OrderItem orderItem =
                                      findOrderItem(clientOrder!, menu.id!);
                                  if (value == 0) {
                                    setState(() {
                                      clientOrder!.remove(orderItem);
                                    });
                                    //order.remove(orderItem);
                                  } else {
                                    setState(() {
                                      orderItem.count = value;
                                    });
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
                                      setState(() {
                                        clientOrder!.add(OrderItem(
                                          menuItem: menu,
                                          count: 1,
                                        ));
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Color(Styling.accentColor),
                                        borderRadius: BorderRadius.circular(
                                            SizeConfig.diagonal * 3),
                                        border: Border.all(
                                          color: Color(Styling.accentColor),
                                        ),
                                      ),
                                      margin: EdgeInsets.all(
                                          SizeConfig.diagonal * 1),
                                      padding: EdgeInsets.all(
                                          SizeConfig.diagonal * 1),
                                      child: Row(
                                        children: [
                                          ZText(
                                              content: I18n.of(context).addItem,
                                              color: Colors.white,
                                              fontSize:
                                                  SizeConfig.diagonal * 1.5),
                                          SizedBox(
                                              width: SizeConfig.diagonal * 0.5),
                                          Icon(
                                            Icons.add,
                                            size: SizeConfig.diagonal * 1.5,
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
        ],
      ),
    );
  }

  Widget showOrder() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.all(SizeConfig.diagonal * 1),
          child: ZText(
              content: I18n.of(context).orderKind,
              textAlign: TextAlign.center,
              color: Color(Styling.iconColor),
              fontSize: SizeConfig.diagonal * 1.5),
        ),
        Container(
          margin: EdgeInsets.all(SizeConfig.diagonal * 1),
          width: double.infinity,
          height: 1,
          color: Color(Styling.primaryColor),
        ),
      ],
    );
  }

  void restaurantRoomChange(int? value) {
    setState(() {
      restaurantOrRoomOrder = value!;
      FocusScope.of(context).unfocus();
      _choiceController.clear();
      _phoneController.clear();
      _instructionController.clear();
      formKey.currentState!.reset();
    });
  }

  Widget showChoice() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Radio(
                  value: 0,
                  groupValue: restaurantOrRoomOrder,
                  onChanged: restaurantRoomChange),
              ZText(
                content: I18n.of(context).restaurantOrder,
                fontSize: SizeConfig.diagonal * 1.5,
              ),
              Radio(
                value: 1,
                groupValue: restaurantOrRoomOrder,
                onChanged: restaurantRoomChange,
              ),
              ZText(
                content: I18n.of(context).livrdomicile,
                fontSize: SizeConfig.diagonal * 1.5,
              ),
            ],
          ),
        ),
        if (restaurantOrRoomOrder == 1 &&
            (addressList != null && addressList.length > 0))
          showSavedAddresses(),
        Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (restaurantOrRoomOrder == 1)
                SizedBox(
                  width: double.infinity,
                  child: ZElevatedButton(
                    topPadding: SizeConfig.diagonal * 1,
                    bottomPadding: SizeConfig.diagonal * 1,
                    rightPadding: SizeConfig.diagonal * 1,
                    leftPadding: SizeConfig.diagonal * 1,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: SizeConfig.diagonal * 0.5),
                            child: Icon(
                              Icons.location_on,
                              color: Color(Styling.primaryColor),
                            ),
                          ),
                          ZText(
                            content:
                                addressName ?? I18n.of(context).selectLocation,
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            color: Color(Styling.primaryBackgroundColor),
                            fontSize: SizeConfig.diagonal * 1.5,
                          ),
                        ]),
                    onpressed: selectLocation,
                  ),
                ),
              ZTextField(
                controller: _choiceController,
                onSaved: (newValue) => tableAdress = newValue,
                validator: (value) => value == null || value.isEmpty
                    ? I18n.of(context).requit
                    : null,
                keyboardType: restaurantOrRoomOrder == 0
                    ? TextInputType.number
                    : TextInputType.text,
                label: restaurantOrRoomOrder == 0
                    ? I18n.of(context).ntable
                    : I18n.of(context).addr,
                icon: restaurantOrRoomOrder == 0
                    ? Icons.restaurant_menu
                    : Icons.shopping_cart,
              ),
              if (restaurantOrRoomOrder == 1)
                ZTextField(
                  onSaved: (newValue) => phone = newValue,
                  controller: _phoneController,
                  validator: (value) => value == null || value.isEmpty
                      ? I18n.of(context).requit
                      : null,
                  keyboardType: TextInputType.phone,
                  label: I18n.of(context).fone,
                  icon: Icons.phone_android,
                ),
              ZTextField(
                onSaved: (newValue) => instruction = newValue,
                label: I18n.of(context).instruction,
                controller: _instructionController,
                maxLines: 5,
                icon: Icons.info,
                keyboardType: TextInputType.text,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void selectLocation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlacePicker(
          apiKey: getMapsKey()!, // Put YOUR OWN KEY here.
          onPlacePicked: (result) {
            setState(() {
              addressName = result.formattedAddress;
              log("address is lat ${result.geometry!.location.lat} lng ${result.geometry!.location.lng}");
              geoPoint = GeoPoint(
                  result.geometry!.location.lat, result.geometry!.location.lng);
            });
            Navigator.of(context).pop();
          },
          initialPosition: widget.kInitialPosition,
          useCurrentLocation: true,
        ),
      ),
    );
  }

  Widget bill() {
    return _isTaxLoaded
        ? Card(
            color: Colors.white.withOpacity(0.7),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SizeConfig.diagonal * 1.5)),
            elevation: 16,
            child: Padding(
              padding: EdgeInsets.all(SizeConfig.diagonal * 1),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.all(SizeConfig.diagonal * 1),
                    child: ZText(
                      content: I18n.of(context).bil,
                      textAlign: TextAlign.center,
                      fontSize: SizeConfig.diagonal * 1.5,
                      color: Color(Styling.textColor),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(SizeConfig.diagonal * 1),
                    width: double.infinity,
                    height: 1,
                    color: Color(Styling.primaryColor),
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(SizeConfig.diagonal * 1),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ZText(
                              content: I18n.of(context).total,
                              textAlign: TextAlign.center,
                              fontSize: SizeConfig.diagonal * 1.5,
                              color: Color(Styling.textColor),
                              fontWeight: FontWeight.bold,
                            ),
                            ZText(
                              content: priceItemsTotal(context, clientOrder!),
                              fontSize: SizeConfig.diagonal * 1.5,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(SizeConfig.diagonal * 1),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ZText(
                              content: I18n.of(context).taxCharge,
                              textAlign: TextAlign.center,
                              color: Color(Styling.textColor),
                              fontSize: SizeConfig.diagonal * 1.5,
                              fontWeight: FontWeight.bold,
                            ),
                            ZText(
                              content: appliedTax(context, clientOrder!, tax),
                              fontSize: SizeConfig.diagonal * 1.5,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(SizeConfig.diagonal * 1),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ZText(
                              content: I18n.of(context).gtotal,
                              textAlign: TextAlign.center,
                              color: Color(Styling.textColor),
                              fontSize: SizeConfig.diagonal * 1.5,
                              fontWeight: FontWeight.bold,
                            ),
                            ZText(
                              content: grandTotal(context, clientOrder!, tax),
                              fontSize: SizeConfig.diagonal * 1.5,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  ZElevatedButton(
                    onpressed: sendToFireBase,
                    //color: Color(Styling.accentColor),
                    leftPadding: 0.0,
                    rightPadding: 0.0,
                    child: ZText(
                      content: I18n.of(context).ordPlace,
                      color: Color(Styling.primaryBackgroundColor),
                      fontSize: SizeConfig.diagonal * 1.5,
                    ),
                  ),
                ],
              ),
            ),
          )
        : ZCircularProgress(true);
  }

  bool validate() {
    final form = formKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<void> sendToFireBase() async {
    if (validate()) {
      if (restaurantOrRoomOrder == 1 &&
          (addressName == null || addressName == '')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: ZText(content: I18n.of(context).enterLocation),
          ),
        );
      } else {
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
            UserProfile? userProfile =
                await widget.db.getUserProfile(widget.userId);
            Order order = Order(
              clientOrder: clientOrder!,
              orderLocation: restaurantOrRoomOrder,
              tableAdress: tableAdress!,
              phoneNumber: phone,
              instructions: instruction,
              grandTotal: grandTotalNumber(context, clientOrder!, tax),
              orderDate: null,
              confirmedDate: null,
              servedDate: null,
              status: 1,
              userId: widget.userId,
              userRole: widget.userRole,
              userName: userProfile!.name,
              taxPercentage: tax,
              total: priceItemsTotalNumber(context, clientOrder!),
              addressName: addressName,
              geoPoint: geoPoint,
              currentPoint: GeoPoint(-3.3834389, 29.3616122),
            );
            await widget.db.placeOrder(order);

            EasyLoading.dismiss();

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SingleOrderPage(
                  auth: widget.auth,
                  db: widget.db,
                  userId: widget.userId,
                  userRole: widget.userRole,
                  orderId: order.id!,
                  clientOrder: order,
                  messaging: widget.messaging,
                ),
              ),
            );
          } on Exception catch (e) {
            //print('Error: $e');
            EasyLoading.dismiss();
            setState(() {
              formKey.currentState!.reset();
            });

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
}
