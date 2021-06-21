import 'package:intl/intl.dart';
import 'package:zilliken/Helpers/Utils.dart';
import 'package:zilliken/Models/Order.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';

import '../i18n.dart';

class Receipt {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  sample(context, String agentName, String orderType, String tableAddressLabel,
      String tableAddress, String? phoneNumber, Order order) async {
    DateTime dateTime = DateTime.now();
    final DateFormat formatDate = DateFormat('dd/MM/yy');
    final DateFormat formatTime = DateFormat('HH:mm');
    //SIZE
    // 0- normal size text
    // 1- only bold text
    // 2- bold with medium text
    // 3- bold with large text
    //ALIGN
    // 0- ESC_ALIGN_LEFT
    // 1- ESC_ALIGN_CENTER
    // 2- ESC_ALIGN_RIGHT

//     var response = await http.get("IMAGE_URL");
//     Uint8List bytes = response.bodyBytes;
    bluetooth.isConnected.then((isConnected) {
      if (isConnected != null && isConnected == true) {
        bluetooth.printNewLine();
        bluetooth.printCustom(I18n.of(context).appTitle, 4, 1);
        bluetooth.printCustom(I18n.of(context).receipt, 4, 1);
        bluetooth.printNewLine();
        bluetooth.printCustom(formatDate.format(dateTime), 2, 1);
        bluetooth.printNewLine();
        bluetooth.printCustom(formatTime.format(dateTime), 2, 1);
        bluetooth.printNewLine();
        bluetooth.printLeftRight(
            "${I18n.of(context).agentName} : ", agentName, 1);
        bluetooth.printNewLine();
        bluetooth.printLeftRight(
            "${I18n.of(context).orderType} : ", orderType, 1);
        bluetooth.printNewLine();
        bluetooth.printLeftRight("$tableAddressLabel : ", tableAddress, 1);
        if (phoneNumber != null) {
          bluetooth.printNewLine();
          bluetooth.printLeftRight(
              "${I18n.of(context).fone} : ", phoneNumber, 1);
        }
        for (int i = 0; i < order.clientOrder.length; i++) {
          bluetooth.printNewLine();
          bluetooth.printLeftRight(
              '${order.clientOrder[i].menuItem.name} x ${order.clientOrder[i].count}',
              '${formatNumber(order.clientOrder[i].menuItem.price)} * ${order.clientOrder[i].count} = ${formatNumber(order.clientOrder[i].menuItem.price * order.clientOrder[i].count)} FBU',
              1);
        }

        bluetooth.printNewLine();
        bluetooth.printLeftRight("${I18n.of(context).taxCharge} : ",
            appliedTaxFromTotal(context, order.total, order.taxPercentage), 1);
        bluetooth.printNewLine();
        bluetooth.printLeftRight("${I18n.of(context).grandTotal} : ",
            '${formatNumber(order.grandTotal)} FBU', 1);
        bluetooth.printNewLine();
        bluetooth.printCustom("${I18n.of(context).thankYou} : ", 3, 1);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.paperCut();
      }
    });
  }
}
