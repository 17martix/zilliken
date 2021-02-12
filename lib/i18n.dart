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

  String get taxCharge => _getText("taxCharge");

  String get sprkling => _getText("sprkling");

  String get orderKind => _getText("orderKind");

  String get bil => _getText("bil");

  String get ordPlace => _getText("ordPlace");

  String get instruction => _getText("instruction");

  String get restaurantOrder => _getText("restaurantOrder");

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

  String get ntable => _getText("ntable");

  String get livrdomicile => _getText("livrdomicile");

  String get gtotal => _getText("gtotal");

  String get addr => _getText("addr");

  String get fone => _getText("fone");

  String get requit => _getText("requit");

  String get cancelOrder => _getText("cancelOrder");

  String get orderDeleted => _getText("orderDeleted");

  String get pending => _getText("pending");

  String get confirmed => _getText("confirmed");

  String get preparing => _getText("preparing");

  String get served => _getText("served");

  String get number => _getText("number");

  String get updateStatus => _getText("updateStatus");

  static Map<String, String> _localizedValues;

  static Map<String, String> _enValues = {
    "appTitle": "Zilliken",
    "menu": "Menu",
    "orders": "Orders",
    "error": "Something went wrong",
    "loading": "Loading",
    "taxCharge": "Taxes & charges",
    "sprkling": "sparkiling water",
    "orderKind": "What kind of order is this?",
    "bil": "Bill",
    "ordPlace": "Place order",
    "instruction": "Do you have instructions?",
    "restaurantOrder": "Restaurant Order",
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
    "ntable": "Table Number",
    "livrdomicile": "Home delivery",
    "gtotal": "Grand Total",
    "addr": "Address",
    "fone": "Phone number",
    "requit": "Required",
    "cancelOrder": "Cancel Order",
    "orderDeleted": "Order Deleted",
    "pending": "Pending",
    "confirmed": "Confirmed",
    "preparing": "Preparing",
    "served": "Served",
    "number": "Number",
    "updateStatus": "Mettre à Jour Le Statut de la Commande",
  };

  static Map<String, String> _frValues = {
    "appTitle": "Zilliken",
    "menu": "Menu",
    "orders": "Commandes",
    "error": "erreur survenue",
    "loading": "Chargement",
    "taxCharge": "Taxes et charges",
    "sprkling": "Eau petillante",
    "orderKind": "Quel genre de Commande est-ce?",
    "bil": "Facture",
    "ordPlace": "Passer la Commande",
    "instruction": "Avez-vous des instructions?",
    "restaurantOrder": "Commande de Restaurant",
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
    "ntable": "Numero de table",
    "livrdomicile": "Livraison a domicile",
    "gtotal": "Grand total",
    "addr": "Adresse",
    "fone": "Numero de telephone",
    "requit": "Requis",
    "cancelOrder": "Annuler Commande",
    "orderDeleted": "Commande Annulé",
    "pending": "En Attente",
    "confirmed": "Confirmé",
    "preparing": "En Préparation",
    "served": "Servie",
    "number": "Nombre",
    "updateStatus": "Update The Status Of The Order",
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
