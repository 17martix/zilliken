import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zilliken/Models/Fields.dart';
import 'package:zilliken/Models/Order.dart';

class Call {
  String id;
  bool hasCalled;
  Order order;
  Timestamp createdAt;

  Call({
    this.id,
    this.hasCalled,
    this.order,
    this.createdAt,
  });

  void buildObject(DocumentSnapshot document) {
    order = Order();
    hasCalled = document.data()[Fields.hasCalled];
    createdAt = document.data()[Fields.createdAt];
    id = document.id;
    order.buildObject(document);
  }

  void buildObjectAsync(AsyncSnapshot<DocumentSnapshot> document) {
    order = Order();
    hasCalled = document.data[Fields.hasCalled];
    createdAt = document.data[Fields.createdAt];
    id = document.data.id;
    order.buildObjectAsync(document);
  }
}
