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
                  double fontSize = 13.0;
                  int chkLength = doc[index]['dept'].length;
                  if (chkLength == 2) {
                    fontSize = 20.0;
                  } else if (chkLength == 3) {
                    fontSize = 15.0;
                  } else if (chkLength == 4) {
                    fontSize = 14.0;
                  }

                  return Card(
                    elevation: 8.0,
                    margin: EdgeInsets.only(
                        left: 8.0, right: 8.0, top: 4.0, bottom: 4.0),
                    child: ListTile(
                      leading: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: CircleAvatar(
                              backgroundColor: Colors.pink,
                              radius: 20.0,
                              child: Text(
                                doc[index]['dept'],
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: fontSize,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                      title: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                //flex: 3,
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      doc[index]['no'],
                                      style: TextStyle(
                                        fontSize: 15.0,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 4.0,
                                    ),
                                    Text('Charge : ' + doc[index]['charge'],
                                        style: TextStyle(
                                          fontSize: 15.0,
                                        )),
                                  ],
                                ),
                              ),
                              Expanded(
                                //flex: 3,
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      doc[index]['date'],
                                      style: TextStyle(
                                        fontSize: 15.0,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 4.0,
                                    ),
                                    Container(
                                      //color: Colors.purple,
                                      width: 80.0,
                                      alignment: Alignment(1.0, 0.0),
                                      child: Text(doc[index]['amount'],
                                          style: TextStyle(
                                            fontSize: 15.0,
                                            color: Colors.pink,
                                            fontWeight: FontWeight.bold,
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                              /*
                              Expanded(
                                flex: 2,
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      doc[index]['status'],
                                      style: TextStyle(
                                          color: Colors.pink,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15.0),
                                    )
                                  ],
                                ),
                              ),*/
                            ],
                          ),
                          SizedBox(
                            height: 4.0,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                  child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0, right: 8.0),
                                child: Text(
                                  doc[index]['reason'],
                                  textAlign: TextAlign.left,
                                ),
                              ))
                            ],
                          ),
                          /*
                          SizedBox(
                            height: 4.0,
                          ),
                          RaisedButton.icon(
                            onPressed: () {
                              print('History:' + doc[index]['no']);
                            },
                            icon: Icon(Icons.history),
                            label: Text('History'),
                          ),
                          */
                          /*
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: RaisedButton.icon(
                                  onPressed: () {
                                    print('History:' + doc[index]['no']);
                                  },
                                  icon: Icon(Icons.history),
                                  label: Text('History'),
                                ),
                              ),
                              Expanded(
                                child: RaisedButton.icon(
                                  onPressed: () {
                                    print('Response:' + doc[index]['no']);
                                  },
                                  icon: Icon(Icons.done),
                                  label: Text(doc[index]['response']),
                                ),
                              ),
                            ],
                          ),*/
                        ],
                      ),
                      trailing: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            doc[index]['status'],
                            style: TextStyle(
                                color: Colors.pink,
                                fontWeight: FontWeight.bold,
                                fontSize: 15.0),
                          ),
                          /*
                          Expanded(
                            child: Container(
                              child: Ink(
                                decoration: ShapeDecoration(
                                  color: Colors.pink[200],
                                  shape: CircleBorder(),
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.list),
                                  color: Colors.pink,
                                  onPressed: () {
                                    print("filled background");
                                  },
                                ),
                              ),
                            ),
                          ),
                          */
                          /*
                          GestureDetector(
                              onTap: () {
                                print('Detail:' + doc[index]['no']);
                              },
                              child: Icon(
                                Icons.list,
                                size: 30.0,
                              )),*/
                          /*
                          Expanded(
                            child: IconButton(
                              color: Colors.pink,
                              icon: Icon(
                                Icons.keyboard_arrow_right,
                                size: 30.0,
                              ),
                              tooltip: 'Detail',
                              onPressed: () {
                                print('Detail:' + doc[index]['no']);
                              },
                            ),
                          ),*/
                          //Text('Detail')
                        ],
                      ),
                    ),
                  );
                  /*
                  return Card(
                    margin: EdgeInsets.only(
                        left: 8.0, right: 8.0, top: 2.0, bottom: 2.0),
                    elevation: 8.0,
//                    shape: RoundedRectangleBorder(
//                        side: BorderSide.none,
//                        borderRadius: BorderRadius.circular(10.0)),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Container(
                          color: Colors.pink,
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    doc[index]['dept'],
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15.0),
                                  ),
                                ),
                              ),
                              Expanded(
                                  child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  doc[index]['status'],
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.0),
                                ),
                              )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );*/
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
