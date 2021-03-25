import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zilliken/Models/Order.dart';

class Call {
  String id;
  bool hasCalled;
  Order order;
  Timestamp createdAt;

  Call({
    this.createdAt,this.hasCalled,this.id,this.order,
  });
}
