import 'package:flutter/material.dart';
import 'package:zilliken/Helpers/SizeConfig.dart';
import 'package:zilliken/Helpers/Styling.dart';

class ZTextButton extends StatelessWidget {
  final onpressed;
  final bottomVerticalSpace;
  final color;
  final child;

  ZTextButton({
    this.onpressed,
    required this.child,
    this.bottomVerticalSpace,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          0.0, 0, 0.0, bottomVerticalSpace ?? SizeConfig.diagonal * 2),
      child: TextButton(child: child, onPressed: onpressed),
    );
  }
}
