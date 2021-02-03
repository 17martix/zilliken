import 'package:flutter/material.dart';
import 'package:zilliken/Helpers/Styling.dart';

AppBar buildAppBar() {
  return AppBar(
    title: Center(
      child: RichText(
        text: TextSpan(
          text: 'Z',
          style: TextStyle(
            color: Color(
              Styling.primaryColor,
            ),
          ),
          children: <TextSpan>[
            TextSpan(
              text: 'illiken',
              style: TextStyle(
                color: Color(
                  Styling.textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
