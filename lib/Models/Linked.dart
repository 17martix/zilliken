import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:zilliken/Models/Fields.dart';

class Linked {
  String id;
  String itemId;
  String itemName;
  num substQuantity;

  void buildObject(DocumentSnapshot document) async {
    id = document.id;
    itemId = document.data()[Fields.itemId];
    itemName = document.data()[Fields.itemName];
    substQuantity = document.data()[Fields.substQuantity];
  }

  void buildObjetAsync(AsyncSnapshot<DocumentSnapshot> document) {
    id = document.data.id;
    itemId = document.data[Fields.itemId];
    itemName = document.data[Fields.itemName];
    substQuantity = document.data[Fields.substQuantity];
  }
}
