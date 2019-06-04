import 'package:flutter/material.dart';

class InitialScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BSMART'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Center(child: Text('Welcome to',style: TextStyle(color: Colors.pink, fontSize: 30.0, fontWeight: FontWeight.bold),textAlign: TextAlign.center,)),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Center(child: Text('BSMART',style: TextStyle(color: Colors.pink, fontSize: 50.0, fontWeight: FontWeight.bold),textAlign: TextAlign.center,)),
          ),
          Center(child: Text('application!',style: TextStyle(color: Colors.pink, fontSize: 30.0, fontWeight: FontWeight.bold),textAlign: TextAlign.center,)),
        ],
      ),
    );
  }
}
