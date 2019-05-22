import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  var modules;
  bool isLoading = true;
  String userID, userName, versionName, versionCode;

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
      setState(() {
        modules = jsonResponse['results'];
      });
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
      child: ListView(
        padding: EdgeInsets.zero,
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
          /*DrawerHeader(
            child: Text(
              'Drawer Header',
              style: TextStyle(fontSize: 30),
            ),
            decoration: BoxDecoration(
              color: Colors.pink[400],
            ),
          ),*/
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
            onTap: () {},
          ),
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
      ),
    );

    return Scaffold(
      appBar: appBar,
      body: RefreshIndicator(
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
      ),
      drawer: drawer,
    );
  }
}
