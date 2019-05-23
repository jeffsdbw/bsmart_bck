import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'epr_screen.dart';
import 'fmr_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  var modules;
  bool isLoading = true;
  String userID, userName, versionName, versionCode;

  int currentIndex = 0;
  List pages = [FmrScreen(), EprScreen()];

  Future<Null> getModules() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String server = (prefs.getString('server') ?? 'Unknow Server');
    userID = (prefs.getString('userID') ?? 'Unknow User');
    userName = (prefs.getString('userName') ?? 'Unknow Name');
    print('Check Server:' + server + 'getModule.php?user=' + userID);
    final response = await http.get(server + 'getModule.php?user=' + userID);

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

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    versionName = packageInfo.version;
    versionCode = packageInfo.buildNumber;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getModules();
  }

  @override
  Widget build(BuildContext context) {
    String dID = userID, dName = userName, dVersion = versionCode;
    if (dID == null || dID == '') {
      dID = 'XXX';
    }
    if (dName == null || dName == '') {
      dName = 'XXX';
    }
    if (dVersion == null || dVersion == '') {
      dVersion = 'XXX';
    }

    Widget appBar = AppBar(
      title: Text(
        'BSMART',
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
        ListTile(
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
            onTap: () {}),
        Expanded(
          flex: 2,
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
                      Divider(),
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
                          Navigator.pushNamed(
                              context, modules[position]['path']);
                        },
                      ),
                    ],
                  );
                } else if (position == modules.length) {
                  return Column(
                    children: <Widget>[
                      Divider(),
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
                        onTap: () {},
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
              icon: Icon(Icons.store),
              title: Text(
                'FMR',
                style: TextStyle(fontSize: 15.0),
              )),
          BottomNavigationBarItem(
              icon: Icon(Icons.view_list),
              title: Text('EPR', style: TextStyle(fontSize: 15.0))),
        ]);

    return Scaffold(
      appBar: appBar,
      /*body: RefreshIndicator(
        onRefresh: getModules,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Card(
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, int index) {
                    return Column(
                      children: <Widget>[
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.indigoAccent,
                            radius: 25.0,
                            child: Text(
                              modules[index]['short'],
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.0,
                                  color: Colors.white),
                            ),
                          ),
                          title: Text(
                            modules[index]['name'],
                            style: TextStyle(
                                fontSize: 17.0, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(modules[index]['info']),
                          trailing: IconButton(
                              icon: Icon(Icons.chevron_right), onPressed: null),
                          onTap: () {
                            //print('Module:' + modules[index]['path']);
                            Navigator.pushNamed(
                                context, modules[index]['path']);
                          },
                        ),
                        Divider(),
                      ],
                    );
                  },
                  itemCount: modules != null ? modules.length : 0,
                ),
              ),
      ),*/
      body: Center(
        child: Text('This is Main Screen!'),
      ),
      drawer: drawer,
      bottomNavigationBar: bottomNavBar,
    );
  }
}
