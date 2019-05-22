import 'dart:io' show Platform; //at the top
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:bsmart/screens/main_screen.dart';
import 'package:bsmart/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool chkToken = false;
  String textValue = 'Hello World!';
  FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  String userID = 'No User';
  bool chkUser = false;

  Future<Null> getPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userID = (prefs.getString('userID') ?? 'No User');
    if (userID != 'No User') {
      chkUser = true;
    }
  }

  @override
  // ignore: must_call_super
  void initState() {
    getPref();
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
    });
    firebaseMessaging.getToken().then((token) {
      update(token);
    });
  }

  void update(String token) {
    print('Token :' + token);
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

    if (os == 'android') {
      chkAndroid = true;
    } else {
      chkAndroid = false;
    }

    return new StreamBuilder(
        stream: Firestore.instance
            .collection('config')
            .document('main')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            //return new Text("Loading");
            return Center(
              child: Container(
                color: Colors.white,
                child: Text(
                  'Loading...',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(fontSize: 25.0, color: Colors.black),
                ),
              ),
            );
          }
          var userDocument = snapshot.data;
          //return new Text(userDocument["line1"]);
          bool chkClose = false;
          if (userDocument["status"] == '0') {
            chkClose = true;
          }
          String mainPath = userDocument["mainpath"];
          /*
          return Center(
            child: Text(
              userDocument["line1"],
              textDirection: TextDirection.rtl,
            ),
          );*/

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              scaffoldBackgroundColor: Colors.white70,
              primaryColor: Colors.pink,
              accentColor: Colors.amber,
              //cursorColor: Colors.white,
            ),
            title: 'BSMART ',
            home: chkClose
                ? LoginScreen(textValue)
                : chkUser
                    ? MainScreen()
                    : chkAndroid
                        ? chkToken
                            ? LoginScreen(textValue)
                            : Center(
                                child: Scaffold(
                                body: Center(
                                    child: Text('MainToken:' + textValue)),
                              ))
                        : LoginScreen(textValue),
          );
        });

    /*
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white70,
        primaryColor: Colors.pink,
        accentColor: Colors.amber,
        //cursorColor: Colors.white,
      ),
      title: 'Approval ',
      home: chkUser
          ? MainScreen()
          : chkAndroid
              ? chkToken
                  ? LoginScreen(textValue)
                  : Center(
                      child: Scaffold(
                      body: Center(child: Text('MainToken:' + textValue)),
                    ))
              : LoginScreen(textValue),
    );
    */
  }
}
