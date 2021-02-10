import 'package:cloud_firestore/cloud_firestore.dart';

import 'Fields.dart';

class MenuItem {
  String id;
  String name;
  String category;
  int price;
  int rank;
  int global;
  int availability;
  int createdAt;

  MenuItem({
    this.category,
    this.id,
    this.name,
    this.price,
    this.rank,
    this.global,
    this.availability,
    this.createdAt,
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
  }
}
