import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_basic/flutter_bluetooth_basic.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'dart:io' show Platform;
import 'package:zilliken/Components/ZAppBar.dart';
import 'package:zilliken/Services/Authentication.dart';

import '../i18n.dart';

class PrintPage extends StatefulWidget {
  final Authentication auth;
  final String orderType;
  final List<String> items;
  final String tableAddress;
  final String phoneNumber;
  final String orderDate;
  final String tax;
  final String total;

  PrintPage({
    Key key,
    @required this.orderType,
    @required this.items,
    @required this.tableAddress,
    @required this.phoneNumber,
    @required this.orderDate,
    @required this.tax,
    @required this.total,
    @required this.auth,
  }) : super(key: key);

  @override
  _PrintPageState createState() => _PrintPageState();
}

class _PrintPageState extends State<PrintPage> {
  PrinterBluetoothManager _printerManager = PrinterBluetoothManager();
  List<PrinterBluetooth> _devices = [];
  String _devicesMsg;
  BluetoothManager bluetoothManager = BluetoothManager.instance;

  void backFunction() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    log("error 3");
    return Scaffold(
      appBar: buildAppBar(
        context,
        widget.auth,
        true,
        null,
        backFunction,
        null,
      ),
      body: Stack(
        children: [
          _devices.isNotEmpty
              ? ListView.builder(
                  itemBuilder: (context, position) => ListTile(
                    onTap: () {
                      _startPrint(_devices[position]);
                    },
                    leading: Icon(Icons.print),
                    title: Text(_devices[position].name),
                    subtitle: Text(_devices[position].address),
                  ),
                  itemCount: _devices.length,
                )
              : Center(
                  child: Text(
                    _devicesMsg ?? I18n.of(context).oopsSomethingwentwrong,
                    style: TextStyle(fontSize: 24),
                  ),
                ),
        ],
      ),
    );
  }

  Future<void> _startPrint(PrinterBluetooth printer) async {
    _printerManager.selectPrinter(printer);
    final myTicket = await _ticket(PaperSize.mm58);
    final result = await _printerManager.printTicket(myTicket);
    print(result);
  }

  Future<Ticket> _ticket(PaperSize paper) async {
    final ticket = Ticket(paper);
    ticket.text(widget.orderType);
    ticket.text(widget.tableAddress);
    ticket.text(widget.phoneNumber);
    ticket.text(widget.orderDate);
    for (int i = 0; i < widget.items.length; i++) {
      ticket.text(widget.items[i]);
    }
    ticket.text(widget.tax);
    ticket.text(widget.total);

    ticket.cut();
    return ticket;
  }

  void initPrinter() {
    print('init printer');

    _printerManager.startScan(Duration(seconds: 2));
    _printerManager.scanResults.listen((event) {
      if (!mounted) return;
      setState(() => _devices = event);

      if (_devices.isEmpty)
        setState(() {
          _devicesMsg = I18n.of(context).noDevices;
        });
    });
  }

  @override
  void initState() {
    if (Platform.isIOS) {
      initPrinter();
    } else {
      bluetoothManager.state.listen((val) {
        print("state = $val");
        if (!mounted) return;
        if (val == 12) {
          print('on');
          initPrinter();
        } else if (val == 10) {
          print('off');
          setState(() {
            _devicesMsg = I18n.of(context).pleaseEnablebluetooth;
          });
        }
        print('state is $val');
      });
    }
    super.initState();
  }
}
