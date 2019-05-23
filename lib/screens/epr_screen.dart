import 'package:flutter/material.dart';

class EprScreen extends StatefulWidget {
  @override
  _EprScreenState createState() => _EprScreenState();
}

class _EprScreenState extends State<EprScreen> {
  @override
  Widget build(BuildContext context) {
    Widget appBar = AppBar(
      title: Text(
        'EPR',
      ),
      centerTitle: true,
    );

    return Scaffold(
      appBar: appBar,
      body: Center(
        child: Text('This is EPR Screen!'),
      ),
    );
  }
}
