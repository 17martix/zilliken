import 'package:flutter/material.dart';
import 'package:zilliken/Helpers/Styling.dart';

AppBar buildAppBar(context) {
  return AppBar(
    title: Center(
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.headline6.copyWith(
                fontWeight: FontWeight.bold,
              ),
          children: <TextSpan>[
            TextSpan(
              text: 'Z',
              style: TextStyle(color: Color(Styling.primaryColor)),
            ),
            TextSpan(
              text: 'illiken',
              style: TextStyle(color: Color(Styling.accentColor)),
            ),
          ],
        ),
      ),
    ),
  );
}
