import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  var modules;
  bool isLoading = true;

  Future<Null> getModules() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String server = (prefs.getString('server') ?? 'Unknow Server');
    String userID = (prefs.getString('userID') ?? 'Unknow User');
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
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getModules();
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
            // backgroundImage: NetworkImage(
            //     'https://randomuser.me/api/portraits/med/men/11.jpg'),
            /* backgroundColor: Colors.white70,
              child: Text(
                'SK',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 45.0,
                    color: Colors.white),
              ),*/
          ),
          accountName: Text(
            'User ID',
            style: TextStyle(fontSize: 20.0),
          ),
          accountEmail: Text(
            'User Name',
            style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
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
            Icons.people,
            color: Colors.pinkAccent,
          ),
          title: Text(
            'Customer List',
            style: TextStyle(
              fontSize: 25.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            'Customer Detail',
            style: TextStyle(fontSize: 20.0),
          ),
          trailing: Icon(Icons.keyboard_arrow_right),
          onTap: () {},
        ),
        ListTile(
          leading: Icon(
            Icons.store,
            color: Colors.pinkAccent,
          ),
          title: Text(
            'Customer Stock',
            style: TextStyle(
              fontSize: 25.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            'Customer Stock Checking',
            style: TextStyle(fontSize: 20.0),
          ),
          trailing: Icon(Icons.keyboard_arrow_right),
          onTap: () {},
        ),
        ListTile(
          leading: Icon(
            Icons.monetization_on,
            color: Colors.pinkAccent,
          ),
          title: Text(
            'Customer Credit Note',
            style: TextStyle(
              fontSize: 25.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            'Credit Note Document',
            style: TextStyle(fontSize: 20.0),
          ),
          trailing: Icon(Icons.keyboard_arrow_right),
          onTap: () {},
        ),
        Divider(),
        ListTile(
          leading: Icon(
            Icons.view_list,
            color: Colors.pinkAccent,
          ),
          title: Text(
            'Product List',
            style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            'Product Detail',
            style: TextStyle(fontSize: 20.0),
          ),
          trailing: Icon(Icons.keyboard_arrow_right),
          onTap: () {},
        ),
        ListTile(
          leading: Icon(
            Icons.local_shipping,
            color: Colors.pinkAccent,
          ),
          title: Text(
            'Product Stock',
            style: TextStyle(
              fontSize: 25.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            'Product Stock Detail',
            style: TextStyle(fontSize: 20.0),
          ),
          trailing: Icon(Icons.keyboard_arrow_right),
          onTap: () {},
        ),
        Divider(),
        ListTile(
          leading: Icon(
            Icons.account_circle,
            color: Colors.pinkAccent,
          ),
          title: Text(
            'Profile',
            style: TextStyle(
              fontSize: 25.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            'Your profile',
            style: TextStyle(fontSize: 20.0),
          ),
          trailing: Icon(Icons.keyboard_arrow_right),
          onTap: () {},
        ),
        Divider(),
        ListTile(
          leading: Icon(
            Icons.exit_to_app,
            color: Colors.pinkAccent,
          ),
          title: Text(
            'Logout',
            style: TextStyle(
              fontSize: 25.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            'Logout your account',
            style: TextStyle(fontSize: 20.0),
          ),
          trailing: Icon(Icons.keyboard_arrow_right),
          onTap: () {},
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
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
                            print('Module:' + modules[index]['path']);
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
