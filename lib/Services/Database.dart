import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zilliken/Models/Fields.dart';
import 'package:zilliken/Models/Order.dart';

class Database {
  final databaseReference = FirebaseFirestore.instance;

  Future<String> getUserRole(String userId) async {
    String role = Fields.client;
    await databaseReference
        .collection(Fields.users)
        .doc(userId)
        .get()
        .then((snapshot) async {
      if (snapshot.exists) {
        role = snapshot.data()[Fields.role].toString();
      } else {
        await createProfile(userId);
      }
    });

    return role;
  }

  Future<String> createProfile(
    String userId,
  ) async {
    String role = Fields.client;
    await databaseReference.collection(Fields.users).doc(userId).set({
      Fields.id: userId,
      Fields.role: role,
      Fields.receiveNotifications: 1,
    });

    return role;
  }

  Future<int> getTax() async {
    int taxPercentage = 0;
    await databaseReference
        .collection(Fields.configuration)
        .doc(Fields.taxes)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        taxPercentage = documentSnapshot.data()[Fields.percentage];
      }
    });
    return taxPercentage;
  }

  Future<String> placeOrder(Order order) async {
    var document = databaseReference.collection('orders').doc();

    await document.set({
      Fields.id: document.id,
      Fields.orderLocation: order.orderLocation,
      Fields.roomTableNumber: order.roomTableNumber,
      Fields.instructions: order.instructions,
      Fields.grandTotal: order.grandTotal,
      Fields.status: order.status,
      Fields.orderDate: order.orderDate,
      Fields.confirmedDate: order.confirmedDate,
      Fields.prepationDate: order.prepationDate,
      Fields.servedDate: order.servedDate,
      Fields.userId: order.userId,
      Fields.userRole: order.userRole,
      Fields.taxPercentage: order.taxPercentage,
      Fields.total: order.total,
    }).then((value) async {
      for (int i = 0; i < order.clientOrder.length; i++) {
        await databaseReference
            .collection(Fields.orders)
            .doc(document.id)
            .collection(Fields.items)
            .doc(order.clientOrder[i].menuItem.id)
            .set({
          Fields.count: order.clientOrder[i].count,
          Fields.id: order.clientOrder[i].menuItem.id,
          Fields.name: order.clientOrder[i].menuItem.name,
          Fields.category: order.clientOrder[i].menuItem.category,
          Fields.price: order.clientOrder[i].menuItem.price,
          Fields.rank: order.clientOrder[i].menuItem.rank,
          Fields.global: order.clientOrder[i].menuItem.global,
        });
      }
    });

    return document.id;
  }
}
