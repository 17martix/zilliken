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

  String get total => _getText("total");

  String get ordPlace => _getText("ordPlace");

  String get instruction => _getText("instruction");

  String get restaurantOrder => _getText("restaurantOrder");

  String get roomOrder => _getText("roomOrder");


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
    "total": "Item total",
    "ordPlace": "Place order",
    "instruction": "Do you have instructions?",
    "restaurantOrder": "Restaurant Order",
    "roomOrder": "Room Order",

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
    "total": "Le total",
    "ordPlace": "Passer la Commande",
    "instruction": "Avez-vous des instructions?",
    "restaurantOrder": "Commande de Restaurant",
    "roomOrder": "Commande chambre",

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
