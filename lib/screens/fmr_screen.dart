import 'package:flutter/material.dart';

class FmrScreen extends StatefulWidget {
  @override
  _FmrScreenState createState() => _FmrScreenState();
}

class _FmrScreenState extends State<FmrScreen> {
  @override
  Widget build(BuildContext context) {
    Widget appBar = AppBar(
      title: Text(
        'FMR',
      ),
      centerTitle: true,
    );

    return Scaffold(
      appBar: appBar,
      body: Center(
        child: Text('This is FMR Screen!'),
      ),
    );
  }
}
