import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zilliken/Models/Fields.dart';

class StatisticStock {
  String? id;
  late String name;
  late num quantity;
  late String unit;
  late Timestamp? date;

  StatisticStock({
    this.id,
    required this.name,
    required this.quantity,
    required this.date,
    required this.unit,
  });
  StatisticStock.buildObject(DocumentSnapshot<Map<String,dynamic>> document) {
    id = document.id;
    name = document.data()![Fields.name];
    quantity = document.data()![Fields.quantity];
    unit = document.data()![Fields.unit];
    date = document.data()![Fields.date];

  }
   StatisticStock.buildObjectAsync(AsyncSnapshot<DocumentSnapshot<Map<String,dynamic>>> document) {
    id = document.data!.id;
    name = document.data![Fields.name];
    quantity = document.data![Fields.quantity];
    unit = document.data![Fields.unit];
    date = document.data![Fields.date];

  }
}
