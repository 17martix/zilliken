import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:zilliken/Models/Fields.dart';

class Condiment {
  late String id;
  late String itemId;
  late String itemName;
  late num substQuantity;

  Condiment.buildObject(DocumentSnapshot document) {
    id = document.id;
    itemId = document.data()![Fields.itemId];
    itemName = document.data()![Fields.itemName];
    substQuantity = document.data()![Fields.substQuantity];
  }

  Condiment.buildObjetAsync(AsyncSnapshot<DocumentSnapshot> document) {
    id = document.data!.id;
    itemId = document.data![Fields.itemId];
    itemName = document.data![Fields.itemName];
    substQuantity = document.data![Fields.substQuantity];
  }
}
