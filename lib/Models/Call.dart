import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zilliken/Models/Fields.dart';
import 'package:zilliken/Models/Order.dart';

class Call {
  late String? id;
  late bool hasCalled;
  late Order order;
  late Timestamp? createdAt;

  Call({
     this.id,
    required this.hasCalled,
    required this.order,
     this.createdAt,
  });

  Call.buildObject(DocumentSnapshot document) {
    order = Order.buildObject(document);
    hasCalled = document.data()![Fields.hasCalled];
    createdAt = document.data()![Fields.createdAt];
    id = document.id;
  }

  Call.buildObjectAsync(AsyncSnapshot<DocumentSnapshot> document) {
    order = Order.buildObjectAsync(document);
    hasCalled = document.data![Fields.hasCalled];
    createdAt = document.data![Fields.createdAt];
    id = document.data!.id;
  }
}
