import 'package:cloud_firestore/cloud_firestore.dart';

import 'Fields.dart';

class Statistic {
  String? id;
  late num total;
  late Timestamp date;

  Statistic({
    this.id,
    required this.total,
    required this.date,
  });

  Statistic.buildObject(DocumentSnapshot document) {
    id = document.id;
    total = document.data()![Fields.total];
    date = document.data()![Fields.date];
  }
}
