import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FmrScreen extends StatefulWidget {
  @override
  _FmrScreenState createState() => _FmrScreenState();
}

class _FmrScreenState extends State<FmrScreen> {
  var modules, doc;
  bool isLoading = true, isLoading2 = true;
  String userID, userName;

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
  }

  Future<Null> getDocList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String server = (prefs.getString('server') ?? 'Unknow Server');
    userID = (prefs.getString('userID') ?? 'Unknow User');
    //final response = await http.get(server + '/fmr/getDocList.php?user=' + userID);
    final response =
        await http.get(server + '/fmr/getDocList.php?user=NAPRAPAT');

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      print(jsonResponse);
      isLoading2 = false;
      /*setState(() {
        modules = jsonResponse['results'];
      });*/
      doc = jsonResponse['results'];
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
    getDocList();
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
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: () {
              print('Refresh FMR');
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
      //backgroundColor: Colors.white,
      appBar: appBar,
      body: RefreshIndicator(
        onRefresh: getDocList,
        child: isLoading2
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, int index) {
                  return Card(
                    //color: Colors.blue,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        //color: Colors.pink[100],
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  doc[index]['status'],
                                  style: TextStyle(
                                      color: Colors.pinkAccent,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(
                                  height: 8.0,
                                ),
                                Row(
                                  children: <Widget>[
                                    Text(
                                      'Dept. : ',
                                    ),
                                    Text(
                                      doc[index]['dept'],
                                      style: TextStyle(
                                          color: Colors.pink,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  doc[index]['no'],
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(
                                  height: 8.0,
                                ),
                                Row(
                                  children: <Widget>[
                                    Text(
                                      'Charge : ',
                                    ),
                                    Text(
                                      doc[index]['charge'],
                                      style: TextStyle(
                                          color: Colors.pink,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  doc[index]['date'],
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(
                                  height: 8.0,
                                ),
                                Container(
                                  width: 80.0,
                                  //color: Colors.green,
                                  alignment: Alignment(1.0, 0.0),
                                  child: Text(
                                    doc[index]['amount'],
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                itemCount: doc != null ? doc.length : 0,
              ),
      ),
      //body: Center(
      //  child: Text('This is FMR Screen!'),
      //),
      drawer: drawer,
    );
  }
}
