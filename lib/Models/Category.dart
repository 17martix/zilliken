import 'package:cloud_firestore/cloud_firestore.dart';

import 'Fields.dart';

class Category {
  String id;
  String name;
  int rank;
  int createdAt;
  String imageName;

  Category({this.id, this.name, this.rank, this.createdAt, this.imageName});

  void buildObject(DocumentSnapshot document) {
    id = document.id;
    name = document.data()[Fields.name];
    rank = document.data()[Fields.rank];
    createdAt = document.data()[Fields.createdAt];
    imageName = document.data()[Fields.imageName];
  }
}
