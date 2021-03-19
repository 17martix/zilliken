import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'Fields.dart';

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
  });

  void buildObject(DocumentSnapshot document) {
    category = document.data()[Fields.category];
    id = document.id;
    name = document.data()[Fields.name];
    price = document.data()[Fields.price];
    rank = document.data()[Fields.rank];
    global = document.data()[Fields.global];
    availability = document.data()[Fields.availability];
    createdAt = document.data()[Fields.createdAt];
    imageName = document.data()[Fields.imageName];
  }

  void buildObjectAsync(AsyncSnapshot<DocumentSnapshot> document) {
    category = document.data[Fields.category];
    id = document.data.id;
    name = document.data[Fields.name];
    price = document.data[Fields.price];
    rank = document.data[Fields.rank];
    global = document.data[Fields.global];
    availability = document.data[Fields.availability];
    createdAt = document.data[Fields.createdAt];
    imageName = document.data[Fields.imageName];
  }
}
