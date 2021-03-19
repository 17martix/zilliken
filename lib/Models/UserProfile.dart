import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  String id;
  String role;
  String firstName;
  String lastName;
  String email;
  String address;
  String phoneNumber;
  int receiveNotifications;
  Timestamp lastSeenAt;

  UserProfile({
    this.id,
    this.email,
    this.role,
    this.firstName,
    this.lastName,
    this.address,
    this.phoneNumber,
    this.receiveNotifications,
    this.lastSeenAt,
  });

  bool isNotificationEnabled() {
    if (receiveNotifications == 1) return true;
    return false;
  }
}
