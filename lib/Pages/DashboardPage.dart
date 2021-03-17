import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:zilliken/Components/ZAppBar.dart';
import 'package:zilliken/Helpers/SizeConfig.dart';
import 'package:zilliken/Helpers/Styling.dart';
import 'package:zilliken/Helpers/Utils.dart';
import 'package:zilliken/Models/Fields.dart';
import 'package:zilliken/Models/OrderItem.dart';
import 'package:zilliken/Pages/MenuPage.dart';
import 'package:zilliken/Pages/OrdersPage.dart';
import 'package:zilliken/Services/Authentication.dart';
import 'package:zilliken/Services/Database.dart';
import 'package:zilliken/Services/Messaging.dart';
import 'package:zilliken/i18n.dart';

import 'DisabledPage.dart';
import 'SplashPage.dart';

class DashboardPage extends StatefulWidget {
  final Authentication auth;
  final Database db;
  final String userId;
  final String userRole;
  final Messaging messaging;
  final List<OrderItem> clientOrder;
  final int index;

  DashboardPage({
    @required this.auth,
    @required this.userId,
    @required this.userRole,
    @required this.db,
    this.clientOrder,
    @required this.messaging,
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

  @override
  void initState() {
    super.initState();

    if (widget.index != null) {
      setState(() {
        _selectedIndex = widget.index;
      });
    }

    FirebaseFirestore.instance
        .collection(Fields.configuration)
        .doc(Fields.settings)
        .snapshots()
        .listen((DocumentSnapshot documentSnapshot) {
      setState(() {
        enabled = documentSnapshot.data()[Fields.enabled];
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
                appBar: buildAppBar(context, widget.auth, false, true,
                    googleSign, logout, null),
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
                  //animationCurve: Curves.easeInBack,
                  color: Colors.white.withOpacity(0.7),
                  height: 50,
                  //height: SizeConfig.diagonal * 6,
                  //animationDuration: Duration(milliseconds: 800),
                  animationDuration: Duration(milliseconds: 0),
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

  /*void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }*/

  Widget body() {
    /*return Stack(
      children: [
        AnimatedContainer(
          child: MenuPage(
            auth: widget.auth,
            db: widget.db,
            userId: widget.userId,
            userRole: widget.userRole,
            clientOrder: widget.clientOrder,
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
          ),
          curve: Curves.easeInBack,
          duration: Duration(milliseconds: 800),
          transform: Matrix4.translationValues(_xOffset2, 0, 1),
        )
      ],
    );*/
    switch (_selectedIndex) {
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
    }
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

  void googleSign() async {
    String userId = "";

    bool isOnline = await hasConnection();
    if (!isOnline) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(I18n.of(context).noInternet),
        ),
      );
    } else {
      try {
        userId = await widget.auth.signInWithGoogle();
        String token = await widget.messaging.firebaseMessaging.getToken();
        await widget.db.setToken(userId, token);

        if (userId.length > 0 && userId != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SplashPage(
                auth: widget.auth,
                db: widget.db,
                messaging: widget.messaging,
              ),
            ),
          );
        }
      } on Exception catch (e) {
        //print('Error: $e');
        _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }
    }
  }

  void logout() async {
    try {
      await widget.auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => SplashPage(
                  auth: widget.auth,
                  db: widget.db,
                  messaging: widget.messaging,
                )),
      );
    } on Exception catch (e) {
      print('Error: $e');
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }
}
