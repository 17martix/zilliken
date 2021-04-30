import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zilliken/Helpers/SizeConfig.dart';
import 'package:zilliken/Helpers/Styling.dart';
import 'package:zilliken/Services/Authentication.dart';

AppBar buildAppBar(
  context,
  Authentication auth,
  bool isBackAllowed,
  logout,
  backFunction,
  print,
  admin,
) {
  return AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    leading: isBackAllowed
        ? IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Color(Styling.iconColor),
              size: SizeConfig.diagonal * 3,
            ),
            onPressed: backFunction ??
                () {
                  Navigator.pop(context);
                })
        : null,
    title: Center(
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.headline6!.copyWith(
                fontWeight: FontWeight.bold,
              ),
          children: <TextSpan>[
            TextSpan(
              text: 'Z',
              style: TextStyle(
                color: Color(Styling.primaryColor),
                fontSize: SizeConfig.diagonal * 2,
              ),
            ),
            TextSpan(
              text: 'illiken',
              style: TextStyle(
                color: Color(Styling.accentColor),
                fontSize: SizeConfig.diagonal * 2,
              ),
            ),
          ],
        ),
      ),
    ),
    actions: [
      logout == null ? Text('') : logoutButton(logout),
      if (print != null) printButton(print),
      if (admin != null) adminButton(admin),
    ],
  );
}

Widget logoutButton(logout) {
  return IconButton(
    icon: Icon(
      FontAwesomeIcons.powerOff,
      color: Color(Styling.iconColor),
      size: SizeConfig.diagonal * 2.5,
    ),
    onPressed: logout,
  );
}

Widget adminButton(admin) {
  return IconButton(
    icon: Icon(
      Icons.dashboard,
      color: Color(Styling.iconColor),
      size: SizeConfig.diagonal * 2.5,
    ),
    onPressed: admin,
  );
}

Widget printButton(print) {
  return IconButton(
    icon: Icon(
      Icons.print,
      color: Color(Styling.iconColor),
      size: SizeConfig.diagonal * 2.5,
    ),
    onPressed: print,
  );
}
