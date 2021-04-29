import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zilliken/Components/ZAppBar.dart';
import 'package:zilliken/Components/ZRaisedButton.dart';
import 'package:zilliken/Components/ZTextField.dart';
import 'package:zilliken/Helpers/SizeConfig.dart';
import 'package:zilliken/Helpers/Styling.dart';
import 'package:zilliken/Models/Fields.dart';
import 'package:zilliken/Models/Linked.dart';
import 'package:zilliken/Models/MenuItem.dart';
import 'package:zilliken/Models/Stock.dart';
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
  final Stock stock;

  LinkToMenu({
    this.auth,
    this.db,
    this.messaging,
    this.userId,
    this.userRole,
    this.stock,
  });
  @override
  _ConnectToMenuState createState() => _ConnectToMenuState();
}

class _ConnectToMenuState extends State<LinkToMenu> {
  String linkId;
  bool _isChecked;
  void backFunction() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: buildAppBar(
          context, widget.auth, true, null, backFunction, null, null),
      body: body(MenuItem(), Linked()),
    );
  }

  Widget body(MenuItem menuItem, Linked linked) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: SizeConfig.diagonal * 0.9),
          child: ZTextField(
            outsidePrefix: Padding(
              padding: EdgeInsets.only(left: SizeConfig.diagonal * 1),
              child: Icon(Icons.search),
            ),
          ),
        ),
        Container(
          height: SizeConfig.diagonal * 5,
          child: Center(
            child: Text('Choose any meal that requires this item'),
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Expanded(child: menuItemStream()),
              ZRaisedButton(
                onpressed: () async {
                  if (linkId != null) {
                    await widget.db.linkUpdater(widget.stock, menuItem, linked);
                  } else {
                    await widget.db.linkSetter(widget.stock, menuItem, linked);
                  }
                },
                textIcon: Text(I18n.of(context).save),
                bottomPadding: SizeConfig.diagonal * 0.8,
                topPadding: SizeConfig.diagonal * 0.8,
              ),
            ],
          ),
        )
      ],
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
              shrinkWrap: true,
              //physics: BouncingScrollPhysics(),
              itemCount: snapshot.data.docs.length,
              itemBuilder: (BuildContext context, index) {
                MenuItem menuItem = MenuItem();
                menuItem.buildObject(snapshot.data.docs[index]);
                return itemTile(menuItem);
              });
        });
  }

  Widget itemTile(MenuItem menuItem) {
    Linked linked = Linked();
    return Container(
      width: double.infinity,
      height: SizeConfig.diagonal * 13,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SizeConfig.diagonal * 1.5)),
        child: Column(
          children: [
            CheckboxListTile(
              activeColor: Color(Styling.accentColor),
              title: Text(menuItem.name),
              value: true,
              onChanged: (value) {
                setState(() {
                  value = value;
                });
              },
            ),
            Padding(
              padding: EdgeInsets.only(right: SizeConfig.diagonal * 4),
              child: ZTextField(
                onSaved: (value) => value = '${linked.substQuantity}',
                validator: (value) =>
                    value.isEmpty ? I18n.of(context).requit : null,
                outsidePrefix: Padding(
                  padding: EdgeInsets.only(left: SizeConfig.diagonal * 0.5),
                  child: Text('Qty needed :'),
                ),
                elevation: 1.3,
                // outsideSuffix: Padding(
                //   padding: EdgeInsets.only(right: SizeConfig.diagonal * 0.5),
                //   child: InkWell(
                //       onTap: () {},
                //       child: Icon(
                //         Icons.backspace,
                //         size: SizeConfig.diagonal * 2.0,
                //       )),
                // ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget linkedStream() {
    var linkRef = FirebaseFirestore.instance
        .collection(Fields.stock)
        .doc(widget.stock.id)
        .collection(Fields.linked);

    return StreamBuilder(
        stream: linkRef.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.data == null)
            return Center(
              child: Text(''),
            );

          return ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (BuildContext context, index) {
                Linked linked = Linked();
                linked.buildObject(snapshot.data.docs[index]);

                if (snapshot.data.docs.contains(linked.itemId)) {
                  linked.itemId = linkId;
                }
              });
        });
  }
}
