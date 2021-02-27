import 'package:zilliken/Helpers/SizeConfig.dart';
import 'package:flutter/material.dart';

import 'Styling.dart';

class NumericStepButton extends StatefulWidget {
  final int minValue;
  final int maxValue;
  int counter = 0;

  final ValueChanged<int> onChanged;

  NumericStepButton(
      {Key key,
      this.minValue = 0,
      this.maxValue = 10,
      this.onChanged,
      this.counter})
      : super(key: key);

  @override
  State<NumericStepButton> createState() {
    return _NumericStepButtonState();
  }
}

class _NumericStepButtonState extends State<NumericStepButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(SizeConfig.diagonal * 1),
      padding: EdgeInsets.all(SizeConfig.diagonal * 1),
      decoration: BoxDecoration(
          color: Color(Styling.accentColor),
          borderRadius: BorderRadius.circular(SizeConfig.diagonal * 3)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                if (widget.counter > widget.minValue) {
                  widget.counter--;
                }
                widget.onChanged(widget.counter);
              });
            },
            child: Icon(
              Icons.remove,
              color: Colors.white,
              size: SizeConfig.diagonal * 2,
            ),
          ),
          SizedBox(
            width: SizeConfig.diagonal * 1.1,
          ),
          Text(
            "${widget.counter}",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: SizeConfig.diagonal * 1.5,
            ),
          ),
          SizedBox(
            width: SizeConfig.diagonal * 1.1,
          ),
          InkWell(
            onTap: () {
              setState(() {
                if (widget.counter < widget.maxValue) {
                  widget.counter++;
                }
                widget.onChanged(widget.counter);
              });
            },
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: SizeConfig.diagonal * 2,
            ),
          ),
        ],
      ),
    );
  }
}
