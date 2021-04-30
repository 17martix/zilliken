import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:zilliken/Components/ZAppBar.dart';
import 'package:zilliken/Components/ZElevatedButton.dart';
import 'package:zilliken/Components/ZTextField.dart';
import 'package:zilliken/Helpers/SizeConfig.dart';
import 'package:zilliken/Helpers/Styling.dart';
import 'package:zilliken/Helpers/Utils.dart';
import 'package:zilliken/Models/Category.dart';
import 'package:zilliken/Models/Stock.dart';
import 'package:zilliken/Services/Authentication.dart';
import 'package:zilliken/Services/Database.dart';
import 'package:zilliken/Services/Messaging.dart';
import 'package:zilliken/i18n.dart';

import '../Components/ZText.dart';

class NewItemPage extends StatefulWidget {
  final Authentication auth;
  final Database db;
  final Messaging messaging;
  final String userId;
  final String userRole;

  NewItemPage({
    required this.auth,
    required this.db,
    required this.messaging,
    required this.userId,
    required this.userRole,
  });
  @override
  _NewItemPageState createState() => _NewItemPageState();
}

class _NewItemPageState extends State<NewItemPage> {
  void backFunction() {
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  List<String> unitList = [
    'Kilogram(s)',
    'Liter(s)',
    'Box(es)',
    'Bottle(s)',
    'Item(s)',
    'gram(s)'
  ];

  String? selectedValue;
  String? name;
  String? unit;
  num? quantity;
  num? usedSince;
  num? usedTotal;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      appBar: buildAppBar(
          context, widget.auth, true, null, backFunction, null, null),
      body: body(),
    );
  }

  Widget body() {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: SizeConfig.diagonal * 0.9),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                height: SizeConfig.diagonal * 15,
                child: Center(
                  child:  ZText(content:I18n.of(context).itemDescription),
                ),
              ),
              ZTextField(
                outsidePrefix:  ZText(content:I18n.of(context).name + ' :'),
                onSaved: (value) => name = value,
                validator: (value) => value == null || value.isEmpty
                    ? I18n.of(context).requit
                    : null,
              ),
              SizedBox(
                height: SizeConfig.diagonal * 3,
              ),
              ZTextField(
                outsidePrefix:  ZText(content:I18n.of(context).quantity + ' :'),
                onSaved: (value) {
                  if (value != null) {
                    quantity = num.parse(value);
                  }
                },
                validator: (value) =>
                  value == null ||  value.isEmpty ? I18n.of(context).requit : null,
              ),
              SizedBox(
                height: SizeConfig.diagonal * 3,
              ),
              DropdownButton(
                  hint:  ZText(content:'Select the Unit'),
                  value: selectedValue,
                  items: unitList.map((String value) {
                    return DropdownMenuItem<String>(
                        value: value,
                        child:  ZText(content:
                          value,
                        ));
                  }).toList(),
                  onChanged: (String? val) {
                    setState(() {
                      selectedValue = val;
                      unit = selectedValue;
                    });
                  }),
              SizedBox(
                height: SizeConfig.diagonal * 2,
              ),
              ZElevatedButton(
                onpressed: saveItem,
                child:  ZText(content:
                  I18n.of(context).save,
                 color: Color(Styling.textColor)
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void saveItem() async {
    final form = _formKey.currentState;

    if (form!.validate()) {
      form.save();
      EasyLoading.show(status: I18n.of(context).loading);

      bool isOnline = await hasConnection();
      if (!isOnline) {
        EasyLoading.dismiss();

       ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:  ZText(content:I18n.of(context).noInternet),
          ),
        );
      } else {
        try {
          Stock newStock = Stock(
              name: name!,
              quantity: quantity!,
              unit: unit!,
              usedSince: 0,
              usedTotal: 0);
          setState(() {});
          await widget.db.addInventoryItem(context, newStock);

          EasyLoading.dismiss();

          setState(() {
            _formKey.currentState!.reset();
          });
        } on Exception catch (e) {
          //print('Error: $e');

          EasyLoading.dismiss();
          setState(() {
            _formKey.currentState!.reset();
          });

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:  ZText(content:e.toString()),
            ),
          );
        }
      }
    }
  }
}
