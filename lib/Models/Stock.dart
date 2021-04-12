import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:zilliken/Models/Fields.dart';

class Stock {
  String id;
  String name;
  String unit;
  num usedSince;
  num usedTotal;
  num quantity;

  Stock({
    this.id,
    this.name,
    this.quantity,
    this.unit,
    this.usedSince,
    this.usedTotal,
  });

  void buildObject(DocumentSnapshot document) {
    id = document.id;
    name = document.data()[Fields.name];
    unit = document.data()[Fields.unit];
    usedSince = document.data()[Fields.usedSince];
    usedTotal = document.data()[Fields.usedTotal];
    quantity = document.data()[Fields.quantity];
  }

  void buildObjectAsync(AsyncSnapshot<DocumentSnapshot> document) {
    id = document.data.id;
    name = document.data[Fields.name];
    unit = document.data[Fields.unit];
    usedSince = document.data[Fields.usedSince];
    usedTotal = document.data[Fields.usedTotal];
    quantity = document.data[Fields.quantity];
  }
}
