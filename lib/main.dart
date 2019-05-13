import 'dart:io' show Platform;  //at the top
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
//import 'package:fmr/screens/home_screen.dart';
import 'package:bsmart/screens/login_screen.dart';
//import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  bool chkToken = false;
  String textValue = 'Hello World!';
  FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    firebaseMessaging.configure(onLaunch: (Map<String, dynamic> msg) {
      print('onLaunch called');
    }, onResume: (Map<String, dynamic> msg) {
      print('onResume called');
    }, onMessage: (Map<String, dynamic> msg) {
      print('onMessage called');
    });
    firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, alert: true, badge: true));
    firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings setting) {
      print('IOS Setting Registed $setting');
    }
    );
    firebaseMessaging.getToken().then((token) {
      update(token);
    });
  }

  void update(String token) {
    print('Token :'+token);
    textValue = token;
    //final prefs = await SharedPreferences.getInstance();
    //prefs.setString('token', token);
    chkToken = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    String os = Platform.operatingSystem; //in your code
    bool chkAndroid;

    if(os=='android'){
      chkAndroid = true;
    } else {
      chkAndroid = false;
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white70,
        primaryColor: Colors.pink,
        accentColor: Colors.amber,
        //cursorColor: Colors.white,
      ),
      title: 'Approval ',
      /*home:
      chkToken
          ? LoginScreen(textValue)
          : Center(
          child: Scaffold(
            body: Center(child: Text('MainToken:' + textValue)),
          )),*/
      home: chkAndroid?
      chkToken
          ? LoginScreen(textValue)
          : Center(
          child: Scaffold(
            body: Center(child: Text('MainToken:' + textValue)),
          ))
          : LoginScreen(textValue),
      /*home: Center(
          child: Scaffold(
        body: Center(child: Text('OS:'+os+'\n'+'Token:' + textValue)),
      )),*/
      //home: LoginScreen(textValue),
      //home: HomeScreen(),
      /*home: chkToken
          ? LoginScreen(textValue)
          : Center(
          child: Scaffold(
            body: Text('MainToken:' + textValue),
          )),
      */
      //routes: <String, WidgetBuilder>{
      //  '/home': (BuildContext context) => HomeScreen(),
      //},

    );
  }
}
