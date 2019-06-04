import 'dart:convert';
import 'dart:async';
import 'package:bsmart/screens/initial_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bsmart/screens/epr/epr_screen.dart';
import 'package:bsmart/screens/fmr/fmr_main_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  var init;
  bool isLoading = true;
  String userID, userName, versionName, versionCode;

  int currentIndex = 0;
  List pages = [InitialScreen(), FmrMainScreen(), EprScreen()];

  Future<Null> getInitScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String server = (prefs.getString('server') ?? 'Unknow Server');
    userID = (prefs.getString('userID') ?? 'Unknow User');
    final response = await http
        .get(server + 'getInitScreen.php?appid=BSMART&user=' + userID);

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      print(jsonResponse);
      isLoading = false;
      /*setState(() {
        modules = jsonResponse['results'];
      });*/
      init = jsonResponse['results'];
      currentIndex = init[0]['init'];
      setState(() {});
    } else {
      print('Connection Error!');
    }

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    versionName = packageInfo.version;
    versionCode = packageInfo.buildNumber;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getInitScreen();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: getInitScreen,
      child: Scaffold(
        body: pages[currentIndex],
      ),
    );
  }
}
