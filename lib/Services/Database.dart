import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zilliken/Models/Category.dart';
import 'package:zilliken/Models/Fields.dart';
import 'package:zilliken/Models/MenuItem.dart';
import 'package:zilliken/Models/Order.dart';
import 'package:zilliken/Models/OrderItem.dart';
import 'package:zilliken/Models/UserProfile.dart';

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
      Fields.phoneNumber: order.phoneNumber,
      Fields.tableAdress: order.tableAdress,
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
            .collection(Fields.order)
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

  Future<Order> getOrder(String id) async {
    Order order;
    var document = databaseReference.collection(Fields.order).doc(id);
    await document.get().then((snapshot) {
      order = Order(
        id: document.id,
        orderLocation: snapshot[Fields.orderLocation],
        tableAdress: snapshot[Fields.tableAdress],
         phoneNumber: snapshot[Fields.phoneNumber],
        instructions: snapshot[Fields.instructions],
        grandTotal: snapshot[Fields.grandTotal],
        orderDate: snapshot[Fields.orderDate],
      );
    });

    return order;
  }

  Future<void> cancelOrder(String id) async {
    var document = databaseReference.collection(Fields.order).doc(id);
    var collection = databaseReference
        .collection(Fields.order)
        .doc(id)
        .collection(Fields.items);
    //await document.update({'status': 'deleted'});
    await collection.get().then((snapshots) async {
      for (DocumentSnapshot document in snapshots.docs) {
        document.reference.delete();
      }
      await document.delete();
    });
  }

  Future<List<OrderItem>> getOrderItems(String orderId) async {
    List<OrderItem> clientOrder;
    var collection = databaseReference
        .collection(Fields.order)
        .doc(orderId)
        .collection(Fields.items);
    await collection.get().then((snapshot) {
      snapshot.docs.map((DocumentSnapshot document) {
        MenuItem menuItem = MenuItem(
          id: document.data()[Fields.id],
          name: document.data()[Fields.name],
          category: document.data()[Fields.category],
          price: document.data()[Fields.price],
          rank: document.data()[Fields.rank],
          global: document.data()[Fields.global],
        );
        int count = document.data()[Fields.count];
        OrderItem orderItem = OrderItem(menuItem: menuItem, count: count);
        clientOrder.add(orderItem);
      });
    });

    return clientOrder;
  }

  Future<List<String>> getCategories() async {
    List<String> categories = new List();
    var collection = databaseReference.collection(Fields.category);
    await collection.get().then((snapshot) async {
      snapshot.docs.forEach((element) {
        categories.add(element.data()[Fields.name]);
      });
    });

    return categories;
  }

  Future<bool> profileExists(String userId) async {
    await databaseReference
        .collection(Fields.users)
        .doc(userId)
        .get()
        .then((snapshot) async {
      if (snapshot.exists) {
        return true;
      } else {
        return false;
      }
    });

    return false;
  }

  Future<UserProfile> getUserProfile(String id) async {
    UserProfile userProfile;
    var document = databaseReference.collection(Fields.users).doc(id);
    await document.get().then((snapshot) {
      String role = snapshot[Fields.role];
      int receiveNotifications = snapshot[Fields.receiveNotifications];

      userProfile = UserProfile(
        id: id,
        role: role,
        receiveNotifications: receiveNotifications,
      );
    });

    return userProfile;
  }

  Future<void> addItem(MenuItem menuItem) async {
    int global;
    int rank;
    await databaseReference
        .collection(Fields.menu)
        .orderBy(Fields.createdAt, descending: true)
        .limit(1)
        .get()
        .then((snapshot) async {
      if (snapshot.docs.isEmpty) {
        global = 1;
      } else {
        global = snapshot.docs[0].data()[Fields.global] + 1;
      }
    });

    await databaseReference
        .collection(Fields.menu)
        .where(Fields.category,isEqualTo: menuItem.category)
        .orderBy(Fields.createdAt, descending: true)
        .limit(1)
        .get()
        .then((snapshot) async {
      if (snapshot.docs.isEmpty) {
        rank = 1;
      } else {
        rank = snapshot.docs[0].data()[Fields.rank] + 1;
      }
    });

    var document = databaseReference.collection(Fields.menu).doc();
    await document.set({
      Fields.availability: 1,
      Fields.category: menuItem.category,
      Fields.name: menuItem.name,
      Fields.price: menuItem.price,
      Fields.createdAt: DateTime.now().millisecondsSinceEpoch.toInt(),
      Fields.rank:rank,
      Fields.global:global,
    });
  }

  Future<void> addCategoy(Category category) async {
    int rank;
    await databaseReference
        .collection(Fields.menu)
        .orderBy(Fields.createdAt, descending: true)
        .limit(1)
        .get()
        .then((snapshot) async {

      if (snapshot.docs.isEmpty) {
        rank = 1;
      } else {
        rank = snapshot.docs[0].data()[Fields.rank] + 1;
      }
    });

    var document = databaseReference.collection(Fields.category).doc();
    await document.set({
      Fields.name: category.name,
      Fields.createdAt: DateTime.now().millisecondsSinceEpoch.toInt(),
      Fields.rank:rank,
    });
  }

  Future<void> updateNotifications(String id, int isEnabled) async {
    var document = databaseReference.collection(Fields.users).doc(id);
    await document.update({Fields.receiveNotifications: isEnabled});
  }

  Future<void> updateAvailability(String id, int isEnabled) async {
    var document = databaseReference.collection(Fields.menu).doc(id);
    await document.update({Fields.availability: isEnabled});
  }

  Future<void> updateStatus(String id, Order order, int value) async {
    var document = databaseReference.collection(Fields.order).doc(id);
    int now = DateTime.now().millisecondsSinceEpoch.toInt();
    if (value == 0) {
      await document.update({Fields.status: Fields.pending, Fields.orderDate: now});
    } else if (value == 1) {
      await document.update({
        Fields.status: Fields.confirmed,
        Fields.confirmedDate: now,
      });
    } else if (value == 2) {
      await document.update({Fields.status: Fields.preparation, Fields.prepationDate: now});
    } else if (value == 3) {
      await document.update({Fields.status: Fields.served, Fields.servedDate: now});
    }
  }
}
