import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class EprScreen extends StatefulWidget {
  @override
  _EprScreenState createState() => _EprScreenState();
}

class _EprScreenState extends State<EprScreen> {
  var modules;
  bool isLoading = true;
  String userID, userName;

  Future<Null> getModules() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String server = (prefs.getString('server') ?? 'Unknow Server');
    userID = (prefs.getString('userID') ?? 'Unknow User');
    userName = (prefs.getString('userName') ?? 'Unknow Name');
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
        'EPR',
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
                        onTap: () {},
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
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image(
                image: NetworkImage(
                    'http://dsmservice.mistine.co.th/bsmart/image/kung.jpg'),
                height: 200.0,
              ),
              SizedBox(
                height: 8.0,
              ),
              Text(
                'e-PR system is coming soon!',
                style: TextStyle(color: Colors.red, fontSize: 20.0),
              ),
            ],
          ),
        ),
      ),
      drawer: drawer,
    );
  }
}
