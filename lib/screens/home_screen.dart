import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    Widget appbar = AppBar(
      title: Text('BSMART'),
      centerTitle: true,
      actions: <Widget>[
        IconButton(
            icon: Icon(
              Icons.home,
              color: Colors.white,
            ),
            onPressed: () {
              print('Back Home!!!');
            }),
      ],
    );

    return Scaffold(
      appBar: appbar,
      body: Center(
        child: Text('This is Home Screen!!!'),
      ),
    );
  }
}
