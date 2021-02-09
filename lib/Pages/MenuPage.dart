import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zilliken/Helpers/NumericStepButton.dart';
import "package:zilliken/Helpers/Styling.dart";
import 'package:zilliken/Models/Category.dart';
import 'package:zilliken/Models/MenuItem.dart';
import 'package:zilliken/Models/OrderItem.dart';

class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  var commandes;
  var categories = FirebaseFirestore.instance
      .collection('category')
      .orderBy('rank', descending: false);
  String selectedCategory = "Tout";
  List<OrderItem> clientOrder;

  @override
  void initState() {
    super.initState();
    setState(() {
      commandesQuery('Tout');
    });
  }

  void commandesQuery(String category) {
    if (category == 'Tout') {
      commandes = FirebaseFirestore.instance.collection('menu');
    } else {
      commandes = FirebaseFirestore.instance
          .collection('menu')
          .where('category', isEqualTo: category);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          categoryList(),
          Expanded(
            child: menulist(),
          ),
        ],
      ),
    );
  }

  Widget categoryList() {
    return StreamBuilder<QuerySnapshot>(
      stream: categories.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }

        return SingleChildScrollView(
          child: Row(
            children: snapshot.data.docs.map((DocumentSnapshot document) {
              Category category = Category();
              category.buildObject(document);
              return categoryItem(category);
            }).toList(),
          ),
        );
      },
    );
  }

  Widget menulist() {
    return StreamBuilder<QuerySnapshot>(
      stream: commandes.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }

        return new Column(
          children: snapshot.data.docs.map((DocumentSnapshot document) {
            MenuItem menu = MenuItem();
            menu.buildObject(document);
            return item(menu);
          }).toList(),
        );
      },
    );
  }

  Widget item(MenuItem menu) {
    return Card(
      elevation: 16,
      child: ListTile(
        leading: Icon(Icons.restaurant_menu),
        title: Text(menu.name),
        subtitle: Text("${menu.price}"),
        trailing: Container(
          width: 100,
          child: FlatButton(
            onPressed: () {
              clientOrder.add(OrderItem(menuItem: menu, count: 1));
            },
            child: Container(child: Row(
              children: [
                Text("Add"),
                Text("+"),

              ],
            ),
            decoration: BoxDecoration(border: Border.all()),),

              ),
            ),
          ),
        
        
    );
  }

  Widget categoryItem(Category category) {
    return InkWell(
      onTap: () {
        setState(() {
          commandesQuery(category.name);
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              category.name,
              style: TextStyle(
                color: selectedCategory == category.name
                    ? Color(Styling.textColor)
                    : Color(Styling.textColor).withOpacity(0.5),
              ),
            ),
            if (selectedCategory == category.name)
              Container(
                height: 2,
                width: 20,
                color: Color(Styling.accentColor),
              ),
          ],
        ),
      ),
    );
  }
}
