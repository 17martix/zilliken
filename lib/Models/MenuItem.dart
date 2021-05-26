import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'Fields.dart';
import 'Stock.dart';

class MenuItem {
  late String? id;
  late String name;
  late String? category;
  late int price;
  late int? rank;
  late int? global;
  late int? availability;
  late Timestamp? createdAt;
  late String? imageName;
  late int? isDrink;
  List<Stock>? condiments;
  late bool? isChecked;
  num? quantity;
  TextEditingController controller = TextEditingController();

  MenuItem({
    this.category,
    this.id,
    required this.name,
    required this.price,
    this.rank,
    this.global,
    this.availability,
    this.createdAt,
    this.imageName,
    this.isDrink,
    this.condiments,
    this.isChecked,
    this.quantity,
  });

  MenuItem.buildObject(DocumentSnapshot<Map<String,dynamic>> document) {
    if (document.data()?[Fields.condiments] != null) {
      condiments = [];
      List<String> textCondimentList =
          List.from(document.data()![Fields.condiments]);
      textCondimentList.forEach((element) {
        Stock stock = Stock.buildObjectFromString(element);
        condiments!.add(stock);
      });
    }

    category = document.data()![Fields.category];
    id = document.id;
    name = document.data()![Fields.name];
    price = document.data()![Fields.price];
    rank = document.data()![Fields.rank];
    global = document.data()![Fields.global];
    availability = document.data()![Fields.availability];
    createdAt = document.data()![Fields.createdAt];
    imageName = document.data()![Fields.imageName];
    isDrink = document.data()![Fields.isDrink];
  }

  MenuItem.buildObjectAsync(AsyncSnapshot<DocumentSnapshot<Map<String,dynamic>>> document) {
    if (document.data?[Fields.condiments] != null) {
      condiments = [];
      List<String> textCondimentList =
          List.from(document.data![Fields.condiments]);
      textCondimentList.forEach((element) {
        Stock stock = Stock.buildObjectFromString(element);
        condiments!.add(stock);
      });
    }

    category = document.data![Fields.category];
    id = document.data!.id;
    name = document.data![Fields.name];
    price = document.data![Fields.price];
    rank = document.data![Fields.rank];
    global = document.data![Fields.global];
    availability = document.data![Fields.availability];
    createdAt = document.data![Fields.createdAt];
    imageName = document.data![Fields.imageName];
    isDrink = document.data![Fields.isDrink];
  }
}
