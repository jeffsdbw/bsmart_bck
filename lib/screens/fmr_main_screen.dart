import 'dart:convert';
import 'dart:async';
import 'package:bsmart/main.dart';
import 'package:bsmart/screens/fmr_history_screen.dart';
import 'package:bsmart/screens/fmr_list_screen.dart';
import 'package:bsmart/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class FmrMainScreen extends StatefulWidget {
  @override
  _FmrMainScreenState createState() => _FmrMainScreenState();
}

class _FmrMainScreenState extends State<FmrMainScreen> {
  var modules, doc;
  bool isLoading = true, isLoading2 = true;
  String userID, userName, token;

  int currentIndex = 0;
  List pages = [FmrListScreen(), FmrHistoryScreen()];

  Future<Null> clearAllPref(String token) async {
    Navigator.of(context).pop();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.clear();
    exit(0);
  }

  Future<Null> getModules() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String server = (prefs.getString('server') ?? 'Unknow Server');
    userID = (prefs.getString('userID') ?? 'Unknow User');
    userName = (prefs.getString('userName') ?? 'Unknow Name');
    token = (prefs.getString('token') ?? 'Unknow Token');
    print(
        'Check Server:' + server + 'getModule.php?appid=BSMART&user=' + userID);
    final response =
        await http.get(server + 'getModule.php?appid=BSMART&user=' + userID);

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      print(jsonResponse);
      isLoading = false;
      /*setState(() {
        modules = jsonResponse['results'];
      });*/
      modules = jsonResponse['results'];
      setState(() {});
    } else {
      print('Connection Error!');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getModules();
  }

  @override
  Widget build(BuildContext context) {
    String dID = userID, dName = userName;
    if (dID == null || dID == '') {
      dID = 'XXX';
    }
    if (dName == null || dName == '') {
      dName = 'XXX';
    }

    Widget appBar = AppBar(
      title: Text(
        'FMR',
      ),
      centerTitle: true,
      actions: <Widget>[
        IconButton(
            icon: Icon(
              Icons.exit_to_app,
              color: Colors.white,
            ),
            onPressed: () {
              exit(0);
            }),
      ],
    );

    Widget drawer = Drawer(
        child: Column(
      children: <Widget>[
        UserAccountsDrawerHeader(
          currentAccountPicture: CircleAvatar(
            backgroundColor: Colors.white,
            backgroundImage: AssetImage('assets/images/logo_bsmart_02.jpg'),
          ),
          accountName: Text(
            dID,
            style: TextStyle(fontSize: 20.0),
          ),
          accountEmail: Text(
            dName,
            style: TextStyle(fontSize: 20.0),
          ),
          decoration: BoxDecoration(
            color: Colors.pink[400],
            image: DecorationImage(
              image: ExactAssetImage('assets/images/wdhead2.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        /*ListTile(
            leading: Icon(
              Icons.home,
              size: 35.0,
            ),
            title: Text(
              'Home',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              'Main Menu',
              style: TextStyle(fontSize: 15.0),
            ),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () {
              Navigator.pushNamed(context, '/main');
            }),*/
        Expanded(
          //flex: 2,
          child: ListView.builder(
              //itemCount: modules.length == null ? 2 : modules.length + 2,
              itemCount: modules != null ? modules.length + 2 : 2,
              padding: EdgeInsets.only(top: 0.0),
              itemBuilder: (context, position) {
                String chk =
                    position.toString() + ':' + modules.length.toString();
                if (position < modules.length) {
                  return Column(
                    children: <Widget>[
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey,
                          radius: 20.0,
                          child: Text(
                            modules[position]['short'],
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.0,
                                color: Colors.white),
                          ),
                        ),
                        title: Text(modules[position]['name'],
                            style: TextStyle(fontSize: 20.0)),
                        subtitle: Text(modules[position]['info'],
                            style: TextStyle(fontSize: 15.0)),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.pushNamed(
                              context, modules[position]['path']);
                        },
                      ),
                      Divider(),
                    ],
                  );
                } else if (position == modules.length) {
                  return Column(
                    children: <Widget>[
                      ListTile(
                        leading: Icon(
                          Icons.account_circle,
                          size: 35.0,
                        ),
                        title: Text(
                          'Profile',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Your profile',
                          style: TextStyle(fontSize: 15.0),
                        ),
                        trailing: Icon(Icons.keyboard_arrow_right),
                        onTap: () {},
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: <Widget>[
                      Divider(),
                      ListTile(
                        leading: Icon(
                          Icons.exit_to_app,
                          size: 35.0,
                        ),
                        title: Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Logout your account',
                          style: TextStyle(fontSize: 15.0),
                        ),
                        trailing: Icon(Icons.keyboard_arrow_right),
                        onTap: () {
                          clearAllPref(token);
                        },
                      ),
                    ],
                  );
                }
              }),
        ),
      ],
    ));

    Widget bottomNavBar = BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (int index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.list),
              title: Text(
                'List',
                style: TextStyle(fontSize: 15.0),
              )),
          BottomNavigationBarItem(
              icon: Icon(Icons.history),
              title: Text('History', style: TextStyle(fontSize: 15.0))),
        ]);

    return Scaffold(
      //backgroundColor: Colors.white,
      appBar: appBar,
      body: pages[currentIndex],
      drawer: drawer,
      bottomNavigationBar: bottomNavBar,
    );
  }
}
