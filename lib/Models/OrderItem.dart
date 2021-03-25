import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zilliken/Models/Fields.dart';

import 'MenuItem.dart';

class OrderItem {
  MenuItem menuItem;
  int count;
  int coldCount;
  int lukeWCount;

  OrderItem({
    this.count,
    this.menuItem,
    this.coldCount,
    this.lukeWCount,
  });

  void buildObject(DocumentSnapshot document) {
    menuItem = MenuItem();
    count = document.data()[Fields.count];
    coldCount = document.data()[Fields.coldCount];
    lukeWCount = document.data()[Fields.lukeWCount];

    menuItem.buildObject(document);
  }

  void buildObjectAsync(AsyncSnapshot<DocumentSnapshot> document) {
    menuItem = MenuItem();
    count = document.data[Fields.count];
    coldCount = document.data[Fields.coldCount];
    lukeWCount = document.data[Fields.lukeWCount];
    menuItem.buildObjectAsync(document);
  }
}
