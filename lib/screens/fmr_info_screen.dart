import 'package:bsmart/screens/fmr_detail_screen.dart';
import 'package:bsmart/screens/fmr_tracking_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class FmrInfoScreen extends StatefulWidget {
  String params;
  FmrInfoScreen(this.params);
  @override
  _FmrInfoScreenState createState() => _FmrInfoScreenState(params);
}

class _FmrInfoScreenState extends State<FmrInfoScreen> {
  String params;
  _FmrInfoScreenState(this.params);

  Future<Null> SetDocNo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('docNo', params);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SetDocNo();
  }

  int currentIndex = 0;
  List pages = [FmrDetailScreen(), FmrTrackingScreen()];

  @override
  Widget build(BuildContext context) {
    Widget appBar = AppBar(
      title: Text(
        'FMR Document',
      ),
      centerTitle: true,
    );

    Widget bottomNavBar = BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (int index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.description),
              title: Text(
                'Detail',
                style: TextStyle(fontSize: 15.0),
              )),
          BottomNavigationBarItem(
              icon: Icon(Icons.face),
              title: Text('Tracking', style: TextStyle(fontSize: 15.0))),
        ]);

    return Scaffold(
      appBar: appBar,
      body: pages[currentIndex],
      bottomNavigationBar: bottomNavBar,
    );
  }
}
