import 'package:cloud_firestore/cloud_firestore.dart';

import 'Fields.dart';

class Address {
  String id;
  GeoPoint geoPoint;
  String addressName;
  String typedAddress;
  String phoneNumber;

  void buildObject(DocumentSnapshot document) {
    id = document.id;
    geoPoint = document.data()[Fields.geoPoint];
    addressName = document.data()[Fields.addressName];
    typedAddress = document.data()[Fields.typedAddress];
    phoneNumber = document.data()[Fields.phoneNumber];
  }
}
