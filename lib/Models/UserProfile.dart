import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  String id;
  String role;
  String name;
  String token;

  String phoneNumber;

  UserProfile({
    this.id,
    this.role,
    this.phoneNumber,
    this.name,
    this.token,
  });

}
