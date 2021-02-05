import 'dart:async';

import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Center(
              child: Text(
                'Zilliken',
              ),
            ),
          ),
          progressLoading(),
        ],
      ),
    );
  }

  Widget progressLoading() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  
}
