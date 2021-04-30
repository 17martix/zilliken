import 'package:flutter/material.dart';
import 'package:zilliken/Helpers/SizeConfig.dart';
import 'package:zilliken/Helpers/Styling.dart';

class ZText extends StatelessWidget {
  final String content;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final TextOverflow? overflow;
  final FontStyle? fontStyle;
  final TextAlign? textAlign;
  final TextDecoration? decoration;
  final int? maxLines;

  ZText({
    required this.content,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.overflow,
    this.fontStyle,
    this.textAlign,
    this.decoration,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Text(
      content,
      overflow: overflow ?? TextOverflow.ellipsis,
      textAlign: textAlign ?? TextAlign.start,
      maxLines: maxLines ?? null,
      style: TextStyle(
        decoration: decoration ?? null,
        color: color ?? Color(Styling.textColor),
        fontSize: fontSize ?? SizeConfig.diagonal * 1.5,
        fontWeight: fontWeight ?? FontWeight.normal,
        fontStyle: fontStyle ?? FontStyle.normal,
      ),
    );
  }
}
