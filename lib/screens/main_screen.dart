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
    );
  }
}
