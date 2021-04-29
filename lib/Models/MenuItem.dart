import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'Fields.dart';
import 'Stock.dart';

class MenuItem {
  String id;
  String name;
  String category;
  int price;
  int rank;
  int global;
  int availability;
  Timestamp createdAt;
  String imageName;
  int isDrink;
  List<Stock> condiments;
  bool isChecked;

  MenuItem({
    this.category,
    this.id,
    this.name,
    this.price,
    this.rank,
    this.global,
    this.availability,
    this.createdAt,
    this.imageName,
    this.isDrink,
    this.condiments,
    this.isChecked,
  });

  void buildObject(DocumentSnapshot document) {
    if (document.data()[Fields.condiments] != null) {
      condiments = [];
      List<String> textCondimentList =
          List.from(document.data()[Fields.condiments]);
      textCondimentList.forEach((element) {
        Stock stock = Stock();
        stock.buildObjectFromString(element);
        condiments.add(stock);
      });
    }

    category = document.data()[Fields.category];
    id = document.id;
    name = document.data()[Fields.name];
    price = document.data()[Fields.price];
    rank = document.data()[Fields.rank];
    global = document.data()[Fields.global];
    availability = document.data()[Fields.availability];
    createdAt = document.data()[Fields.createdAt];
    imageName = document.data()[Fields.imageName];
    isDrink = document.data()[Fields.isDrink];
  }

  void buildObjectAsync(AsyncSnapshot<DocumentSnapshot> document) {
    if (document.data[Fields.condiments] != null) {
      condiments = [];
      List<String> textCondimentList =
          List.from(document.data[Fields.condiments]);
      textCondimentList.forEach((element) {
        Stock stock = Stock();
        stock.buildObjectFromString(element);
        condiments.add(stock);
      });
    }

    category = document.data[Fields.category];
    id = document.data.id;
    name = document.data[Fields.name];
    price = document.data[Fields.price];
    rank = document.data[Fields.rank];
    global = document.data[Fields.global];
    availability = document.data[Fields.availability];
    createdAt = document.data[Fields.createdAt];
    imageName = document.data[Fields.imageName];
    isDrink = document.data[Fields.isDrink];
  }
}
