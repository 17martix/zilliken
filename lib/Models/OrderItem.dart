import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zilliken/Models/Fields.dart';

import 'MenuItem.dart';

class OrderItem {
  late MenuItem menuItem;
  late int count;

  OrderItem({
    required this.count,
    required this.menuItem,
  });

  OrderItem.buildObject(DocumentSnapshot document) {
    menuItem = MenuItem.buildObject(document);
    count = document.data()![Fields.count];
  }

  OrderItem.buildObjectAsync(AsyncSnapshot<DocumentSnapshot> document) {
    menuItem = MenuItem.buildObjectAsync(document);
    count = document.data![Fields.count];
  }
}
