import 'package:flutter/material.dart';
import 'package:zilliken/Components/ZAppBar.dart';

class SingleOrderPage extends StatefulWidget {
  @override
  _SingleOrderPageState createState() => _SingleOrderPageState();
}

class _SingleOrderPageState extends State<SingleOrderPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
    );
  }
}
