import 'package:cloud_firestore/cloud_firestore.dart';

import 'Fields.dart';

class Address {
  late String? id;
 late GeoPoint geoPoint;
 late String addressName;
 late String typedAddress;
 late String phoneNumber;

 Address({
 required  this.addressName,
 required  this.geoPoint,
  required this.phoneNumber,
  required this.typedAddress,
 });

   Address.buildObject(DocumentSnapshot document) {
    id = document.id;
    geoPoint = document.data()![Fields.geoPoint];
    addressName = document.data()![Fields.addressName];
    typedAddress = document.data()![Fields.typedAddress];
    phoneNumber = document.data()![Fields.phoneNumber];
  }
}
