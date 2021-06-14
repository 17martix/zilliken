import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'Fields.dart';
import 'OrderItem.dart';

class Order {
  late String? id;
  late List<OrderItem> clientOrder;
  late int orderLocation;
  late String tableAdress;
  late String? phoneNumber;
  late String? instructions;
  late num grandTotal;
  late Timestamp? orderDate;
  late Timestamp? confirmedDate;
  late Timestamp? preparationDate;
  late Timestamp? servedDate;
  late int status;
  late String userId;
  late String userName;
  late String userRole;
  late int taxPercentage;
  late int total;
  late GeoPoint? geoPoint;
  late GeoPoint? currentPoint;
  late String? addressName;
  late String? deliveringOrderId;

  Order({
    this.id,
    this.instructions,
    required this.clientOrder,
    required this.orderLocation,
    this.phoneNumber,
    required this.tableAdress,
    required this.grandTotal,
    this.orderDate,
    required this.status,
    this.confirmedDate,
    this.preparationDate,
    this.servedDate,
    required this.userName,
    required this.userId,
    required this.userRole,
    required this.taxPercentage,
    required this.total,
    this.addressName,
    this.geoPoint,
    this.currentPoint,
    this.deliveringOrderId,
  });

  Order.buildObject(DocumentSnapshot<Map<String, dynamic>> document) {
    id = document.id;
    instructions = document.data()?[Fields.instructions];
    orderLocation = document.data()![Fields.orderLocation];
    phoneNumber = document.data()?[Fields.phoneNumber];
    tableAdress = document.data()![Fields.tableAdress];
    grandTotal = document.data()![Fields.grandTotal];
    orderDate = document.data()![Fields.orderDate];
    status = document.data()![Fields.status];
    confirmedDate = document.data()?[Fields.confirmedDate];
    preparationDate = document.data()?[Fields.preparationDate];
    servedDate = document.data()?[Fields.servedDate];
    userId = document.data()![Fields.userId];
    userName = document.data()![Fields.userName];
    userRole = document.data()![Fields.userRole];
    taxPercentage = document.data()![Fields.taxPercentage];
    total = document.data()![Fields.total];
    addressName = document.data()?[Fields.addressName];
    geoPoint = document.data()?[Fields.geoPoint];
    currentPoint = document.data()?[Fields.currentPoint];
    deliveringOrderId = document.data()?[Fields.deliveringOrderId];
    userName = document.data()?[Fields.userName];
  }

  Order.buildObjectAsync(
      AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> document) {
    id = document.data?.id;
    instructions = document.data?[Fields.instructions];
    orderLocation = document.data![Fields.orderLocation];
    grandTotal = document.data![Fields.grandTotal];
    tableAdress = document.data![Fields.tableAdress];
    phoneNumber = document.data?[Fields.phoneNumber];
    orderDate = document.data![Fields.orderDate];
    status = document.data![Fields.status];
    confirmedDate = document.data?[Fields.confirmedDate];
    preparationDate = document.data?[Fields.preparationDate];
    servedDate = document.data?[Fields.servedDate];
    userId = document.data![Fields.userId];
    userName = document.data![Fields.userName];
    userRole = document.data![Fields.userRole];
    taxPercentage = document.data![Fields.taxPercentage];
    total = document.data![Fields.total];
    addressName = document.data?[Fields.addressName];
    geoPoint = document.data?[Fields.geoPoint];
    currentPoint = document.data?[Fields.currentPoint];
    deliveringOrderId = document.data?[Fields.deliveringOrderId];
    userName = document.data?[Fields.userName];
  }
}
