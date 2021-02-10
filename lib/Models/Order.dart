import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'Fields.dart';
import 'OrderItem.dart';

class Order {
  String id;
  List<OrderItem> clientOrder;
  int orderLocation;
  String tableAdress;
  String phoneNumber;
  String instructions;
  double grandTotal;
  int orderDate;
  int confirmedDate;
  int prepationDate;
  int servedDate;
  int status;
  String userId;
  String userRole;
  int taxPercentage;
  int total;

  Order({
    this.id,
    this.instructions,
    this.clientOrder,
    this.orderLocation,
    this.phoneNumber,
    this.tableAdress,
    this.grandTotal,
    this.orderDate,
    this.status,
    this.confirmedDate,
    this.prepationDate,
    this.servedDate,
    this.userId,
    this.userRole,
    this.taxPercentage,
    this.total,
  });

  void buildObject(DocumentSnapshot document) {
    id = document.id;
    instructions = document.data()[Fields.instructions];
    orderLocation = document.data()[Fields.orderLocation];
    phoneNumber = document.data()[Fields.phoneNumber];
    tableAdress = document.data()[Fields.tableAdress];
    grandTotal = document.data()[Fields.grandTotal];
    orderDate = document.data()[Fields.orderDate];
    status = document.data()[Fields.status];
    confirmedDate = document.data()[Fields.confirmedDate];
    prepationDate = document.data()[Fields.prepationDate];
    servedDate = document.data()[Fields.servedDate];
    userId = document.data()[Fields.userId];
    userRole = document.data()[Fields.userRole];
    taxPercentage = document.data()[Fields.taxPercentage];
    total = document.data()[Fields.total];
  }

  void buildObjectAsync(AsyncSnapshot<DocumentSnapshot> document) {
    id = document.data.id;
    instructions = document.data[Fields.instructions];
    orderLocation = document.data[Fields.orderLocation];
    roomTableNumber = document.data[Fields.roomTableNumber];
    grandTotal = document.data[Fields.grandTotal];
    orderDate = document.data[Fields.orderDate];
    status = document.data[Fields.status];
    confirmedDate = document.data[Fields.confirmedDate];
    prepationDate = document.data[Fields.prepationDate];
    servedDate = document.data[Fields.servedDate];
    userId = document.data[Fields.userId];
    userRole = document.data[Fields.userRole];
    taxPercentage = document.data[Fields.taxPercentage];
    total = document.data[Fields.total];
  }
}
