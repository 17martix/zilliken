import 'package:flutter/material.dart';
import 'package:zilliken/Components/ZAppBar.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:zilliken/Helpers/SizeConfig.dart';
import 'package:zilliken/Services/Database.dart';
import 'package:zilliken/Services/Messaging.dart';
import 'package:zilliken/Pages/StatPage.dart';
import 'package:zilliken/Pages/StockPage.dart';
import 'package:zilliken/Pages/UserPage.dart';
import 'package:zilliken/Pages/AdminPage.dart';
import 'package:zilliken/Services/Authentication.dart';

class AdminPage extends StatefulWidget {
  final Authentication auth;
  final Database db;
  final Messaging messaging;
  final String userId;
  final String userRole;

  AdminPage({
    @required this.auth,
    @required this.db,
    @required this.userId,
    @required this.userRole,
    @required this.messaging,
  });

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _pageState = 0;
  double _xoffset1 = 0;
  double _xoffset2 = 0;
  double _xoffset3 = 0;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    _xoffset1 = SizeConfig.safeBlockHorizontal * 0;

    switch (_pageState) {
      case 0:
        setState(() {
          _xoffset1 = SizeConfig.safeBlockHorizontal * 0;
          _xoffset2 = SizeConfig.safeBlockHorizontal * 100;
          _xoffset3 = SizeConfig.safeBlockHorizontal * 100;
        });
        break;
      case 1:
        setState(() {
          _xoffset1 = SizeConfig.safeBlockHorizontal * -100;
          _xoffset2 = SizeConfig.safeBlockHorizontal * 0;
          _xoffset3 = SizeConfig.safeBlockHorizontal * 100;
        });
        break;
      case 2:
        setState(() {
          _xoffset1 = SizeConfig.safeBlockHorizontal * -100;
          _xoffset2 = SizeConfig.safeBlockHorizontal * -100;
          _xoffset3 = SizeConfig.safeBlockHorizontal * 0;
        });
    }

    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
        image: AssetImage('assets/Zilliken.jpg'),
        fit: BoxFit.cover,
      )),
      child: Scaffold(
        appBar: buildAppBar(
          context,
          widget.auth,
          true,
          null,
          null,
          null,
          null,
        ),
        body: body(),
        backgroundColor: Colors.transparent,
        bottomNavigationBar: CurvedNavigationBar(
          animationCurve: Curves.easeInBack,
          color: Colors.white.withOpacity(0.7),
          height: 54,
          backgroundColor: Colors.transparent,
          animationDuration: Duration(milliseconds: 800),
          index: _pageState,
          items: <Widget>[
            Icon(Icons.access_alarms),
            Icon(Icons.satellite),
            Icon(Icons.supervised_user_circle),
          ],
          onTap: (index) {
            setState(() {
              _pageState = index;
            });
          },
        ),
      ),
    );
  }

  Widget body() {
    return Stack(
      children: [
        AnimatedContainer(
          child: StatPage(
            auth: widget.auth,
            db: widget.db,
            userId: widget.userId,
            userRole: widget.userRole,
            data: [],
          ),
          duration: Duration(milliseconds: 800),
          curve: Curves.easeInBack,
          transform: Matrix4.translationValues(_xoffset1, 0, 1),
        ),
        AnimatedContainer(
          child: StockPage(
            auth: widget.auth,
            db: widget.db,
            messaging: widget.messaging,
            userId: widget.userId,
            userRole: widget.userRole,
          ),
          duration: Duration(milliseconds: 800),
          curve: Curves.easeInBack,
          transform: Matrix4.translationValues(_xoffset2, 0, 1),
        ),
        AnimatedContainer(
          child: UserPage(),
          duration: Duration(milliseconds: 800),
          curve: Curves.easeInBack,
          transform: Matrix4.translationValues(_xoffset3, 0, 1),
        ),
      ],
    );
  }
}
