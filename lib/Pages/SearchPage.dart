import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zilliken/Components/ZText.dart';
import 'package:zilliken/Helpers/SizeConfig.dart';
import 'package:zilliken/Helpers/Styling.dart';
import 'package:zilliken/Models/UserProfile.dart';
import 'package:zilliken/Services/Authentication.dart';
import 'package:zilliken/Services/Database.dart';
import 'package:intl/intl.dart';

import '../i18n.dart';
import 'SingleUserPage.dart';

class SearchPage extends StatefulWidget {
  final Authentication auth;
  final Database db;
  final String userId;
  final String userRole;
  final bool isLoading;
  final List<DocumentSnapshot<Map<String,dynamic>>> searchList;
  final String noResult;
  final DateFormat formatter = DateFormat('dd/MM/yy HH:mm');

  SearchPage({
    required this.auth,
    required this.db,
    required this.userId,
    required this.userRole,
    required this.isLoading,
    required this.noResult,
    required this.searchList,
  });

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return resultView();
  }

  Widget resultView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        widget.searchList.length == 0
            ? Center(
                child: ZText(
                  content: widget.noResult,
                  fontSize: SizeConfig.diagonal * 2,
                  color: Color(Styling.primaryColor),
                  fontWeight: FontWeight.w700,
                ),
              )
            : ListView(
                shrinkWrap: true,
                children: widget.searchList.map((DocumentSnapshot<Map<String,dynamic>> document) {
                  UserProfile userProfile = UserProfile.buildObject(document);
                  return userList(userProfile);
                }).toList(),
              ),
        widget.isLoading
            ? Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(SizeConfig.diagonal * 1),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : Container()
      ],
    );
  }

  Widget userList(UserProfile userProfile) {
    return Card(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: SizeConfig.diagonal * 1),
        child: ListTile(
          title: ZText(
            content: '${I18n.of(context).name} ' " : " ' ${userProfile.name}',
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ZText(
                content: I18n.of(context).phone + " : " + userProfile.phoneNumber,
              ),
              ZText(
                content: '${I18n.of(context).last} '
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
                  userData: userProfile,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
