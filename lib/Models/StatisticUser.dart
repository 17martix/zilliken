import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import 'Fields.dart';

class StatisticUser {
  String? id;
  late num total;
  late Timestamp date;
  late String userId;
  late String userName;
   num? count;

  StatisticUser(
      {this.id,
      required this.total,
      required this.date,
      required this.userId,
      required this.userName,
      this.count});

  StatisticUser.buildObject(DocumentSnapshot<Map<String,dynamic>> document) {
    id = document.id;
    total = document.data()![Fields.total];
    date = document.data()![Fields.date];
    userId = document.data()![Fields.userId];
     userName = document.data()![Fields.userName];

    count = document.data()![Fields.count];
  }

  StatisticUser.buildObjectAsync(AsyncSnapshot<DocumentSnapshot<Map<String,dynamic>>> document) {
    id = document.data!.id;
    total = document.data![Fields.total];
    date = document.data![Fields.date];
    userId = document.data![Fields.userId];
    userName = document.data![Fields.userName];
    count = document.data![Fields.count];
  }
}
