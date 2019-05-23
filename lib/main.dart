import 'dart:io' show Platform, exit; //at the top
import 'package:bsmart/screens/epr_screen.dart';
import 'package:bsmart/screens/fmr_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:bsmart/screens/main_screen.dart';
import 'package:bsmart/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info/package_info.dart';
import 'package:http/http.dart' as http;
//import 'package:flutter/rendering.dart';

void main() => runApp(MyApp());

/*
void main() {
  debugPaintSizeEnabled = true;
  runApp(MyApp());
}
*/

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
  String versionName, versionCode;

  Future<Null> getPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userID = (prefs.getString('userID') ?? 'No User');
    String token = (prefs.getString('token') ?? 'No Token');
    String server = (prefs.getString('server') ?? 'No Server');
    if (userID != 'No User') {
      chkUser = true;

      final response = await http.post(server +
          'updateInfo.php?user=' +
          userID +
          '&appid=BSMART' +
          '&token=' +
          token +
          '&version=' +
          versionCode);
    }
  }

  Future<Null> checkForceUpdate() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    versionName = packageInfo.version;
    versionCode = packageInfo.buildNumber;
    print('Check Version:' + versionCode + ':');
  }

  @override
  // ignore: must_call_super
  void initState() {
    checkForceUpdate();
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

  Future<Null> setServer(String server) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('server', server);
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
                  textDirection: TextDirection.ltr,
                  style: TextStyle(fontSize: 25.0, color: Colors.black),
                ),
              ),
            );
          }
          var userDocument = snapshot.data;
          //return new Text(userDocument["line1"]);
          setServer(userDocument["server"]);
          bool chkClose = false;
          if (userDocument["status"] == '0') {
            chkClose = true;
            print('Check Status : Close!');
          } else {
            print('Check Status : Open!');
          }
          bool chkVersion = false;
          if (userDocument["force_update"] == '1' &&
              int.parse(versionCode) < int.parse(userDocument["version"])) {
            chkVersion = true;
          }

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
            home: chkVersion
                ? Center(
                    child: Scaffold(
                    backgroundColor: Colors.white,
                    body: Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image(
                          image: AssetImage('assets/images/warning.png'),
                          height: 150.0,
                          width: 150.0,
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        Text(
                          'Your Application version : ' + versionCode,
                          style: TextStyle(fontSize: 20.0),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Please Update to Version : ' +
                              userDocument["version"],
                          style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.red),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        ButtonTheme(
                          minWidth: 200.0,
                          child: RaisedButton(
                            child: Text(
                              'OK',
                              style: TextStyle(
                                  fontSize: 20.0, color: Colors.white),
                            ),
                            color: Colors.pinkAccent,
                            elevation: 4.0,
                            splashColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                side: BorderSide.none,
                                borderRadius: BorderRadius.circular(10.0)),
                            onPressed: () {
                              exit(0);
                            },
                          ),
                        )
                      ],
                    )),
                  ))
                : chkClose
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
            routes: <String, WidgetBuilder>{
              '/main': (BuildContext context) => MainScreen(),
              '/fmr': (BuildContext context) => FmrScreen(),
              '/epr': (BuildContext context) => EprScreen(),
            },
          );
          /*
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
          */
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
