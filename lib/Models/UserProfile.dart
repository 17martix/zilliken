import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import 'Fields.dart';

class UserProfile {
  String? id;
  late String role;
  late String name;
  late String? token;

  late String phoneNumber;
  late Timestamp? lastSeenAt;
  late Timestamp? createdAt;
  late List<String>? tags;
  late bool isActive;

  UserProfile({
    required this.id,
    required this.role,
    required this.phoneNumber,
    required this.name,
    this.token,
    this.lastSeenAt,
    this.createdAt,
    required this.tags,
    required this.isActive,
  });

  UserProfile.buildObject(DocumentSnapshot<Map<String,dynamic>> document) {
    id = document.id;
    role = document.data()![Fields.role];
    phoneNumber = document.data()![Fields.phoneNumber];
    name = document.data()![Fields.name];
    token = document.data()?[Fields.token];
    lastSeenAt = document.data()![Fields.lastSeenAt];
    createdAt = document.data()![Fields.createdAt];
    isActive = document.data()![Fields.isActive];
    tags = List.from(document.data()![Fields.tags]);
  }

  UserProfile.buildObjectAsync(AsyncSnapshot<DocumentSnapshot<Map<String,dynamic>>> document) {
    id = document.data?.id;
    role = document.data![Fields.role];
    phoneNumber = document.data![Fields.phoneNumber];
    name = document.data![Fields.name];
    token = document.data?[Fields.token];
    lastSeenAt = document.data![Fields.lastSeenAt];
    createdAt = document.data![Fields.createdAt];
    tags = List.from(document.data![Fields.tags]);
    isActive = document.data![Fields.isActive];
  }
}
