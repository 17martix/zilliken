import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:zilliken/Components/ZAppBar.dart';
import 'package:zilliken/Components/ZElevatedButton.dart';
import 'package:zilliken/Helpers/SizeConfig.dart';
import 'package:zilliken/Helpers/Styling.dart';
import 'package:zilliken/Helpers/Utils.dart';
import 'package:zilliken/Models/Call.dart';
import 'package:zilliken/Models/Fields.dart';
import 'package:zilliken/Models/OrderItem.dart';
import 'package:zilliken/Pages/AdminPage.dart';
import 'package:zilliken/Pages/LoginPage.dart';
import 'package:zilliken/Pages/MenuPage.dart';
import 'package:zilliken/Pages/OrdersPage.dart';
import 'package:zilliken/Services/Authentication.dart';
import 'package:zilliken/Services/Database.dart';
import 'package:zilliken/Services/Messaging.dart';
import 'package:zilliken/i18n.dart';

import '../Components/ZText.dart';
import 'DisabledPage.dart';

class DashboardPage extends StatefulWidget {
  final Authentication auth;
  final Database db;
  final String userId;
  final String userRole;
  final Messaging messaging;
  final List<OrderItem>? clientOrder;
  final int? index;

  DashboardPage({
    required this.auth,
    required this.userId,
    required this.userRole,
    required this.db,
    this.clientOrder,
    required this.messaging,
    this.index,
  });

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int enabled = 1;
  double _xOffset1 = 0;
  double _xOffset2 = 0;
  var calls = FirebaseFirestore.instance
      .collection(Fields.calls)
      .orderBy(Fields.createdAt, descending: true)
      .limit(3);
  bool isActive = true;

  BuildContext? dialogContext;
  bool isStarting = true;

  @override
  void initState() {
    super.initState();

    if (widget.index != null) {
      setState(() {
        _selectedIndex = widget.index!;
      });
    }

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
        .collection(Fields.users)
        .doc(widget.userId)
        .snapshots()
        .listen((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
      setState(() {
        isActive = documentSnapshot.data()![Fields.isActive];
      });
    });

    widget.messaging.listenMessage(
      context,
      widget.auth,
      widget.db,
      widget.userId,
      widget.userRole,
      widget.messaging,
    );

    if (widget.userRole == Fields.chef ||
        widget.userRole == Fields.chefBoissons ||
        widget.userRole == Fields.chefCuisine) {
      calls.snapshots().listen((snapshot) {
        Call call = Call.buildObject(snapshot.docs[0]);
        if (call.hasCalled && isStarting == false) {
          callDialog(call);
        } else if (isStarting == true) {
          isStarting = false;
        } else {
          Navigator.pop(dialogContext!);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    _xOffset2 = SizeConfig.safeBlockHorizontal * 0;
    switch (_selectedIndex) {
      case 0:
        setState(() {
          _xOffset1 = SizeConfig.safeBlockHorizontal * 0;
          _xOffset2 = SizeConfig.safeBlockHorizontal * 100;
        });
        break;
      case 1:
        setState(() {
          _xOffset1 = SizeConfig.safeBlockHorizontal * -100;
          _xOffset2 = SizeConfig.safeBlockHorizontal * 0;
        });
        break;
    }

    return enabled == 0
        ? DisabledPage(
            auth: widget.auth,
            db: widget.db,
            userId: widget.userId,
            userRole: widget.userRole,
          )
        : isActive == false
            ? DisabledPage(
                auth: widget.auth,
                db: widget.db,
                userId: widget.userId,
                userRole: widget.userRole,
              )
            : Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                  image: AssetImage('assets/Zilliken.jpg'),
                  fit: BoxFit.cover,
                )),
                child: Container(
                  color: Color(Styling.primaryBackgroundColor).withOpacity(0.7),
                  child: Scaffold(
                    key: _scaffoldKey,
                    backgroundColor: Colors.transparent,
                    appBar: buildAppBar(
                      context,
                      widget.auth,
                      false,
                      logout,
                      null,
                      null,
                      widget.userRole != Fields.client ? admin : null,
                    ),
                    body: body(),
                    /*bottomNavigationBar: BottomNavigationBar(
                  items: <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      icon: Icon(Icons.restaurant_menu_outlined),
                      label: I18n.of(context).menu,
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.shopping_bag),
                      label: I18n.of(context).orders,
                    ),
                  ],
                  currentIndex: _selectedIndex,
                  selectedItemColor: Color(
                    Styling.primaryColor,
                  ),
                  onTap: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                ),*/
                    bottomNavigationBar: CurvedNavigationBar(
                      animationCurve: Curves.easeInBack,
                      color: Colors.white.withOpacity(0.7),
                      height: 50,
                      //height: SizeConfig.diagonal * 6,
                      animationDuration: Duration(milliseconds: 800),

                      backgroundColor: Colors.transparent,
                      index: _selectedIndex,
                      items: <Widget>[
                        Icon(Icons.restaurant_menu_outlined),
                        Icon(Icons.shopping_bag),
                      ],
                      /*currentIndex: _selectedIndex,
                  selectedItemColor: Color(
                    Styling.primaryColor,
                  ),*/
                      onTap: (index) {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                    ),
                  ),
                ),
              );
  }

  /*Widget callsStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: calls.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.data == null)
          return Center(
            child: Text(""),
          );

        Call call = Call();
        call.buildObject(snapshot.data.docs[0]);
        if(call.hasCalled){
          return WidgetsBinding.instance.addPostFrameCallback((_){
    showDialog(
      context: context, 
      ...
    );
  });
        }     
        
      },
    );
  }

  Widget float() {
    return Align(
      alignment: Alignment.bottomRight,
      child: FloatingActionButton(onPressed: () {
        call();
      }),
    );
  }*/

  void callDialog(Call call) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      transitionDuration: Duration(milliseconds: 300),
      transitionBuilder: (context, a1, a2, widget) {
        dialogContext = context;
        return Transform.scale(
          scale: a1.value,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SizeConfig.diagonal * 1.5),
            ),
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ZText(
                    content:
                        "${I18n.of(context).tableNumber} ${call.order.tableAdress} ${I18n.of(context).called}",
                    fontSize: SizeConfig.diagonal * 2,
                  ),
                  Icon(
                    Icons.warning,
                    size: SizeConfig.diagonal * 15,
                    color: Colors.red,
                  ),
                  ZElevatedButton(
                    onpressed: () => updateCall(call),
                    topPadding: 0.0,
                    bottomPadding: 0.0,
                    child: ZText(
                      content:
                          "${I18n.of(context).accept} ${I18n.of(context).tableNumber} ${call.order.tableAdress}",
                    ),
                  )
                ],
              ),
              height: SizeConfig.diagonal * 45,
            ),
          ),
        );
      },
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return Container();
      },
    );
  }

  Future<void> updateCall(Call call) async {
    EasyLoading.show(status: I18n.of(context).loading);
    bool isOnline = await hasConnection();
    if (!isOnline) {
      EasyLoading.dismiss();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: ZText(content: I18n.of(context).noInternet),
      ));
    } else {
      try {
        await widget.db.updateCall(call, false);
        EasyLoading.dismiss();
        // Navigator.of(context).pop();
      } on Exception catch (e) {
        EasyLoading.dismiss();

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: ZText(content: e.toString()),
        ));
      }
    }
  }

  /*void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }*/

  Widget body() {
    return Stack(
      children: [
        AnimatedContainer(
          child: MenuPage(
            auth: widget.auth,
            db: widget.db,
            userId: widget.userId,
            userRole: widget.userRole,
            clientOrder: widget.clientOrder,
            messaging: widget.messaging,
          ),
          curve: Curves.easeInBack,
          duration: Duration(milliseconds: 800),
          transform: Matrix4.translationValues(_xOffset1, 0, 1),
        ),
        AnimatedContainer(
          child: OrdersPage(
            auth: widget.auth,
            db: widget.db,
            userId: widget.userId,
            userRole: widget.userRole,
            messaging: widget.messaging,
          ),
          curve: Curves.easeInBack,
          duration: Duration(milliseconds: 800),
          transform: Matrix4.translationValues(_xOffset2, 0, 1),
        )
      ],
    );
    /* switch (_selectedIndex) {
      case 0:
        return MenuPage(
          auth: widget.auth,
          db: widget.db,
          userId: widget.userId,
          userRole: widget.userRole,
          clientOrder: widget.clientOrder,
          messaging: widget.messaging,
        );
        break;
      case 1:
        return OrdersPage(
          auth: widget.auth,
          db: widget.db,
          userId: widget.userId,
          userRole: widget.userRole,
          messaging: widget.messaging,
        );
        break;
      default:
        return MenuPage(
          auth: widget.auth,
          db: widget.db,
          userId: widget.userId,
          userRole: widget.userRole,
          clientOrder: widget.clientOrder,
          messaging: widget.messaging,
        );
        break;
    }*/
  }

  /*Route _fromMenuToOrders() {
    return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => OrdersPage(
              auth: widget.auth,
              db: widget.db,
              userId: widget.userId,
              userRole: widget.userRole,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return child;
        });
  }

  Route _fromOrdersToMenu() {
    return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => OrdersPage(
              auth: widget.auth,
              db: widget.db,
              userId: widget.userId,
              userRole: widget.userRole,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return child;
        });
  }*/

  void admin() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AdminPage(
                auth: widget.auth,
                db: widget.db,
                messaging: widget.messaging,
                userId: widget.userId,
                userRole: widget.userRole,
              )),
    );
  }

  void logout() async {
    try {
      await widget.auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => LoginPage(
                  auth: widget.auth,
                  db: widget.db,
                  messaging: widget.messaging,
                )),
      );
    } on Exception catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: ZText(content: e.toString()),
        ),
      );
    }
  }
}
