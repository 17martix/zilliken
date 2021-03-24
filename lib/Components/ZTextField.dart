import 'package:country_list_pick/country_list_pick.dart';
import 'package:flutter/material.dart';
import 'package:zilliken/Helpers/Styling.dart';

import '../Helpers/SizeConfig.dart';

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
  final prefix;
  final outsidePrefix;
  final onFieldSubmitted;

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
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextFormField(
        onSaved: onSaved,
        maxLines: maxLines ?? 1,
        controller: controller,
        validator: validator,
        autofocus: false,
        obscureText: obsecure,
        keyboardType: keyboardType,
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
}
