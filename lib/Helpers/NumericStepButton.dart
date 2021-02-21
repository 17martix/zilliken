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
    return Wrap(
      alignment: WrapAlignment.end,
      children: [
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  Icons.remove,
                  color: Theme.of(context).accentColor,
                ),
                padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
                iconSize: SizeConfig.diagonal * 2,
                color: Theme.of(context).primaryColor,
                onPressed: () {
                  setState(() {
                    if (widget.counter > widget.minValue) {
                      widget.counter--;
                    }
                    widget.onChanged(widget.counter);
                  });
                },
              ),
              Text(
                "${widget.counter}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(Styling.textColor),
                  fontSize: SizeConfig.diagonal * 1.5,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.add,
                  color: Theme.of(context).accentColor,
                ),
                padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
                iconSize: SizeConfig.diagonal * 2,
                color: Theme.of(context).primaryColor,
                onPressed: () {
                  setState(() {
                    if (widget.counter < widget.maxValue) {
                      widget.counter++;
                    }
                    widget.onChanged(widget.counter);
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
