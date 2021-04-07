import 'package:flutter/material.dart';
import 'package:zilliken/Components/ZTextField.dart';
import 'package:zilliken/Helpers/SizeConfig.dart';

import '../i18n.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: SizeConfig.diagonal * 3),
          ZTextField(
              decoration: InputDecoration(
                labelText: I18n.of(context).search,
              ),
              keyboardType: TextInputType.text,
              icon: Icons.search,
              onChanged: () {}),
          Container(
            child: ListTile(
              title: Text(I18n.of(context).name),
              subtitle: Text(I18n.of(context).phone),
            ),
          ),
        ],
      ),
    );
  }
}
