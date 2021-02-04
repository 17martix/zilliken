import 'package:flutter/material.dart';
import 'package:zilliken/Components/ZAppBar.dart';
import 'package:zilliken/Helpers/Styling.dart';

class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        "All/Tout",
                      ),
                      Container(
                        height: 2,
                        width: 20,
                        color: Color(Styling.accentColor),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        "Petit dejeuner",
                        style: TextStyle(
                          color: Color(Styling.textColor).withOpacity(0.5),
                        ),
                      ),
                      Container(
                        height: 2,
                        width: 20,
                        color: Color(Styling.accentColor),
                      ),
                    ],
                  ),
                ),
                Text(
                  "Dinner",
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                height: 1,
                color: Color(Styling.accentColor),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Petit dejeuner"),
              ),
              Container(
                padding: const EdgeInsets.all(15.0),
                height: 1,
                color: Color(Styling.accentColor),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: <Widget>[
                ListTile(
                  title: Text("The vert"),
                  subtitle: Text("500"),
                  trailing: FlatButton(
                    child: Text("+"),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
