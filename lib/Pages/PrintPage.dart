import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zilliken/Components/ZAppBar.dart';
import 'package:zilliken/Components/ZElevatedButton.dart';
import 'package:zilliken/Helpers/SizeConfig.dart';
import 'package:zilliken/Helpers/Styling.dart';
import 'package:zilliken/Models/Order.dart';
import 'package:zilliken/Models/Receipt.dart';
import 'package:zilliken/Services/Authentication.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';

import '../Components/ZText.dart';
import '../i18n.dart';

class PrintPage extends StatefulWidget {
  final Authentication auth;
  final String agentName;
  final String orderType;
  final String tableAddressLabel;
  final String tableAddress;
  final String? phoneNumber;
  final Order order;

  PrintPage({
    required this.auth,
    required this.agentName,
    required this.orderType,
    required this.tableAddressLabel,
    required this.tableAddress,
    required this.phoneNumber,
    required this.order,
  });

  @override
  _PrintPageState createState() => _PrintPageState();
}

class _PrintPageState extends State<PrintPage> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _device;
  bool _connected = false;
  //String pathImage;
  Receipt receipt = Receipt();

  @override
  void initState() {
    super.initState();
    initPlatformState();
    // initSavetoPath();
  }

  /*initSavetoPath()async{
    //read and write
    //image max 300px X 300px
    final filename = 'yourlogo.png';
    var bytes = await rootBundle.load("assets/images/yourlogo.png");
    String dir = (await getApplicationDocumentsDirectory()).path;
    writeToFile(bytes,'$dir/$filename');
    setState(() {
     pathImage='$dir/$filename';
   });
 }

  //write to app path
 Future<void> writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return new File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
 }*/

  Future<void> initPlatformState() async {
    bool? isConnected = await bluetooth.isConnected;
    List<BluetoothDevice> devices = [];
    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: ZText(content: I18n.of(context).operationFailed)));
    }

    bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          setState(() {
            _connected = true;
          });
          break;
        case BlueThermalPrinter.DISCONNECTED:
          setState(() {
            _connected = false;
          });
          break;
        default:
          print(state);
          break;
      }
    });

    if (!mounted) return;
    setState(() {
      _devices = devices;
    });

    if (isConnected != null && isConnected == true) {
      setState(() {
        _connected = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
        image: AssetImage('assets/Zilliken.jpg'),
        fit: BoxFit.cover,
      )),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: buildAppBar(
          context,
          widget.auth,
          true,
          null,
          null,
          null,
          null,
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Card(
              color: Colors.white.withOpacity(0.7),
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(SizeConfig.diagonal * 1.5)),
              elevation: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.all(SizeConfig.diagonal * 1),
                    child: ZText(
                      content: I18n.of(context).print,
                      fontWeight: FontWeight.bold,
                      fontSize: SizeConfig.diagonal * 1.5,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.diagonal * 1,
                        vertical: SizeConfig.diagonal * 0.5),
                    child: Divider(height: 2.0, color: Colors.black),
                  ),
                  SizedBox(
                    height: SizeConfig.diagonal * 2.5,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: SizeConfig.diagonal * 1,
                      ),
                      ZText(
                        content: I18n.of(context).device,
                        fontWeight: FontWeight.bold,
                      ),
                      SizedBox(
                        width: SizeConfig.diagonal * 1,
                      ),
                      Expanded(
                        child: DropdownButton(
                          items: _getDeviceItems(),
                          onChanged: (BluetoothDevice? value) =>
                              setState(() => _device = value),
                          value: _device,
                          iconSize: SizeConfig.diagonal * 2.5,
                          style: TextStyle(
                            fontSize: SizeConfig.diagonal * 1.5,
                            color: Color(Styling.textColor),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: SizeConfig.diagonal * 2.5,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Expanded(
                        child: ZElevatedButton(
                          onpressed: () {
                            initPlatformState();
                          },
                          // bottomPadding: SizeConfig.diagonal * 1,
                          child: ZText(
                            content: I18n.of(context).refresh,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: SizeConfig.diagonal * 1,
                      ),
                      Expanded(
                        child: ZElevatedButton(
                          // bottomPadding: SizeConfig.diagonal * 1,
                          color: _connected
                              ? Color(Styling.accentColor)
                              : Color(Styling.primaryColor),
                          onpressed: _connected ? _disconnect : _connect,
                          child: ZText(
                            content: _connected
                                ? I18n.of(context).disconnect
                                : I18n.of(context).connect,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  ZElevatedButton(
                    // bottomPadding: SizeConfig.diagonal * 1,
                    onpressed: () {
                      receipt.sample(
                          context,
                          widget.agentName,
                          widget.orderType,
                          widget.tableAddressLabel,
                          widget.tableAddress,
                          widget.phoneNumber,
                          widget.order);
                      //Navigator.of(context).pop();
                    },
                    child: ZText(
                      content: I18n.of(context).print,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devices.isEmpty) {
      items.add(DropdownMenuItem(
        child: ZText(content: I18n.of(context).none),
      ));
    } else {
      _devices.forEach((device) {
        items.add(DropdownMenuItem(
          child: ZText(content: device.name!),
          value: device,
        ));
      });
    }
    return items;
  }

  void _connect() {
    if (_device == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        new SnackBar(
          content: ZText(
            content: I18n.of(context).noDevices,
            color: Colors.white,
          ),
        ),
      );
      //show(I18n.of(context).noDevices);
    } else {
      bluetooth.isConnected.then((isConnected) {
        if (!isConnected!) {
          bluetooth.connect(_device!).catchError((error) {
            setState(() => _connected = false);
          });
          setState(() => _connected = true);
        }
      });
    }
  }

  void _disconnect() {
    bluetooth.disconnect();
    setState(() => _connected = true);
  }

  Future show(
    String message, {
    Duration duration: const Duration(seconds: 3),
  }) async {
    await new Future.delayed(new Duration(milliseconds: 100));
    ScaffoldMessenger.of(context).showSnackBar(
      new SnackBar(
        content: ZText(
          content: message,
          color: Colors.white,
        ),
        duration: duration,
      ),
    );
  }

  /* @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
        image: AssetImage('assets/Zilliken.jpg'),
        fit: BoxFit.cover,
      )),
      child: Container(
        color: Color(Styling.primaryBackgroundColor).withOpacity(0.7),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child:  ZText(content:
              I18n.of(context).printingDisabled,
              textAlign: TextAlign.center,
              
                fontSize: SizeConfig.diagonal * 2,
             
            ),
          ),
        ),
      ),
    );
  }*/
  /*PrinterBluetoothManager _printerManager = PrinterBluetoothManager();
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
        null,null,
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
  }*/
}
