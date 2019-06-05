import 'dart:convert';
import 'dart:async';
import 'package:bsmart/screens/fmr/fmr_info_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FmrListScreen extends StatefulWidget {
  @override
  _FmrListScreenState createState() => _FmrListScreenState();
}

class _FmrListScreenState extends State<FmrListScreen> {
  var modules, doc;
  bool isLoading = true, isLoading2 = true;
  String userID, userName;

  Future<Null> getDocList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String server = (prefs.getString('server') ?? 'Unknow Server');
    userID = (prefs.getString('userID') ?? 'Unknow User');
    //final response = await http.get(server + '/fmr/getDocList.php?user=' + userID);
    final response =
        await http.get(server + '/fmr/getDocList.php?user='+userID+'&page=l');

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      isLoading2 = false;
      /*setState(() {
        modules = jsonResponse['results'];
      });*/
      doc = jsonResponse['results'];
      setState(() {});
    } else {

    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDocList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.white,
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
                                child: Text(
                                  doc[index]['no'],
                                  style: TextStyle(
                                    fontSize: 15.0,
                                  ),
                                ),
                              ),
                              Expanded(
                                //flex: 3,
                                child: Text(
                                  doc[index]['date'],
                                  style: TextStyle(
                                    fontSize: 15.0,
                                  ),
                                ),
                              ),
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
                                    left: 4.0, right: 8.0),
                                child: Text(
                                  'Charge to : ' + doc[index]['charge'],
                                  textAlign: TextAlign.left,
                                ),
                              ))
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
                                    left: 4.0, right: 8.0),
                                child: Text(
                                  doc[index]['reason'],
                                  textAlign: TextAlign.left,
                                ),
                              ))
                            ],
                          ),
                        ],
                      ),
                      trailing: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Container(
                          width: 35.0,
                          height: 35.0,
                          child: RaisedButton(
                            elevation: 6.0,
                            color: Colors.green[300],
                            padding: EdgeInsets.all(0.0),
                            shape: CircleBorder(),
                            child: Center(
                              child: Icon(
                                Icons.edit,
                                size: 20,
                                color: Colors.black38,
                              ),
                            ),
                            onPressed: () async {
                              var response = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          FmrInfoScreen(doc[index]['no'])));
                              getDocList();
                              setState(() {

                              });
                            },
                          ),
                        ),
                      ),
                      /*trailing: InkWell(
                        // this is the one you are looking for..........
                        onTap: () {},
                        child: new Container(
                          //width: 50.0,
                          //height: 50.0,
                          padding: const EdgeInsets.all(
                              10.0), //I used some padding without fixed width and height
                          decoration: new BoxDecoration(
                            shape: BoxShape
                                .circle, // You can use like this way or like the below line
                            //borderRadius: new BorderRadius.circular(30.0),
                            color: Colors.green,
                          ),
//                          child: new Text('5',
//                              style: new TextStyle(
//                                  color: Colors.white,
//                                  fontSize:
//                                      25.0)), // You can add a Icon instead of text also, like below.
                          child: new Icon(Icons.edit,
                              size: 25.0, color: Colors.black38),
                        ), //............
                      ),*/
                    ),
                  );
                },
                itemCount: doc != null ? doc.length : 0,
              ),
      ),
    );
  }
}
