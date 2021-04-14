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

  Stock({
    this.id,
    this.name,
    this.quantity,
    this.unit,
    this.usedSince,
    this.usedTotal,
    this.date,
  });

  void buildObject(DocumentSnapshot document) {
    id = document.id;
    name = document.data()[Fields.name];
    quantity = document.data()[Fields.quantity];
    unit = document.data()[Fields.unit];
    usedSince = document.data()[Fields.usedSince];
    usedTotal = document.data()[Fields.usedTotal];
    date = document.data()[Fields.date];
  }

  void buildObjectAsync(AsyncSnapshot<DocumentSnapshot> document) {
    id = document.data.id;
    name = document.data[Fields.name];
    quantity = document.data[Fields.quantity];
    unit = document.data[Fields.unit];
    usedSince = document.data[Fields.usedSince];
    usedTotal = document.data[Fields.usedTotal];
    date = document.data[Fields.date];
  }
}
