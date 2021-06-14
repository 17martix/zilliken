import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zilliken/Models/Fields.dart';

class StatisticStock {
  String? id;
  late String name;
  late num quantity;
  late String unit;
  late String stockId;
  late Timestamp? date;

  StatisticStock({
    this.id,
    required this.name,
    required this.quantity,
    required this.date,
    required this.unit,
    required this.stockId,
  });
  StatisticStock.buildObject(DocumentSnapshot<Map<String, dynamic>> document) {
    id = document.id;
    name = document.data()![Fields.name];
    quantity = document.data()![Fields.quantity];
    unit = document.data()![Fields.unit];
    date = document.data()![Fields.date];
    stockId = document.data()![Fields.stockId];
  }
  StatisticStock.buildObjectAsync(
      AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> document) {
    id = document.data!.id;
    name = document.data![Fields.name];
    quantity = document.data![Fields.quantity];
    unit = document.data![Fields.unit];
    date = document.data![Fields.date];
    stockId = document.data![Fields.stockId];
  }
}
