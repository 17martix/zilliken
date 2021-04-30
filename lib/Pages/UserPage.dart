import 'package:flutter/material.dart';
import 'package:zilliken/Components/ZTextField.dart';
import 'package:zilliken/Helpers/SizeConfig.dart';
import 'package:zilliken/Models/Fields.dart';
import 'package:zilliken/Models/UserProfile.dart';
import 'package:zilliken/Pages/SingleUserPage.dart';
import 'package:zilliken/Services/Authentication.dart';
import 'package:zilliken/Services/Database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../i18n.dart';

class UserPage extends StatefulWidget {
  final Authentication auth;
  final Database db;
  final String userId;
  final DateFormat formatter = DateFormat('dd/MM/yy hh:mm ');
  final String userRole;

  UserPage({
    required this.auth,
    required this.db,
    required this.userId,
    required this.userRole,
  });

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  var users = FirebaseFirestore.instance.collection(Fields.users);

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
        Expanded(child: userListStream()),
      ],
    );
  }

  Widget userListStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: users.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.data == null) return Center(child: Text(""));

        return ListView(
          shrinkWrap: true,
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            UserProfile userProfile = UserProfile.buildObject(document);
            return userList(userProfile);
          }).toList(),
        );
      },
    );
  }

  Widget userList(UserProfile userProfile) {
    return Card(
      child: ListTile(
        title: Text(
          '${I18n.of(context).name} ' " : " ' ${userProfile.name}',
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              I18n.of(context).phone + " : " + userProfile.phoneNumber,
            ),
            Text(
              '${I18n.of(context).last} '
              " : "
              '${widget.formatter.format(userProfile.lastSeenAt!.toDate())}',
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SingleUserPage(
                db: widget.db,
                auth: widget.auth,
                userId: widget.userId,
                userRole: widget.userRole,
                userData:userProfile,
              ),
            ),
          );
        },
      ),
    );
  }
}
