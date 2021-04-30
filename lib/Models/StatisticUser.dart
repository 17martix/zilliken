import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import 'Fields.dart';

class StatisticUser {
  String? id;
  late String total;

  late Timestamp date;

  StatisticUser({
    this.id,
    required this.total,
    required this.date,
  });

  StatisticUser.buildObject(DocumentSnapshot document) {
    id = document.id;
    total = document.data()![Fields.total];
    date = document.data()![Fields.date];
  }

  StatisticUser.buildObjectAsync(AsyncSnapshot<DocumentSnapshot> document) {
    id = document.data!.id;
    total = document.data![Fields.total];
    date = document.data![Fields.date];
  }
}
