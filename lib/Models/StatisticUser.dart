import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import 'Fields.dart';

class StatisticUser {
  String? id;
  late num total;
  late Timestamp date;
  late String userId;
  late num count;

  StatisticUser(
      {this.id,
      required this.total,
      required this.date,
      required this.userId,
      required this.count});

  StatisticUser.buildObject(DocumentSnapshot document) {
    id = document.id;
    total = document.data()![Fields.total];
    date = document.data()![Fields.date];
    userId = document.data()![Fields.userId];

    count = document.data()![Fields.count];
  }

  StatisticUser.buildObjectAsync(AsyncSnapshot<DocumentSnapshot> document) {
    id = document.data!.id;
    total = document.data![Fields.total];
    date = document.data![Fields.date];
    userId = document.data![Fields.userId];
    count = document.data![Fields.count];
  }
}
