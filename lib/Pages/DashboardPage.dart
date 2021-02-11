import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zilliken/Components/ZAppBar.dart';
import 'package:zilliken/Helpers/ConnectionStatus.dart';
import 'package:zilliken/Helpers/Styling.dart';
import 'package:zilliken/Models/Fields.dart';
import 'package:zilliken/Pages/MenuPage.dart';
import 'package:zilliken/Pages/OrdersPage.dart';
import 'package:zilliken/Services/Authentication.dart';
import 'package:zilliken/Services/Database.dart';
import 'package:zilliken/i18n.dart';

import 'DisabledPage.dart';
import 'SplashPage.dart';

class DashboardPage extends StatefulWidget {
  final Authentication auth;
  final Database db;
  final String userId;
  final String userRole;

  DashboardPage({
    this.auth,
    this.userId,
    this.userRole,
    this.db,
  });

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  StreamSubscription _connectionChangeStream;
  bool isOffline = false;

  int _selectedIndex = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int enabled = 1;

  @override
  void initState() {
    super.initState();
    ConnectionStatus connectionStatus = ConnectionStatus.getInstance();
    _connectionChangeStream =
        connectionStatus.connectionChange.listen(connectionChanged);

    FirebaseFirestore.instance
        .collection(Fields.configuration)
        .doc(Fields.settings)
        .snapshots()
        .listen((DocumentSnapshot documentSnapshot) {
      setState(() {
        enabled = documentSnapshot.data()[Fields.enabled];
      });
    });
  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isOffline = !hasConnection;
    });
  }

  @override
  Widget build(BuildContext context) {
    return enabled == 0
        ? DisabledPage(
            auth: widget.auth,
            db: widget.db,
            userId: widget.userId,
            userRole: widget.userRole,
          )
        : Scaffold(
            key: _scaffoldKey,
            appBar: buildAppBar(
                context, widget.auth, false, true, googleSign, logout),
            body: body(),
            bottomNavigationBar: BottomNavigationBar(
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
              onTap: _onItemTapped,
            ),
          );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget body() {
    switch (_selectedIndex) {
      case 0:
        return MenuPage(
          auth: widget.auth,
          db: widget.db,
          userId: widget.userId,
          userRole: widget.userRole,
        );
        break;
      case 1:
        return OrdersPage(
          auth: widget.auth,
          db: widget.db,
          userId: widget.userId,
          userRole: widget.userRole,
        );
        break;
      default:
        return MenuPage(
          auth: widget.auth,
          db: widget.db,
          userId: widget.userId,
          userRole: widget.userRole,
        );
        break;
    }
  }

  void googleSign() async {
    String userId = "";

    if (isOffline) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(I18n.of(context).noInternet),
        ),
      );
    } else {
      try {
        userId = await widget.auth.signInWithGoogle();

        if (userId.length > 0 && userId != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SplashPage(
                auth: widget.auth,
                db: widget.db,
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
