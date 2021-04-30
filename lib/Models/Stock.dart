import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:zilliken/Models/Fields.dart';

class Stock {
  String? id;
  late String name;
  late num quantity;
  late String unit;
  late num usedSince;
  late num usedTotal;
  late Timestamp? date;

  Stock({
    this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.usedSince,
    required this.usedTotal,
     this.date,
  });

  Stock.buildObject(DocumentSnapshot document) {
    id = document.id;
    name = document.data()![Fields.name];
    quantity = document.data()![Fields.quantity];
    unit = document.data()![Fields.unit];
    usedSince = document.data()![Fields.usedSince];
    usedTotal = document.data()![Fields.usedTotal];
    date = document.data()![Fields.date];
  }

  Stock.buildObjectAsync(AsyncSnapshot<DocumentSnapshot> document) {
    id = document.data?.id;
    name = document.data![Fields.name];
    quantity = document.data![Fields.quantity];
    unit = document.data![Fields.unit];
    usedSince = document.data![Fields.usedSince];
    usedTotal = document.data![Fields.usedTotal];
    date = document.data![Fields.date];
  }

  String buildStringFromObject() {
    String text = "$id;$name;$quantity;$unit";
    return text;
  }

  Stock.buildObjectFromString(String text) {
    List<String> list = text.split(';');
    id = list[0];
    name = list[1];
    quantity = num.parse(list[2]);
    unit = list[3];
  }
}
