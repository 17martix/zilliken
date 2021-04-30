import 'package:cloud_firestore/cloud_firestore.dart';

import 'Fields.dart';

class Category {
  late String? id;
  late String name;
  late int? rank;
  late Timestamp? createdAt;
  late String? imageName;

  Category({
     this.id,
    required this.name,
     this.rank,
     this.createdAt,
     this.imageName,
  });

  Category.buildObject(DocumentSnapshot document) {
    id = document.id;
    name = document.data()![Fields.name];
    rank = document.data()![Fields.rank];
    createdAt = document.data()![Fields.createdAt];
    imageName = document.data()![Fields.imageName];
  }
}
