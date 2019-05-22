import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info/device_info.dart';

import 'main_screen.dart';

// ignore: must_be_immutable
class LoginScreen extends StatefulWidget {
  String params;
  LoginScreen(this.params);
  @override
  _LoginScreenState createState() => _LoginScreenState(params);
}

Widget _buildContent(
    BuildContext context, List<DocumentSnapshot> snapshot, String token) {
  return ListView(
    children:
        snapshot.map((data) => _buildListItem(context, data, token)).toList(),
  );
}

Widget _buildListItem(
    BuildContext context, DocumentSnapshot data, String token) {
  final record = Record.fromSnapshot(data);
  return SingleChildScrollView(
    key: ValueKey(record.status),
    child: Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _buildAvatar(),
          _buildInfo(context, record.status, record.line1, record.line2,
              record.line3, record.line4, record.server, token),
        ],
      ),
    ),
  );
}

Widget _buildAvatar() {
  return Container(
    width: 155.0,
    height: 155.0,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white30),
      color: Colors.white,
    ),
    margin: const EdgeInsets.only(top: 75.0),
    padding: const EdgeInsets.all(5.0),
    child: ClipOval(
      //child: Image.asset(artist.avatar),
      child: Image(
        image: AssetImage('assets/images/logo_bsmart_02.png'),
        width: 100.0,
        height: 100.0,
      ),
    ),
  );
}

Widget _buildInfo(BuildContext context, String status, String line1,
    String line2, String line3, String line4, String server, String token) {
  TextEditingController ctrUsername = TextEditingController();
  TextEditingController ctrPassword = TextEditingController();

  Future<Null> doLogin() async {
    String os = Platform.operatingSystem;

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    String model;
    if (os == 'android') {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      model = androidInfo.model;
      print('Running on ${androidInfo.model}'); // e.g. "Moto G (4)"
    } else {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      model = iosInfo.utsname.machine;
      print('Running on ${iosInfo.utsname.machine}'); // e.g. "iPod7,1"
    }

    String versionCode;
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    versionCode = packageInfo.buildNumber;

    print('URL SERVICE:' +
        server +
        'checkLogin.php?user=' +
        ctrUsername.text +
        '&password=' +
        ctrPassword.text +
        '&appid=BSMART' +
        '&token=' +
        token +
        '&os=' +
        os +
        '&model=' +
        model +
        '&version=' +
        versionCode);
    final response = await http.post(server +
        'checkLogin.php?user=' +
        ctrUsername.text +
        '&password=' +
        ctrPassword.text +
        '&appid=BSMART' +
        '&token=' +
        token +
        '&os=' +
        os +
        '&model=' +
        model +
        '&version=' +
        versionCode);

    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      String status = map['results']['status'];
      if (status == '0') {
        String userID = ctrUsername.text;
        String userName = map['results']['name'];

        final prefs = await SharedPreferences.getInstance();
        prefs.setString('userID', userID);
        prefs.setString('userName', userName);
        prefs.setString('server', server);
        prefs.setString('token', token);
        prefs.setString('os', os);
        prefs.setString('model', model);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MainScreen()));
      } else {
        String vMsg = map['results']['message'];
        showDialog<Null>(
            context: context,
            builder: (BuildContext context) {
              return SimpleDialog(
                title: Text(
                  vMsg,
                ),
                children: <Widget>[
                  SimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Center(
                      child: const Text('OK',
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                  ),
                ],
              );
            });
      }
    } else {
      showDialog<Null>(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              title: const Text(
                'Connection Error!!!',
              ),
              children: <Widget>[
                SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Center(
                    child: const Text('OK',
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                ),
              ],
            );
          });
    }
  }

  void _doLogin() {
    if (ctrUsername.text.isEmpty || ctrPassword.text.isEmpty) {
      showDialog<Null>(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              title: const Text(
                'Please fill User ID and Password!!!',
              ),
              children: <Widget>[
                SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Center(
                    child: const Text('OK',
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                ),
              ],
            );
          });
    } else {
      doLogin();
    }
  }

  if (status == "1") {
    FocusNode _userFocus = new FocusNode();
    FocusNode _passwordFocus = new FocusNode();
    return Padding(
        padding: const EdgeInsets.only(top: 80.0, left: 60.0, right: 60.0),
        child: Form(
          child: Column(children: <Widget>[
            TextFormField(
              controller: ctrUsername,
              focusNode: _userFocus,
              textInputAction: TextInputAction.next,
              style: TextStyle(color: Colors.pinkAccent, fontSize: 20.0),
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.account_circle,
                  color: Colors.white,
                  size: 25.0,
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                labelText: 'User ID',
                labelStyle: new TextStyle(color: Colors.white, fontSize: 20.0),
              ),
              onFieldSubmitted: (v) {
                _userFocus.unfocus();
                FocusScope.of(context).requestFocus(_passwordFocus);
                ctrUsername.text = ctrUsername.text.toUpperCase();
              },
            ),
            const SizedBox(
              height: 10.0,
            ),
            TextFormField(
              controller: ctrPassword,
              focusNode: _passwordFocus,
              textInputAction: TextInputAction.done,
              style: TextStyle(color: Colors.pinkAccent, fontSize: 20.0),
              obscureText: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.lock,
                  color: Colors.white,
                  size: 25.0,
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                labelText: 'Password',
                labelStyle: new TextStyle(color: Colors.white, fontSize: 20.0),
              ),
            ),
            const SizedBox(
              height: 30.0,
            ),
            RaisedButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Login',
                    style: TextStyle(fontSize: 20.0, color: Colors.white),
                  ),
                ],
              ),
              color: Theme.of(context).primaryColor,
              elevation: 4.0,
              splashColor: Colors.white,
              shape: RoundedRectangleBorder(
                  side: BorderSide.none,
                  borderRadius: BorderRadius.circular(10.0)),
              onPressed: () {
                _doLogin();
              },
            ),
            /*Material(
              borderRadius: BorderRadius.all(const Radius.circular(30.0)),
              shadowColor: Colors.pink[500],
              elevation: 5.0,
              child: MaterialButton(
                minWidth: 290.0,
                height: 55.0,
                onPressed: () => _doLogin(),
                color: const Color.fromRGBO(247, 64, 106, 1.0),
                child: Text(
                  'Login',
                  style: new TextStyle(
                    color: Colors.white,
                    fontSize: 30.0,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),*/
          ]),
        ));
  } else {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            height: 75.0,
          ),
          Text(
            line1,
            style: const TextStyle(
              color: Colors.pinkAccent,
              fontWeight: FontWeight.bold,
              fontSize: 25.0,
            ),
          ),
          const SizedBox(
            height: 80.0,
          ),
          Text(
            line2,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontWeight: FontWeight.w500,
              fontSize: 17.0,
            ),
          ),
          Text(
            line3,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontWeight: FontWeight.w500,
              fontSize: 17.0,
            ),
          ),
          const SizedBox(
            height: 20.0,
          ),
          Container(
            color: Colors.white.withOpacity(0.85),
            margin: const EdgeInsets.symmetric(vertical: 16.0),
            width: 300.0,
            height: 1.0,
          ),
          const SizedBox(
            height: 20.0,
          ),
          Text(
            line4,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 17.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginScreenState extends State<LoginScreen> {
  String params;
  _LoginScreenState(this.params);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('config').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return LinearProgressIndicator();
          return Scaffold(
            body: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                //Image.asset(artist.backdropPhoto, fit: BoxFit.cover),
                Image(
                    image: AssetImage('assets/images/bsm_cover_01.jpg'),
                    fit: BoxFit.cover),
                BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
                  child: Container(
                    color: Colors.black.withOpacity(0.60),
                    child: _buildContent(
                        context, snapshot.data.documents, this.params),
                    //child: Text('Params:' + this.params),
                  ),
                ),
              ],
            ),
          );
        });
  }
}

class Record {
  final String status;
  final String line1;
  final String line2;
  final String line3;
  final String line4;
  final String server;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['status'] != null),
        assert(map['line1'] != null),
        assert(map['line2'] != null),
        assert(map['line3'] != null),
        assert(map['line4'] != null),
        assert(map['server'] != null),
        status = map['status'],
        line1 = map['line1'],
        line2 = map['line2'],
        line3 = map['line3'],
        line4 = map['line4'],
        server = map['server'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$status:$line1:$line2:$line3:$line4:$server>";
}
