// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: prefer_final_fields, public_member_api_docs, prefer_single_quotes, omit_local_variable_types, unnecessary_this

import 'dart:async';

import 'package:flutter/material.dart';

/// A  class generated by flappy_translator package containing localized strings
class I18n {
  String get appTitle => _getText("appTitle");

  String get menu => _getText("menu");

  String get orders => _getText("orders");

  String get error => _getText("error");

  String get loading => _getText("loading");

  String get total => _getText("total");

  String get tableNumber => _getText("tableNumber");

  String get orderDate => _getText("orderDate");

  String get item => _getText("item");

  String get items => _getText("items");

  String get fbu => _getText("fbu");

  String get roomNumber => _getText("roomNumber");

  String get pendingOrder => _getText("pendingOrder");

  String get confirmedOrder => _getText("confirmedOrder");

  String get orderPreparation => _getText("orderPreparation");

  String get orderServed => _getText("orderServed");

  String get and => _getText("and");

  String get moreItems => _getText("moreItems");

  String get order => _getText("order");

  String get orderInformation => _getText("orderInformation");

  String get billDetails => _getText("billDetails");

  static Map<String, String> _localizedValues;

  static Map<String, String> _enValues = {
    "appTitle": "Zilliken",
    "menu": "Menu",
    "orders": "Orders",
    "error": "Something went wrong",
    "loading": "Loading",
    "total": "Total",
    "tableNumber": "N. table",
    "orderDate": "Date",
    "item": "Item",
    "items": "Items",
    "fbu": "FBU",
    "roomNumber": "Room Number",
    "pendingOrder": "Order Pending",
    "confirmedOrder": "Order Confirmed",
    "orderPreparation": "Order Being Prepared",
    "orderServed": "Order Served",
    "and": "and",
    "moreItems": "More Items",
    "order": "Order",
    "orderInformation": "Informations",
    "billDetails": "Bill",
  };

  static Map<String, String> _frValues = {
    "appTitle": "Zilliken",
    "menu": "Menu",
    "orders": "Commandes",
    "error": "erreur survenue",
    "loading": "Chargement",
    "total": "Total",
    "tableNumber": "N. table",
    "orderDate": "Date",
    "item": "Article",
    "items": "Articles",
    "fbu": "FBU",
    "roomNumber": "Numero de Chambre",
    "pendingOrder": "Commande En Attente",
    "confirmedOrder": "Commande Confirmée",
    "orderPreparation": "Commande En Préparation",
    "orderServed": "Commande Servie",
    "and": "et",
    "moreItems": "Articles De Plus",
    "order": "Commande",
    "orderInformation": "Informations",
    "billDetails": "Facture",
  };

  static Map<String, Map<String, String>> _allValues = {
    "en": _enValues,
    "fr": _frValues,
  };

  I18n(Locale locale) {
    this._locale = locale;
    _localizedValues = null;
  }

  Locale _locale;

  static I18n of(BuildContext context) {
    return Localizations.of<I18n>(context, I18n);
  }

  String _getText(String key) {
    return _localizedValues[key] ?? '** $key not found';
  }

  Locale get currentLocale => _locale;

  String get currentLanguage => _locale.languageCode;

  static Future<I18n> load(Locale locale) async {
    final translations = I18n(locale);
    _localizedValues = _allValues[locale.toString()];
    return translations;
  }
}

class I18nDelegate extends LocalizationsDelegate<I18n> {
  const I18nDelegate();

  static final Set<Locale> supportedLocals = {
    Locale('en'),
    Locale('fr'),
  };

  @override
  bool isSupported(Locale locale) => supportedLocals.contains(locale);

  @override
  Future<I18n> load(Locale locale) => I18n.load(locale);

  @override
  bool shouldReload(I18nDelegate old) => false;
}
