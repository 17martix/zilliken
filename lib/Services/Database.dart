import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/services.dart';
import 'package:zilliken/Helpers/Utils.dart';
import 'package:zilliken/Models/Call.dart';
import 'package:zilliken/Models/Address.dart';
import 'package:zilliken/Models/Category.dart';
import 'package:zilliken/Models/Fields.dart';
import 'package:zilliken/Models/MenuItem.dart';
import 'package:zilliken/Models/Order.dart';
import 'package:zilliken/Models/OrderItem.dart';
import 'package:zilliken/Models/Result.dart';
import 'package:zilliken/Models/Statistic.dart';
import 'package:zilliken/Models/Stock.dart';
import 'package:zilliken/Models/UserProfile.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:collection/collection.dart';

import '../i18n.dart';

class Database {
  final databaseReference = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  final String firebaseBucket = "gs://zilliken-914b2.appspot.com";

  Future<void> setToken(String userId, String? token) async {
    await databaseReference.collection(Fields.users).doc(userId).update({
      Fields.token: token,
    });
  }

  Future<GeoPoint?> getSourceAddress() async {
    GeoPoint? address;
    await databaseReference
        .collection(Fields.configuration)
        .doc(Fields.settings)
        .get()
        .then((snapshot) async {
      if (snapshot.exists) {
        address = snapshot.data()![Fields.address];
      }
    });

    return address;
  }

  Future<GeoPoint?> getDestinationAddress(String userId, String token) async {
    GeoPoint? geoPoint;
    await databaseReference
        .collection(Fields.users)
        .doc(userId)
        .get()
        .then((snapshot) async {
      if (snapshot.exists) {
        geoPoint = snapshot.data()![Fields.address];
      }
    });

    return geoPoint;
  }

  Future<String?> getUserRole(String userId) async {
    String? role;

    await databaseReference
        .collection(Fields.users)
        .doc(userId)
        .get()
        .then((snapshot) async {
      if (snapshot.exists) {
        role = snapshot.data()![Fields.role].toString();
      }
    });

    return role;
  }

  Future<String> createProfile(String userId, String token) async {
    String role = Fields.client;
    await databaseReference.collection(Fields.users).doc(userId).set({
      Fields.id: userId,
      Fields.role: role,
      Fields.receiveNotifications: 1,
      Fields.token: token,
      Fields.lastSeenAt: FieldValue.serverTimestamp(),
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
        taxPercentage = documentSnapshot.data()![Fields.percentage];
      }
    });
    return taxPercentage;
  }

  Future<String> placeOrder(Order order) async {
    var document = databaseReference.collection(Fields.order).doc();
    order.id = document.id;

    await document.set({
      Fields.id: order.id,
      Fields.orderLocation: order.orderLocation,
      Fields.phoneNumber: order.phoneNumber,
      Fields.tableAdress: order.tableAdress,
      Fields.instructions: order.instructions,
      Fields.grandTotal: order.grandTotal,
      Fields.status: order.status,
      Fields.orderDate: FieldValue.serverTimestamp(),
      Fields.confirmedDate: order.confirmedDate,
      Fields.preparationDate: order.preparationDate,
      Fields.servedDate: order.servedDate,
      Fields.userId: order.userId,
      Fields.userRole: order.userRole,
      Fields.taxPercentage: order.taxPercentage,
      Fields.total: order.total,
      Fields.geoPoint: order.geoPoint,
      Fields.addressName: order.addressName,
      Fields.deliveringOrderId: null,
      Fields.currentPoint: order.currentPoint,
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

  Future<Order?> getOrder(String id) async {
    Order? order;
    var document = databaseReference.collection(Fields.order).doc(id);
    await document.get().then((snapshot) async {
      List<OrderItem> items = await getOrderItems(id);
      order = Order.buildObject(snapshot);
      order?.clientOrder = items;
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

  Future<Result> createAccount(context, UserProfile userProfile) async {
    Result result =
        Result(isSuccess: false, message: I18n.of(context).operationFailed);
    DocumentReference newUserReference =
        databaseReference.collection(Fields.users).doc(userProfile.id);

    await newUserReference
        .set({
          Fields.id: userProfile.id,
          Fields.name: userProfile.name,
          Fields.role: userProfile.role,
          Fields.phoneNumber: userProfile.phoneNumber,
          Fields.tags:userProfile.tags,
          Fields.lastSeenAt: FieldValue.serverTimestamp(),
          Fields.createdAt: FieldValue.serverTimestamp(),
        })
        .whenComplete(() => result = Result(
            isSuccess: true, message: I18n.of(context).operationSucceeded))
        .catchError((error) => result = Result(
            isSuccess: false, message: I18n.of(context).operationFailed));

    return result;
  }

  Future<List<Address>> getAddressList(String userId) async {
    List<Address> addressList = [];
    var collection = databaseReference
        .collection(Fields.users)
        .doc(userId)
        .collection(Fields.addresses);

    QuerySnapshot querySnapshot = await collection.get();

    querySnapshot.docs.forEach((element) {
      Address address = Address.buildObject(element);
      addressList.add(address);
    });

    /* await collection.get().then((snapshot) {
      if (snapshot == null || snapshot.docs.length <= 0) {
        log("error for id $userId");
      }
      snapshot.docs.map((DocumentSnapshot document) {
        Address address = Address();
        log("address is ${document.data()[Fields.addressName]}");
        address.buildObject(document);
        addressList.add(address);
      });
    });*/

    return addressList;
  }

  Future<List<OrderItem>> getOrderItems(String orderId) async {
    List<OrderItem> clientOrder = [];
    var collection = databaseReference
        .collection(Fields.order)
        .doc(orderId)
        .collection(Fields.items);

    QuerySnapshot querySnapshot = await collection.get();

    querySnapshot.docs.forEach((element) {
      OrderItem orderItem = OrderItem.buildObject(element);
      clientOrder.add(orderItem);
    });

    /*await collection.get().then((snapshot) {
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
      });*/

    return clientOrder;
  }

  Future<List<String>> getCategories() async {
    List<String> categories = [];
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

  Future<UserProfile?> getUserProfile(String id) async {
    UserProfile? userProfile;
    var document = databaseReference.collection(Fields.users).doc(id);
    await document.get().then((snapshot) {
      String role = snapshot[Fields.role];

      userProfile = UserProfile(
        id: id,
        role: role,
        name: snapshot[Fields.name],
        phoneNumber: snapshot[Fields.phoneNumber],
        createdAt: snapshot[Fields.createdAt],
        lastSeenAt: snapshot[Fields.lastSeenAt],
        token: snapshot[Fields.token],
        tags : List.from(snapshot[Fields.tags]),
      );
    });

    return userProfile;
  }

  Future<void> addItem(MenuItem menuItem) async {
    int? global;
    int? rank;
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
        .where(Fields.category, isEqualTo: menuItem.category)
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
      Fields.createdAt: FieldValue.serverTimestamp(),
      Fields.rank: rank,
      Fields.global: global,
    });
  }

  Future<void> addCategoy(Category category) async {
    int? rank;
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
      Fields.createdAt: FieldValue.serverTimestamp(),
      Fields.rank: rank,
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

  Future<void> updateStatus(
      String id, int status, int value, num grandTotal, String userId) async {
    var document = databaseReference.collection(Fields.order).doc(id);

    if (value == 1) {
      await document.update({
        Fields.status: Fields.pending,
        Fields.orderDate: FieldValue.serverTimestamp(),
      });
    } else if (value == 2) {
      await document.update({
        Fields.status: Fields.confirmed,
        Fields.confirmedDate: FieldValue.serverTimestamp(),
      });
    } else if (value == 3) {
      await document.update({
        Fields.status: Fields.preparation,
        Fields.preparationDate: FieldValue.serverTimestamp(),
      });
    } else if (value == 4) {
      await document.update({
        Fields.status: Fields.served,
        Fields.servedDate: FieldValue.serverTimestamp(),
      });

      DateTime today = DateTime.now();
      Statistic newStatistic = Statistic(
        date: Timestamp.fromDate(DateTime(today.year, today.month, today.day)),
        total: grandTotal,
        
      
      );

      await databaseReference
          .collection(Fields.statistic)
          .where(Fields.date, isEqualTo: newStatistic.date)
          .get()
          .then((value) async {
        if (value != null && value.size > 0) {
          await databaseReference
              .collection(Fields.statistic)
              .doc(value.docs[0].id)
              .update({
            Fields.total: FieldValue.increment(newStatistic.total),
          });
        } else {
          DocumentReference statref =
              databaseReference.collection(Fields.statistic).doc();

          await statref.set({
            Fields.id: statref.id,
            Fields.total: newStatistic.total,
            Fields.date: newStatistic.date,
          });
        }
      });

      await databaseReference
          .collection(Fields.users)
          .doc(userId)
          .collection(Fields.statistic)
          .where(Fields.date, isEqualTo: newStatistic.date)
          .get()
          .then((value) async {
        if (value != null && value.size > 0) {
          await databaseReference
              .collection(Fields.users)
              .doc(userId)
              .collection(Fields.statistic)
              .doc(value.docs[0].id)
              .update({
            Fields.total: FieldValue.increment(newStatistic.total),
          });
        } else {
          DocumentReference statref = databaseReference
              .collection(Fields.users)
              .doc(userId)
              .collection(Fields.statistic)
              .doc();

          await statref.set({
            Fields.id: statref.id,
            Fields.total: newStatistic.total,
            Fields.date: newStatistic.date,
          });
        }
      });
    }
  }

  Future<void> sendData(File menu, File category) async {
    List<MenuItem> list = await getMenuItemsFromFile(menu);
    List<Category> catList = await getCategoryListFromFile(category);
    WriteBatch catBatch = databaseReference.batch();

    CollectionReference menuReference =
        databaseReference.collection(Fields.menu);

    await menuReference.get().then((snapshot) {
      snapshot.docs.forEach((element) {
        catBatch.delete(element.reference);
      });
    });

    CollectionReference categoryReference =
        databaseReference.collection(Fields.category);
    await categoryReference.get().then((snapshot) {
      snapshot.docs.forEach((element) {
        catBatch.delete(element.reference);
      });
    });

    for (int i = 0; i < catList.length; i++) {
      DocumentReference catRef =
          databaseReference.collection(Fields.category).doc();
      catBatch.set(catRef, {
        Fields.id: catRef.id,
        Fields.name: catList[i].name,
        Fields.rank: catList[i].rank,
        Fields.imageName: catList[i].imageName,
        Fields.createdAt: FieldValue.serverTimestamp(),
      });
    }
    await catBatch.commit();

    List<MenuItem> list1 = list.sublist(0, (list.length / 2).floor());
    List<MenuItem> list2 = list.sublist((list.length / 2).floor());
    WriteBatch batch1 = databaseReference.batch();
    WriteBatch batch2 = databaseReference.batch();

    for (int i = 0; i < list1.length; i++) {
      DocumentReference documentReference =
          databaseReference.collection(Fields.menu).doc();
      batch1.set(documentReference, {
        Fields.id: documentReference.id,
        Fields.name: list1[i].name,
        Fields.category: list1[i].category,
        Fields.price: list1[i].price,
        Fields.rank: list1[i].rank,
        Fields.global: list1[i].global,
        Fields.availability: list1[i].availability,
        Fields.imageName: list1[i].imageName,
        Fields.isDrink: list1[i].isDrink,
        Fields.createdAt: FieldValue.serverTimestamp(),
      });
    }
    await batch1.commit();

    for (int i = 0; i < list2.length; i++) {
      DocumentReference documentReference =
          databaseReference.collection(Fields.menu).doc();
      batch2.set(documentReference, {
        Fields.id: documentReference.id,
        Fields.name: list2[i].name,
        Fields.category: list2[i].category,
        Fields.price: list2[i].price,
        Fields.rank: list2[i].rank,
        Fields.global: list2[i].global,
        Fields.availability: list2[i].availability,
        Fields.imageName: list2[i].imageName,
        Fields.isDrink: list2[i].isDrink,
        Fields.createdAt: FieldValue.serverTimestamp(),
      });
    }
    await batch2.commit();
  }

  Future<void> loadData(File menu, File category) async {
    //List<MenuItem> list = await getMenuItemsFromFile(menu);
    List<Category> catList = await getCategoryListFromFile(category);
    WriteBatch batch = databaseReference.batch();

    /* CollectionReference menuReference =
          databaseReference.collection(Fields.menu);
  
      await menuReference.get().then((snapshot) {
        snapshot.docs.forEach((element) {
          batch.delete(element.reference);
        });
      });
  
      for (int i = 0; i < list.length; i++) {
        DocumentReference documentReference =
            databaseReference.collection(Fields.menu).doc();
        batch.set(documentReference, {
          Fields.id: documentReference.id,
          Fields.name: list[i].name,
          Fields.category: list[i].category,
          Fields.price: list[i].price,
          Fields.rank: list[i].rank,
          Fields.global: list[i].global,
          Fields.availability: list[i].availability,
          Fields.imageName: list[i].imageName,
          Fields.createdAt: FieldValue.serverTimestamp(),
        });
      }*/

    CollectionReference categoryReference =
        databaseReference.collection(Fields.category);
    await categoryReference.get().then((snapshot) {
      snapshot.docs.forEach((element) {
        batch.delete(element.reference);
      });
    });

    for (int i = 0; i < catList.length; i++) {
      DocumentReference catRef =
          databaseReference.collection(Fields.category).doc();
      batch.set(catRef, {
        Fields.id: catRef.id,
        Fields.name: catList[i].name,
        Fields.rank: catList[i].rank,
        Fields.imageName: catList[i].imageName,
        Fields.createdAt: FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();

    /* List<MenuItem> list = await getMenuItems();
      List<Category> catList = await getCategoryList();
      WriteBatch batch = databaseReference.batch();
  
      CollectionReference menuReference =
          databaseReference.collection(Fields.menu);
  
      await menuReference.get().then((snapshot) {
        snapshot.docs.forEach((element) {
          batch.delete(element.reference);
        });
      });
  
      for (int i = 0; i < list.length; i++) {
        DocumentReference documentReference =
            databaseReference.collection(Fields.menu).doc();
        batch.set(documentReference, {
          Fields.id: documentReference.id,
          Fields.name: list[i].name,
          Fields.category: list[i].category,
          Fields.price: list[i].price,
          Fields.rank: list[i].rank,
          Fields.global: list[i].global,
          Fields.availability: list[i].availability,
          Fields.imageName: list[i].imageName,
          Fields.createdAt: DateTime.now().millisecondsSinceEpoch,
        });
      }
  
      CollectionReference categoryReference =
          databaseReference.collection(Fields.category);
      await categoryReference.get().then((snapshot) {
        snapshot.docs.forEach((element) {
          batch.delete(element.reference);
        });
      });
  
      for (int i = 0; i < catList.length; i++) {
        DocumentReference catRef =
            databaseReference.collection(Fields.category).doc();
        batch.set(catRef, {
          Fields.id: catRef.id,
          Fields.name: catList[i].name,
          Fields.rank: catList[i].rank,
          Fields.imageName: catList[i].imageName,
          Fields.createdAt: DateTime.now().millisecondsSinceEpoch,
        });
      }
  
      await batch.commit();*/
  }

  Future<Result> updateImage(
    context,
    List<Asset> images,
    String name,
  ) async {
    Result result =
        Result(isSuccess: false, message: I18n.of(context).operationFailed);

    /* if (name == null || name == '' || name.isEmpty) {
        name = "${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
      }*/

    try {
      for (int i = 0; i < images.length; i++) {
        double imageDesiredWidth = 500;
        double getAspectRatio(double originalSize, double desiredSize) =>
            desiredSize / originalSize;
        final aspectRatio = getAspectRatio(
            images[i].originalWidth!.toDouble(), imageDesiredWidth);
        ByteData byteData = await images[i].getThumbByteData(
            (images[i].originalWidth! * aspectRatio).round(),
            (images[i].originalHeight! * aspectRatio).round(),
            quality: 60);

        // ByteData byteData = await images[i].getByteData();
        Uint8List imageData = byteData.buffer.asUint8List();
        Reference ref = storage.ref("images/$name");
        TaskSnapshot uploadTask = await ref.putData(imageData);

        String url = await uploadTask.ref.getDownloadURL();
      }
    } on FirebaseException catch (e) {
      result =
          Result(isSuccess: false, message: I18n.of(context).operationFailed);
    }
    return result;
  }

  Future<void> updateDetails(MenuItem menu) async {
    DocumentReference details =
        FirebaseFirestore.instance.collection(Fields.menu).doc(menu.id);
    await details.update({
      Fields.name: menu.name,
      Fields.price: menu.price,
    });
  }

  Future<void> addCall(Call call) async {
    DocumentReference doc =
        FirebaseFirestore.instance.collection(Fields.calls).doc();
    call.id = doc.id;
    await doc.set({
      Fields.id: call.id,
      Fields.hasCalled: call.hasCalled,
      Fields.createdAt: FieldValue.serverTimestamp(),
      Fields.total: call.order.total,
      Fields.taxPercentage: call.order.taxPercentage,
      Fields.userRole: call.order.userRole,
      Fields.userId: call.order.userId,
      Fields.status: call.order.status,
      Fields.servedDate: call.order.servedDate,
      Fields.preparationDate: call.order.preparationDate,
      Fields.confirmedDate: call.order.confirmedDate,
      Fields.orderDate: call.order.orderDate,
      Fields.grandTotal: call.order.grandTotal,
      Fields.instructions: call.order.instructions,
      Fields.phoneNumber: call.order.phoneNumber,
      Fields.tableAdress: call.order.tableAdress,
      Fields.orderLocation: call.order.orderLocation,
      Fields.orderId: call.order.id,
    });
  }

  Future<void> updateCall(Call call, bool hasCalled) async {
    DocumentReference doc =
        FirebaseFirestore.instance.collection(Fields.calls).doc(call.id);
    await doc.update({
      Fields.hasCalled: hasCalled,
    });
  }

  Future<void> deleteAddress(String userId, String addressId) async {
    var document = databaseReference
        .collection(Fields.users)
        .doc(userId)
        .collection(Fields.addresses)
        .doc(addressId);
    await document.delete();
  }

  Future<void> updateLocation(String orderId, GeoPoint geoPoint) async {
    var document = databaseReference.collection(Fields.order).doc(orderId);
    await document.update({
      Fields.currentPoint: geoPoint,
    });
  }

  Future<void> assignDelivery(String orderId, String userId) async {
    var document = databaseReference.collection(Fields.order).doc(orderId);
    await document.update({
      Fields.deliveringOrderId: userId,
    });
  }

  Future<void> addAddress(String userId, Address address) async {
    var document = databaseReference
        .collection(Fields.users)
        .doc(userId)
        .collection(Fields.addresses)
        .doc();
    address.id = document.id;
    await document.set({
      Fields.id: address.id,
      Fields.geoPoint: address.geoPoint,
      Fields.addressName: address.addressName,
      Fields.typedAddress: address.typedAddress,
      Fields.phoneNumber: address.phoneNumber,
    });
  }

  Future<Result> addInventoryItem(context, Stock stock) async {
    Result result =
        Result(isSuccess: false, message: I18n.of(context).operationFailed);
    DocumentReference inventory =
        databaseReference.collection(Fields.stock).doc();

    await inventory
        .set({
          Fields.id: inventory.id,
          Fields.name: stock.name,
          Fields.quantity: stock.quantity,
          Fields.unit: stock.unit,
          Fields.usedSince: stock.usedSince,
          Fields.usedTotal: stock.usedTotal,
          Fields.date: FieldValue.serverTimestamp(),
        })
        .whenComplete(() => result = Result(
            isSuccess: true, message: I18n.of(context).operationSucceeded))
        .catchError((error) => result = Result(
            isSuccess: false, message: I18n.of(context).operationFailed));

    return result;
  }

  Future<Result> updateInventoryItem(context, Stock stock) async {
    Result result =
        Result(isSuccess: false, message: I18n.of(context).operationFailed);
    DocumentReference inventory =
        databaseReference.collection(Fields.stock).doc(stock.id);

    await inventory
        .update({
          Fields.quantity: stock.quantity,
        })
        .whenComplete(() => result = Result(
            isSuccess: true, message: I18n.of(context).operationSucceeded))
        .catchError((error) => result = Result(
            isSuccess: false, message: I18n.of(context).operationFailed));
    return result;
  }

  Future<List<MenuItem>> getMenuItems(String stockId) async {
    List<MenuItem> menuItemList = [];
    var reference = databaseReference.collection(Fields.menu);

    await reference.get().then((QuerySnapshot snapshot) {
      if (snapshot != null && snapshot.docs.isNotEmpty) {
        snapshot.docs.forEach((element) async {
          MenuItem menuItem = MenuItem.buildObject(element);

          Stock? stock;
          if (menuItem.condiments != null) {
            stock = menuItem.condiments!.firstWhereOrNull((condiment) {
              return condiment.id == stockId;
            });

            if (stock == null) {
              menuItem.isChecked = false;
            } else {
              menuItem.isChecked = true;
            }
          } else {
            menuItem.isChecked = false;
          }

          menuItemList.add(menuItem);
        });
      } else {
        log('list empty');
      }
    });

    log('here');

    menuItemList.forEach((element) {
      log('menu name is ${element.name}');
    });

    return menuItemList;
  }

  Future<void> linkToStock(List<String> menuIdList, Stock stock) async {
    String text = stock.buildStringFromObject();

    WriteBatch batch = databaseReference.batch();

    menuIdList.forEach((id) {
      DocumentReference documentReference =
          databaseReference.collection(Fields.menu).doc(id);
      batch.update(documentReference, {
        Fields.condiments: text,
      });
    });

    await batch.commit();
  }
}
