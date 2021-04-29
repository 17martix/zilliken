import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import 'Fields.dart';

class UserProfile {
  String id;
  String role;
  String name;
  String token;

  String phoneNumber;
  Timestamp lastSeenAt;
  Timestamp createdAt;

  UserProfile({
    this.id,
    this.role,
    this.phoneNumber,
    this.name,
    this.token,
    this.lastSeenAt,
    this.createdAt,
  });

  void buildObject(DocumentSnapshot document) {
    id = document.id;
    role = document.data()[Fields.role];
    phoneNumber = document.data()[Fields.phoneNumber];
    name = document.data()[Fields.name];
    token = document.data()[Fields.token];
    lastSeenAt = document.data()[Fields.lastSeenAt];
    createdAt = document.data()[Fields.createdAt];
  }

  void buildObjectAsync(AsyncSnapshot<DocumentSnapshot> document) {
    id = document.data.id;
    role = document.data[Fields.role];
    phoneNumber = document.data[Fields.phoneNumber];
    name = document.data[Fields.name];
    token = document.data[Fields.token];
    lastSeenAt = document.data[Fields.lastSeenAt];
    createdAt = document.data[Fields.createdAt];
  }
}
