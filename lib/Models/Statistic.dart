import 'package:cloud_firestore/cloud_firestore.dart';

import 'Fields.dart';

class Statistic {
  String id;
  int total;
  Timestamp date;

  Statistic({
    this.id,
    this.total,
    this.date,
  });

  void buildObject(DocumentSnapshot document) {
    id = document.id;
    total = document.data()[Fields.total];
    date = document.data()[Fields.date];

  }
}
