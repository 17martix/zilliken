import 'package:zilliken/Helpers/SizeConfig.dart';
import 'package:zilliken/Helpers/Styling.dart';
import 'package:flutter/material.dart';

import '../Helpers/Styling.dart';

class ZElevatedButton extends StatelessWidget {
  final onpressed;
  final child;
  final bottomPadding;
  final topPadding;
  final leftPadding;
  final rightPadding;
  final color;

  ZElevatedButton({
  required  this.onpressed,
   required this.child,
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
            leftPadding ?? SizeConfig.diagonal * 1,
            topPadding ?? SizeConfig.diagonal * 1,
            rightPadding ?? SizeConfig.diagonal * 1,
            bottomPadding ?? SizeConfig.diagonal * 5),
        child: SizedBox(
          height: SizeConfig.diagonal * 6,
          width: double.infinity,
          child: new ElevatedButton(
            style: ElevatedButton.styleFrom(primary:color != null ? color : Color(Styling.primaryColor),elevation: 8.0,shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(35),
            ),),
          
            child: child,
            onPressed: onpressed,
          ),
        ));
  }
}
