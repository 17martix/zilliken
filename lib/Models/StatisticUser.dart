import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import 'Fields.dart';

class StatisticUser {
  String id;
  String total;

  Timestamp date;

  StatisticUser({
    this.id,
    this.total,
    this.date,
  });

  void buildObject(DocumentSnapshot document) {
    id = document.id;
    total = document.data()[Fields.total];
    date = document.data()[Fields.date];
  }

  void buildObjectAsync(AsyncSnapshot<DocumentSnapshot> document) {
    id = document.data.id;
    total = document.data[Fields.total];
    date = document.data[Fields.date];
  }
}
