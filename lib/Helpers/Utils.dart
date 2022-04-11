import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zilliken/Models/Cart.dart';
import 'package:zilliken/Models/Category.dart';
import 'package:zilliken/Models/Fields.dart';
import 'package:zilliken/Models/MenuItem.dart';
import 'package:zilliken/Models/Order.dart';
import 'package:zilliken/Models/OrderItem.dart';

import '../i18n.dart';

OrderItem findOrderItem(List<OrderItem> list, String id) {
  return list.firstWhere((element) => element.menuItem.id == id);
}

bool isAlreadyOnTheOrder(List<OrderItem> list, String id) {
  try {
    findOrderItem(list, id);
    return true;
  } catch (e) {
    return false;
  }
}

String numberItems(context, List<OrderItem> order) {
  Cart cart = cartCount(order);
  if (cart.totalCount == 1)
    return "${cart.totalCount} ${I18n.of(context).item}";
  else
    return "${cart.totalCount} ${I18n.of(context).items}";
}

String priceItems(context, List<OrderItem> order) {
  Cart cart = cartCount(order);
  return "${I18n.of(context).total} : ${formatNumber(cart.totalPrice)} ${I18n.of(context).fbu}";
}

String priceItemsTotal(context, List<OrderItem> order) {
  Cart cart = cartCount(order);
  return "${formatNumber(cart.totalPrice)} ${I18n.of(context).fbu}";
}

int priceItemsTotalNumber(context, List<OrderItem> order) {
  Cart cart = cartCount(order);
  return cart.totalPrice;
}

String grandTotal(context, List<OrderItem> order, int taxPercentage) {
  Cart cart = cartCount(order);
  double tax = (taxPercentage / 100) * cart.totalPrice;
  double total = cart.totalPrice + tax;
  int roundedTotal = total.round();
  return "${formatNumber(roundedTotal)} ${I18n.of(context).fbu}";
}

double grandTotalNumber(context, List<OrderItem> order, int taxPercentage) {
  Cart cart = cartCount(order);
  double tax = (taxPercentage / 100) * cart.totalPrice;
  double total = cart.totalPrice + tax;
  return total;
}

Cart cartCount(List<OrderItem> order) {
  int totalCount = 0;
  int totalPrice = 0;
  for (int i = 0; i < order.length; i++) {
    totalCount += order[i].count;
    totalPrice += (order[i].menuItem.price * order[i].count);
  }

  return new Cart(totalCount: totalCount, totalPrice: totalPrice);
}

String appliedTax(context, List<OrderItem> order, int taxPercentage) {
  Cart cart = cartCount(order);
  double tax = (taxPercentage / 100) * cart.totalPrice;
  int roundedTax = tax.round();
  return "$taxPercentage% = ${formatNumber(roundedTax)} ${I18n.of(context).fbu}";
}

String appliedTaxFromTotal(context, int total, int taxPercentage) {
  double tax = (taxPercentage / 100) * total;
  int roundedTax = tax.round();
  return "$taxPercentage% = ${formatNumber(roundedTax)} ${I18n.of(context).fbu}";
}

String? orderCardTtle(context, Order order) {
  int orderLength = order.clientOrder.length;
  String? text;
  if (orderLength == 1) {
    text = "${order.clientOrder[0].menuItem.name}";
  } else if (orderLength == 2) {
    text =
        "${order.clientOrder[0].menuItem.name} ${I18n.of(context).and} ${order.clientOrder.length} ${I18n.of(context).moreItems}";
  } else if (orderLength > 2) {
    text =
        "${order.clientOrder[0].menuItem.name} ${I18n.of(context).and} ${order.clientOrder.length} ${I18n.of(context).moreItems}";
  }

  return text;
}

String? orderStatus(context, Order order) {
  String? text;
  if (order.status == Fields.pending) {
    text = "${I18n.of(context).pendingOrder}";
  } else if (order.status == Fields.confirmed) {
    text = "${I18n.of(context).confirmedOrder}";
  } else if (order.status == Fields.preparation) {
    text = "${I18n.of(context).orderPreparation}";
  } else if (order.status == Fields.served) {
    text = "${I18n.of(context).orderServed}";
  }

  return text;
}

List<String> getUserTags(String name, String phoneNumber) {
  List<String> searchIndex = [];

  searchIndex.addAll(createTags(name));
  searchIndex.addAll(createTags(phoneNumber));

  return searchIndex;
}

List<String> createTags(String text) {
  text = text.trim();
  text = text.toLowerCase();
  text = text.replaceAll(new RegExp(r'(?:_|[^\w\s])+'), '');
  List<String> list = [];
  String s = '';
  List<String> splitList = text.split(" ");

  for (int i = 0; i < splitList.length; i++) {
    list.add(splitList[i]);
    if (s == '') s = splitList[i];

    if (i > 0) {
      for (int j = i; j < splitList.length; j++) {
        s += " " + splitList[j];
        list.add(s);
      }
      s = splitList[i];
    }
  }

  //for (int i = 0; i < list.length; i++) print(list[i]);

  return list;
}

String itemTotal(context, OrderItem orderItem) {
  int total = orderItem.menuItem.price * orderItem.count;
  return "$total ${I18n.of(context).fbu}";
}

String itemTax(context, Order order) {
  var value = order.total * order.taxPercentage / 100;
  return "${order.taxPercentage}% = $value ${I18n.of(context).fbu}";
}

String? showRommTable(context, Order order) {
  String? text;
  if (order.orderLocation == 0)
    text = "${I18n.of(context).tableNumber} : ${order.tableAdress}";
  else if (order.orderLocation == 1)
    text = "${I18n.of(context).roomNumber} : ${order.tableAdress}";
  return text;
}

String capitalize(String text) {
  String firstLetter = text[0];
  firstLetter = firstLetter.toUpperCase();
  String remaining = text.substring(1);
  remaining = remaining.toLowerCase();
  return firstLetter + remaining;
}

Future<List<MenuItem>> getMenuItems() async {
  List<MenuItem> list = [];

  /*await new HttpClient()
      .getUrl( Uri.parse('http://foo.bar/foo.txt'))
      .then((HttpClientRequest request) async => await request.close())
      .then((HttpClientResponse response) async =>
          await response.pipe(new File('assets/menu.csv').openWrite()));*/

  /*File file = File('assets/menu.csv');
  list = file.readAsLinesSync().skip(1) // Skip the header row
      .map((line) {
    final parts = line.split(',');
    return MenuItem(
      name: parts[0],
      price: int.tryParse(parts[1]),
      category: parts[2],
      availability: int.tryParse(parts[3]),
      rank: int.tryParse(parts[4]),
      global: int.tryParse(parts[5]),
      imageName: parts[6],
    );
  }).toList();*/

  String text = await rootBundle.loadString('assets/menu.csv');
  list = LineSplitter.split(text).map((line) {
    final parts = line.split(',');
    return MenuItem(
      name: capitalize(parts[0]),
      price: int.parse(parts[1]),
      category: capitalize(parts[2]),
      availability: int.parse(parts[3]),
      rank: int.parse(parts[4]),
      global: int.parse(parts[5]),
      imageName: parts[6],
    );
  }).toList();

  return list;
}

Future<List<MenuItem>> getMenuItemsFromFile(File file) async {
  List<MenuItem> list = [];

  list = file.readAsLinesSync().skip(1) // Skip the header row
      .map((line) {
    final parts = line.split(',');
    return MenuItem(
      name: capitalize(parts[0]),
      price: int.parse(parts[1]),
      category: capitalize(parts[2]),
      availability: int.parse(parts[3]),
      rank: int.parse(parts[4]),
      global: int.parse(parts[5]),
      imageName: parts[6],
      isDrink: int.tryParse(parts[7]),
    );
  }).toList();

  return list;
}

Future<List<Category>> getCategoryListFromFile(File file) async {
  List<Category> list = [];

  list = file.readAsLinesSync().skip(1) // Skip the header row
      .map((line) {
    final parts = line.split(',');
    return Category(
      name: capitalize(parts[0]),
      rank: int.parse(parts[1]),
      imageName: parts[2],
    );
  }).toList();

  return list;
}

Future<List<Category>> getCategoryList() async {
  List<Category> list = [];

  /*await new HttpClient()
      .getUrl( Uri.parse('http://foo.bar/foo.txt'))
      .then((HttpClientRequest request) async => await request.close())
      .then((HttpClientResponse response) async =>
          await response.pipe(new File('assets/category.csv').openWrite()));*/

  /*File file = File('assets/category.csv');
  list = file.readAsLinesSync().skip(1) // Skip the header row
      .map((line) {
    final parts = line.split(',');
    return Category(
      name: parts[0],
      rank: int.tryParse(parts[1]),
      imageName: parts[2],
    );
  }).toList();*/

  String text = await rootBundle.loadString('assets/category.csv');
  list = LineSplitter.split(text).map((line) {
    final parts = line.split(',');
    return Category(
      name: capitalize(parts[0]),
      rank: int.parse(parts[1]),
      imageName: parts[2],
    );
  }).toList();

  return list;
}

String formatNumber(num unformatedNumber) {
  int number = unformatedNumber.toInt();
  String oldNumber = "$number";
  String newNumber = '';
  for (int i = oldNumber.length - 1; i >= 0; i--) {
    newNumber = oldNumber[i] + newNumber;
    if (i != oldNumber.length - 1 && i != 0) {
      int remaining = (oldNumber.length - i) % 3;
      if (remaining == 0) {
        newNumber = ' ' + newNumber;
      }
    }
  }
  return newNumber;
}

Future<bool> hasConnection() async {
  try {
    final result = await InternetAddress.lookup('google.com')
        .timeout(Duration(seconds: 10));
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return true;
    }
  } on SocketException catch (_) {
    return false;
  } catch (e) {
    return false;
  }
  return false;
}

String? getMapsKey() {
  String? key;
  if (Platform.isAndroid) {
    key = "REPLACE WITH ANDROID API KEY";
  } else if (Platform.isIOS) {
    key = "REPLACE WITH IOS API KEY";
  }

  return key;
}

String? formatInterVal(double number) {
  String? text;

  int a = number.round();
  String textNumber = a.toString();
  int length = textNumber.length;

  if (length < 4) {
    text = textNumber;
  } else if (length < 7) {
    text = textNumber.substring(0, length - 3) + 'k';
  } else if (length < 10) {
    text =
        '${textNumber.substring(0, length - 6)}.${textNumber.substring(1, length - 5)} M';
  } else {
    text = textNumber;
  }
  return text;
}

String searchReady(String text) {
  text = text.trim();
  text = text.toLowerCase();
  text = text.replaceAll(new RegExp(r'(?:_|[^\w\s])+'), '');
  return text;
}

String? commandePluriel(num count, context) {
  String? commande;
  if (count == 1) {
    commande = I18n.of(context).order;
  } else {
    commande = I18n.of(context).orders;
  }
  return commande;
}

Color colorsStatStock(int index) {
  late Color colorStock;

  if (index == 0) {
    colorStock = Colors.blue;
  } else if (index == 1) {
    colorStock = Colors.yellow;
  } else if (index == 2) {
    colorStock = Colors.purpleAccent;
  } else if (index == 3) {
    colorStock = Colors.lightGreen;
  } else if (index == 4) {
    colorStock = Colors.pink;
  } else {
    colorStock = Colors.black;
  }

  return colorStock;
}

List<String> getMenuTags(MenuItem menuItem) {
  List<String> searchIndex = [];

  searchIndex.addAll(createTags(menuItem.name));
  searchIndex.addAll(createTags(menuItem.category!));
  return searchIndex;
}
