import 'package:flutter/material.dart';

import '../Helpers/SizeConfig.dart';
import '../Helpers/Styling.dart';

class ZTextField extends StatelessWidget {
  final FormFieldSetter<String>? onSaved;
  final IconData? icon;
  final String? hint;
  final bool obsecure;
  final String? label;
  final keyboardType;
  final inputFormatters;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final int? maxLines;
  final suffix;
  final height;
  final enabled;
  final outsideSuffix;
  final elevation;
  final outsidePrefix;
  final fontSize;
  final letterSpacing;
  final focusNode;
  final textInputAction;
  final onFieldSubmitted;
  final onEditingComplete;
  final autofocus;
  final onChanged;
  final textAlign;

  ZTextField({
    this.elevation,
    this.icon,
    this.hint,
    this.obsecure = false,
    this.validator,
    this.onSaved,
    this.label,
    this.inputFormatters,
    this.keyboardType,
    this.controller,
    this.maxLines,
    this.suffix,
    this.height,
    this.enabled,
    this.outsideSuffix,
    this.outsidePrefix,
    this.fontSize,
    this.letterSpacing,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
    this.onEditingComplete,
    this.autofocus,
    this.onChanged,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation ?? 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.diagonal * 0.5,
            vertical: SizeConfig.diagonal * 0.5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (outsidePrefix != null) outsidePrefix,
            SizedBox(
              width: SizeConfig.diagonal * 1,
            ),
            Expanded(
              child: TextFormField(
                textAlign: textAlign ?? TextAlign.start,
                enabled: enabled ?? true,
                textInputAction: textInputAction ?? TextInputAction.next,
                maxLines: maxLines ?? 1,
                onSaved: onSaved,
                controller: controller,
                onFieldSubmitted: onFieldSubmitted ?? null,
                onEditingComplete: onEditingComplete ?? null,
                onChanged: onChanged,
                focusNode: focusNode,
                minLines: 1,
                validator: validator,
                autofocus: autofocus ?? false,
                obscureText: obsecure,
                keyboardType: keyboardType,
                inputFormatters: inputFormatters,
                cursorColor: Color(Styling.primaryColor),
                style: TextStyle(
                  fontSize: fontSize ?? SizeConfig.diagonal * 1.5,
                  color: Color(Styling.textColor),
                  height: SizeConfig.diagonal * 0.2,
                  letterSpacing: letterSpacing ?? null,
                ),
                decoration: InputDecoration(
                  hintText: hint ?? null,
                  isDense: true,
                  hintStyle: TextStyle(
                    fontSize: SizeConfig.diagonal * 1.5,
                    color: Color(Styling.textColor),
                    letterSpacing: 0,
                  ),
                  labelText: label,
                  labelStyle: TextStyle(
                    fontSize: SizeConfig.diagonal * 1.5,
                    color: Color(Styling.textColor),
                    letterSpacing: 0,
                  ),
                  border: InputBorder.none,
                  prefixIcon: icon == null
                      ? null
                      : Icon(
                          icon,
                          size: SizeConfig.diagonal * 2.5,
                        ),
                  suffix: suffix,
                ),
              ),
            ),
            if (outsideSuffix != null) outsideSuffix,
          ],
        ),
      ),
    );
  }
}
