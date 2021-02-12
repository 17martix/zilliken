import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zilliken/Models/Fields.dart';

import 'MenuItem.dart';

class OrderItem {
  MenuItem menuItem;
  int count;

  OrderItem({this.count, this.menuItem});

  void buildObject(DocumentSnapshot document) {
    menuItem = MenuItem();
    count = document.data()[Fields.count];
    menuItem.buildObject(document);
  }

  void buildObjectAsync(AsyncSnapshot<DocumentSnapshot> document) {
    menuItem = MenuItem();
    count = document.data[Fields.count];
    menuItem.buildObjectAsync(document);
  }
}
