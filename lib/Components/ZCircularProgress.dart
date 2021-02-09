import 'package:flutter/material.dart';

class ZCircularProgress extends StatefulWidget {
  bool _isLoading;

  ZCircularProgress(this._isLoading);

  @override
  _ZCircularProgressState createState() => _ZCircularProgressState();
}

class _ZCircularProgressState extends State<ZCircularProgress> {
  @override
  Widget build(BuildContext context) {
    if (widget._isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }
}
