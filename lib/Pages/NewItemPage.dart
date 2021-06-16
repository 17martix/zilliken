import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zilliken/Components/ZAppBar.dart';
import 'package:zilliken/Components/ZElevatedButton.dart';
import 'package:zilliken/Components/ZTextField.dart';
import 'package:zilliken/Helpers/SizeConfig.dart';
import 'package:zilliken/Helpers/Styling.dart';
import 'package:zilliken/Helpers/Utils.dart';
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

  String? selectedValue;
  String? name;
  String? unit;
  num? quantity;
  num? usedSince;
  num? usedTotal;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/Zilliken.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: buildAppBar(
            context, widget.auth, true, null, backFunction, null, null),
        body: body(),
      ),
    );
  }

  Widget body() {
    return SingleChildScrollView(
      // physics: BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: SizeConfig.diagonal * 0.9),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                height: SizeConfig.diagonal * 15,
                child: Center(
                  child: ZText(content: I18n.of(context).itemDescription),
                ),
              ),
              ZTextField(
                outsidePrefix: Icon(Icons.short_text_sharp),
                label: I18n.of(context).itemName,
                onSaved: (value) => name = value,
                validator: (value) => value == null || value.isEmpty
                    ? I18n.of(context).requit
                    : null,
              ),
              SizedBox(
                height: SizeConfig.diagonal * 3,
              ),
              ZTextField(
                outsidePrefix: Icon(Icons.inventory_2_sharp),
                label: I18n.of(context).quantity,
                onSaved: (value) {
                  if (value != null) {
                    quantity = num.parse(value);
                  }
                },
                validator: (value) => value == null || value.isEmpty
                    ? I18n.of(context).requit
                    : null,
              ),
              SizedBox(
                height: SizeConfig.diagonal * 3,
              ),
              ZTextField(
                outsidePrefix: Icon(FontAwesomeIcons.rulerCombined),
                label: I18n.of(context).unit,
                onSaved: (value) {
                  if (value != null) {
                    unit = value;
                  }
                },
                validator: (value) => value == null || value.isEmpty
                    ? I18n.of(context).requit
                    : null,
              ),
              SizedBox(
                height: SizeConfig.diagonal * 2,
              ),
              ZElevatedButton(
                onpressed: saveItem,
                child: ZText(
                  content: I18n.of(context).save,
                  color: Color(Styling.primaryBackgroundColor),
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
            content: ZText(content: I18n.of(context).noInternet),
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

          await widget.db.addInventoryItem(context, newStock);

          EasyLoading.dismiss();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: ZText(content: I18n.of(context).operationSucceeded),
            ),
          );

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
              content: ZText(content: e.toString()),
            ),
          );
        }
      }
    }
    Navigator.of(context).pop();
  }
}
