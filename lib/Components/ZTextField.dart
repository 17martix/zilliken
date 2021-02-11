import 'package:flutter/material.dart';

import '../Helpers/SizeConfig.dart';

class ZTextField extends StatelessWidget {
  final FormFieldSetter<String> onSaved;
  final Icon icon;
  final String hint;
  final bool obsecure;
  final String label;
  final keyboardType;
  final inputFormatters;
  final TextEditingController controller;
  final FormFieldValidator<String> validator;
  final int maxLines;
  final suffix;

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
          prefixIcon: Padding(
            child: IconTheme(
              data: IconThemeData(color: Theme.of(context).primaryColor),
              child: icon,
            ),
            padding: EdgeInsets.only(left: 0, right: 0),
          ),
          suffix: suffix,
        ),
      ),
    );
  }
}
