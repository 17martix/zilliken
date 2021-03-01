import 'package:flutter/material.dart';
import 'package:zilliken/Helpers/SizeConfig.dart';
import 'package:zilliken/Helpers/Styling.dart';

class ZFlatButton extends StatelessWidget {
  final onpressed;
  final String text;
  final bottomVerticalSpace;
  final color;

  ZFlatButton({
    this.onpressed,
    this.text,
    this.bottomVerticalSpace,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          0.0, 0, 0.0, bottomVerticalSpace ?? SizeConfig.diagonal * 2),
      child: FlatButton(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SizeConfig.diagonal * 1.5)),
          child: Text(text,
              style: TextStyle(
                fontSize: SizeConfig.diagonal * 4,
                fontWeight: FontWeight.w300,
                color: color != null ? color : Color(Styling.accentColor),
              )),
          onPressed: onpressed),
    );
  }
}
