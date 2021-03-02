import 'dart:io';
import 'dart:convert';

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
  return "${I18n.of(context).total} : ${cart.totalPrice} ${I18n.of(context).fbu}";
}

String priceItemsTotal(context, List<OrderItem> order) {
  Cart cart = cartCount(order);
  return "${cart.totalPrice} ${I18n.of(context).fbu}";
}

int priceItemsTotalNumber(context, List<OrderItem> order) {
  Cart cart = cartCount(order);
  return cart.totalPrice;
}

String grandTotal(context, List<OrderItem> order, int taxPercentage) {
  Cart cart = cartCount(order);
  double tax = (taxPercentage / 100) * cart.totalPrice;
  double total = cart.totalPrice + tax;
  return "${total} ${I18n.of(context).fbu}";
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
  return "${taxPercentage}% = ${tax} ${I18n.of(context).fbu}";
}

String appliedTaxFromTotal(context, int total, int taxPercentage) {
  double tax = (taxPercentage / 100) * total;
  return "${taxPercentage}% = ${tax} ${I18n.of(context).fbu}";
}

String orderCardTtle(context, Order order) {
  int orderLength = order.clientOrder.length;
  String text;
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

String orderStatus(context, Order order) {
  String text;
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

String itemTotal(context, OrderItem orderItem) {
  int total = orderItem.menuItem.price * orderItem.count;
  return "$total ${I18n.of(context).fbu}";
}

String itemTax(context, Order order) {
  var value = order.total * order.taxPercentage / 100;
  return "${order.taxPercentage}% = ${value} ${I18n.of(context).fbu}";
}

String showRommTable(context, Order order) {
  String text;
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
  List<MenuItem> list = List();

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
      price: int.tryParse(parts[1]),
      category: capitalize(parts[2]),
      availability: int.tryParse(parts[3]),
      rank: int.tryParse(parts[4]),
      global: int.tryParse(parts[5]),
      imageName: parts[6],
    );
  }).toList();

  return list;
}

Future<List<Category>> getCategoryList() async {
  List<Category> list = List();

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
      rank: int.tryParse(parts[1]),
      imageName: parts[2],
    );
  }).toList();

  return list;
}
