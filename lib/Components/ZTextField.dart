import 'package:flutter/material.dart';
import 'package:zilliken/Helpers/Styling.dart';

import '../Helpers/SizeConfig.dart';

/*class ZTextField extends StatelessWidget {
  final FormFieldSetter<String> onSaved;
  final IconData icon;
  final String hint;
  final bool obsecure;
  final String label;
  final keyboardType;
  final inputFormatters;
  final TextEditingController controller;
  final FormFieldValidator<String> validator;
  final int maxLines;
  final suffix;
  final prefix;
  final outsidePrefix;
  final onFieldSubmitted;
  final focusNode;
  
  final onEditingComplete;
  final autofocus;

  ZTextField({
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
    this.outsidePrefix,
    this.onFieldSubmitted,
    this.prefix,
    this.focusNode,
    this.onEditingComplete,
    this.autofocus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextFormField(
        onSaved: onSaved,
        maxLines: maxLines ?? 1,
        minLines: 1,
        controller: controller,
        validator: validator,
        autofocus: autofocus ?? false,
        focusNode: focusNode,
        obscureText: obsecure,
        keyboardType: keyboardType,
        focusNode: focusNode,
        onFieldSubmitted: onFieldSubmitted ?? null,
        inputFormatters: inputFormatters,
        style: TextStyle(
          fontSize: SizeConfig.diagonal * 1.5,
        ),
        decoration: InputDecoration(
          hintStyle: TextStyle(
            fontSize: SizeConfig.diagonal * 1.5,
          ),
          hintText: hint,
          labelText: label,
          labelStyle: TextStyle(
            fontSize: SizeConfig.diagonal * 1.5,
          ),
          prefixIcon: icon ??
              Icon(
                icon,
                size: SizeConfig.diagonal * 2.5,
                color: Color(Styling.primaryColor),
              ),
          suffix: suffix,
          prefix: prefix,
        ),
      ),
    );
  }
}*/

class ZTextField extends StatelessWidget {
  final FormFieldSetter<String> onSaved;
  final IconData icon;
  final String hint;
  final bool obsecure;
  final String label;
  final keyboardType;
  final inputFormatters;
  final TextEditingController controller;
  final FormFieldValidator<String> validator;
  final int maxLines;
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
  final onChanged;
  final prefix;

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
    this.onChanged,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation ?? 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.diagonal * 0.8,
            vertical: SizeConfig.diagonal * 0.1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (outsidePrefix != null) outsidePrefix,
            SizedBox(
              width: SizeConfig.diagonal * 1,
            ),
            Expanded(
              child: TextFormField(
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
                autofocus: false,
                obscureText: obsecure,
                keyboardType: keyboardType,
                inputFormatters: inputFormatters,
                cursorColor: Color(Styling.iconColor),
                style: TextStyle(
                  fontSize: fontSize ?? SizeConfig.diagonal * 1.5,
                  color: Color(Styling.iconColor),
                  height: SizeConfig.diagonal * 0.2,
                  letterSpacing: letterSpacing ?? null,
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  isDense: true,
                  hintStyle: TextStyle(
                    fontSize: SizeConfig.diagonal * 1.5,
                    color: Color(Styling.iconColor),
                    letterSpacing: null,
                  ),
                  labelText: label,
                  labelStyle: TextStyle(
                    fontSize: SizeConfig.diagonal * 1.5,
                    color: Color(Styling.iconColor),
                    letterSpacing: null,
                  ),
                  border: InputBorder.none,
                  prefixIcon: icon == null
                      ? null
                      : Icon(
                          icon,
                          size: SizeConfig.diagonal * 2.5,
                        ),
                  suffix: suffix,
                  prefix: prefix,
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
