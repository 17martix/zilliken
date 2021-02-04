import 'package:flutter/material.dart';
import 'package:zilliken/Components/ZAppBar.dart';
import 'package:zilliken/Helpers/Styling.dart';

class OrdersPage extends StatefulWidget {
  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: listView(),
    );
  }

  Widget listView() {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: RaisedButton(
            onPressed: () {},
            elevation: 35,
            color: Colors.white70,
            child: ListTile(
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant_menu),
                ],
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('Hello 1'),
                  Text('Hello 2'),
                ],
              ),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('Hello 3'),
                  Text('Hello 4'),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
