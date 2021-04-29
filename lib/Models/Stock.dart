import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:zilliken/Models/Fields.dart';

class Stock {
  String id;
  String name;
  num quantity;
  String unit;
  num usedSince;
  num usedTotal;
  Timestamp date;
  bool linked;

  Stock({
    this.id,
    this.name,
    this.quantity,
    this.unit,
    this.usedSince,
    this.usedTotal,
    this.date,
    this.linked,
  });

  void buildObject(DocumentSnapshot document) {
    id = document.id;
    name = document.data()[Fields.name];
    quantity = document.data()[Fields.quantity];
    unit = document.data()[Fields.unit];
    usedSince = document.data()[Fields.usedSince];
    usedTotal = document.data()[Fields.usedTotal];
    date = document.data()[Fields.date];
    linked = document.data()[Fields.linked];
  }

  void buildObjectAsync(AsyncSnapshot<DocumentSnapshot> document) {
    id = document.data.id;
    name = document.data[Fields.name];
    quantity = document.data[Fields.quantity];
    unit = document.data[Fields.unit];
    usedSince = document.data[Fields.usedSince];
    usedTotal = document.data[Fields.usedTotal];
    date = document.data[Fields.date];
    linked = document.data[Fields.linked];
  }

  String buildStringFromObject() {
    String text = "$id;$name;$quantity;$unit";
    return text;
  }

  void buildObjectFromString(String text) {
    List<String> list = text.split(';');
    id = list[0];
    name = list[1];
    quantity = num.parse(list[2]);
    unit = list[3];
  }
}
