import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  final jsModules;
  ProfileScreen({Key key, this.jsModules}) : super(key: key);
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var modules, jsUserinfo;

  bool isLoading = true, isLoadingI = true, chkUserImg = false;
  String userID = '', userName = '', token = '', userImg = '',versionCode = '';

  Future<Null> clearAllPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.clear();
    exit(0);
  }

  Future<Null> getModules() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String server = (prefs.getString('server') ?? 'Unknow Server');
    userID    = (prefs.getString('userID') ?? 'Unknow User');
    userName  = (prefs.getString('userName') ?? 'Unknow Name');
    final response =
    await http.get(server + 'getModule.php?appid=BSMART&user=' + userID);

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
//      print(jsonResponse);
      isLoading = false;
      modules = jsonResponse['results'];
      setState(() {});
    } else {
//      print('Connection Error!');
    }
  }

  Future<Null> getUserInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    versionCode = packageInfo.buildNumber;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String server = (prefs.getString('server') ?? 'Unknow Server');
    userID = (prefs.getString('userID') ?? 'Unknow User');
    userName = (prefs.getString('userName') ?? 'Unknow Name');
    token     = (prefs.getString('token') ?? 'Unknow Token');
    final response =
    await http.get(server + 'getUserInfo.php?appid=BSMART&user=' + userID + '&token='+token);

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      isLoadingI = false;
      jsUserinfo = jsonResponse['results'];
      userImg = jsUserinfo['image'];
      if(userImg.isEmpty||userImg==''){
        chkUserImg = false;
      } else {
        chkUserImg = true;
      }
      setState(() {});
    } else {
//      print('Connection Error!');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserInfo();
    getModules();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    String dID = userID, dName = userName;
    if (dID == null || dID == '') {
      dID = 'XXX';
    }
    if (dName == null || dName == '') {
      dName = 'XXX';
    }

    Widget appBar = AppBar(
      title: Text(
        'PROFILE',
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
                              Navigator.pushReplacementNamed(
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
                            onTap: () {
                              Navigator.of(context).pop();
                              Navigator.pushReplacementNamed(
                                  context, '/profile');
                            },
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
                              clearAllPref();
                            },
                          ),
                        ],
                      );
                    }
                  }),
            ),
          ],
        ));

    return Scaffold(
      appBar: appBar,
      body: isLoadingI
        ? Center(child: CircularProgressIndicator())
        : Container(
        color: Colors.white,
        child: jsUserinfo.length == 0 ? Center(child: CircularProgressIndicator()) : Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 24.0, bottom: 24.0),
                child:
                    chkUserImg
                    ?
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      backgroundImage: NetworkImage(userImg),
                      radius: 65.0,
                    ):
                    Icon(Icons.account_circle,size: 170.0, color: Colors.grey,),
              ),
              _rowProfileData('Account', jsUserinfo['account']),
              _rowProfileData('Name', jsUserinfo['name']),
              //_rowProfileData('Short Name', jsUserinfo['short']),
              _rowProfileData('Dept.', jsUserinfo['dept']),
              _rowProfileData('Email', jsUserinfo['email']),
              _rowProfileData('Login', jsUserinfo['lastlogin']),
              _rowProfileData('Session', jsUserinfo['lastsession']),
              new Padding(
                padding: const EdgeInsets.only(top: 24.0, bottom: 24.0),
                child: new Text(
                  "Version : "+versionCode,
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: drawer,
    );
  }

  Widget _rowProfileData(String textTitle, String textData) {
    return new Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        new Icon(
          Icons.place,
          color: Colors.white,
          size: 16.0,
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(textTitle,
              textAlign: TextAlign.right,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Text(textData,
            textAlign: TextAlign.left,
            style: TextStyle(color: Colors.pink, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
