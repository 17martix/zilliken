import 'OrderItem.dart';

class Order {
  String id;
  List<OrderItem> clientOrder;
  int orderLocation;
  String roomTableNumber;
  String instructions;
  double grandTotal;
  int orderDate;
  int confirmedDate;
  int prepationDate;
  int servedDate;
  String status;
  String userId;
  String userRole;
  int taxPercentage;
  int total;

  Order({
    this.id,
    this.instructions,
    this.clientOrder,
    this.orderLocation,
    this.roomTableNumber,
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
}
