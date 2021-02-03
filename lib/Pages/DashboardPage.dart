import 'package:flutter/material.dart';
import 'package:zilliken/Components/ZAppBar.dart';
import 'package:zilliken/Helpers/Styling.dart';
import 'package:zilliken/Pages/MenuPage.dart';
import 'package:zilliken/Pages/OrdersPage.dart';
import 'package:zilliken/i18n.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: body(),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu_outlined),
            label: I18n.of(context).menu,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: I18n.of(context).orders,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(
          Styling.primaryColor,
        ),
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget body() {
    switch (_selectedIndex) {
      case 0:
        return MenuPage();
        break;
      case 1:
        return OrdersPage();
        break;
      default:
        return MenuPage();
        break;
    }
  }
}
