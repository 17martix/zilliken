import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zilliken/Components/ZAppBar.dart';
import 'package:zilliken/Components/ZRaisedButton.dart';
import 'package:zilliken/Helpers/SizeConfig.dart';
import 'package:zilliken/Models/Fields.dart';
import 'package:zilliken/Models/MenuItem.dart';
import 'package:zilliken/Services/Authentication.dart';
import 'package:zilliken/Services/Database.dart';
import 'package:zilliken/Services/Messaging.dart';
import 'package:zilliken/i18n.dart';

class LinkToMenu extends StatefulWidget {
  final Authentication auth;
  final Database db;
  final Messaging messaging;
  final String userId;
  final String userRole;
  LinkToMenu({
    this.auth,
    this.db,
    this.messaging,
    this.userId,
    this.userRole,
  });
  @override
  _ConnectToMenuState createState() => _ConnectToMenuState();
}

class _ConnectToMenuState extends State<LinkToMenu> {
  void backFunction() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: buildAppBar(
          context, widget.auth, true, null, backFunction, null, null),
      body: menuItemStream(),
    );
  }

  Widget menuItemStream() {
    var menu = FirebaseFirestore.instance.collection(Fields.menu);

    return StreamBuilder(
        stream: menu.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.data == null)
            return Center(
              child: Text(''),
            );

          return ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: snapshot.data.docs.length,
              itemBuilder: (BuildContext context, index) {
                MenuItem menuItem = MenuItem();
                menuItem.buildObject(snapshot.data.docs[index]);
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    itemTile(menuItem),
                  ],
                );
              });
        });
  }

  Widget itemTile(MenuItem menuItem) {
    return Container(
      width: double.infinity,
      height: SizeConfig.diagonal * 7,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SizeConfig.diagonal * 1.5)),
        child: CheckboxListTile(
          title: Text(menuItem.name),
          value: false,
          onChanged: (value) {
            setState(() {
              value = value;
            });
          },
        ),
      ),
    );
  }
}
