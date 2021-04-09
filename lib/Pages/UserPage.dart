import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zilliken/Components/ZTextField.dart';
import 'package:zilliken/Helpers/SizeConfig.dart';
import 'package:zilliken/Helpers/Styling.dart';
import 'package:zilliken/Services/Authentication.dart';
import 'package:zilliken/Services/Database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../i18n.dart';

class UserPage extends StatefulWidget {
  final Authentication auth;
  final Database db;
  final String userId;
// final List<userCategory> userList;
  final String userRole;

  UserPage({
    @required this.auth,
    @required this.db,
    @required this.userId,
    @required this.userRole,
     // @required this.userList,
  });

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
 //List<userCategory> userList = new List();
  var users = FirebaseFirestore.instance.collection('users');

  /* @override
  void initState() {
    super.initState();

    setState(() {});
  }*/

/*  @override
  void userQuery(){
    users = FirebaseFirestore.instance
            .collection(Fields.name)
            .where(Fields.availability, isEqualTo: 1)
            .orderBy(Fields.global, descending: false); 
  }*/

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: body(),
    );
  }

  Widget body() {
    return Column(
      children: [
        SizedBox(height: SizeConfig.diagonal * 3),
        Padding(
          padding: EdgeInsets.all(SizeConfig.diagonal * 1),
          child: ZTextField(
            hint: (I18n.of(context).search),
            keyboardType: TextInputType.text,
            outsidePrefix: Icon(
              Icons.search,
              size: SizeConfig.diagonal * 2.5,
            ),
          ),
        ),
        userCategory(),
      ],
    );
  }

  Widget userCategory() {
    return StreamBuilder<QuerySnapshot>(
      stream: users.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.data == null) return Center(child: Text(""));

        return Container(
          margin: EdgeInsets.symmetric(horizontal: SizeConfig.diagonal * 1),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              children: snapshot.data.docs.map((DocumentSnapshot document) {
                return ListTile(
                  title: Text(document.data()[I18n.of(context).name]),
                  subtitle: Text(document.data()[I18n.of(context).phone]),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
