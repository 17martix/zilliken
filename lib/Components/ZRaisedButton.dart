import 'package:zilliken/Helpers/SizeConfig.dart';
import 'package:zilliken/Helpers/Styling.dart';
import 'package:flutter/material.dart';

class ZRaisedButton extends StatelessWidget {
  final onpressed;
  final textIcon;
  final bottomPadding;
  final topPadding;
  final leftPadding;
  final rightPadding;
  final color;

  ZRaisedButton({
    this.onpressed,
    this.textIcon,
    this.bottomPadding,
    this.leftPadding,
    this.rightPadding,
    this.topPadding,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return new Padding(
        padding: EdgeInsets.fromLTRB(
            leftPadding ?? SizeConfig.diagonal * 2,
            topPadding ?? SizeConfig.diagonal * 5,
            rightPadding ?? SizeConfig.diagonal * 2,
            bottomPadding ?? SizeConfig.diagonal * 5),
        child: SizedBox(
          height: SizeConfig.diagonal * 6,
          width: double.infinity,
          child: new RaisedButton(
            elevation: 5.0,
            color: color != null ? color : Color(Styling.accentColor),
            child: textIcon,
            onPressed: onpressed,
          ),
        ));
  }
}
