import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

// ignore: must_be_immutable
class FmrDetailScreen extends StatefulWidget {
  @override
  _FmrDetailScreenState createState() => _FmrDetailScreenState();
}

class _FmrDetailScreenState extends State<FmrDetailScreen> {
  var doc;
  bool isLoading = true, isLoading2 = true;
  String dspDocNo,
      dspDocDate,
      dspDept,
      dspCharge,
      dspWh,
      dspUnit,
      dspReason,
      dspStatus,
      dspResponse;

  Future<Null> getDocDetail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String server = (prefs.getString('server') ?? 'Unknow Server');
    String userID = (prefs.getString('userID') ?? 'Unknow userID');
    String docNo = (prefs.getString('docNo') ?? 'Unknow DocNo.');
    final response = await http
        //.get(server + 'fmr/getDocDetail.php?docno=1900000002&user=' + userID);
        .get(server +
            'fmr/getDocDetail.php?docno=' +
            docNo +
            '&user=NAPRAPAT'); //userID);

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      print(jsonResponse);
      isLoading = false;
      /*setState(() {
        modules = jsonResponse['results'];
      });*/
      doc = jsonResponse['results'];
      dspDocNo = doc['header']['no'];
      dspDocDate = doc['header']['date'];
      dspDept = doc['header']['dept'];
      dspCharge = doc['header']['charge'];
      dspWh = doc['header']['wh'];
      dspUnit = doc['header']['unit'];
      dspReason = doc['header']['reason'];
      dspStatus = doc['header']['status'];
      dspResponse = doc['header']['response'];
      //print('Doc No. : ' + dspDocNo);
      setState(() {});
    } else {
      print('Connection Error!');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDocDetail();
  }

  @override
  Widget build(BuildContext context) {
    double fontSize = 13.0;
    int chkLength = dspDept.length;
    if (chkLength == 2) {
      fontSize = 20.0;
    } else if (chkLength == 3) {
      fontSize = 15.0;
    } else if (chkLength == 4) {
      fontSize = 14.0;
    }
    bool chkWh = true;
    if (dspWh.isEmpty || dspWh == "") {
      chkWh = false;
    }
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            color: Colors.white,
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
                        dspDept,
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
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                          child: Text(
                        dspDocNo,
                        textAlign: TextAlign.left,
                      )),
                      Expanded(
                        child: Text(dspDocDate, textAlign: TextAlign.left),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Text('Charge to : ' + dspCharge,
                              textAlign: TextAlign.left),
                        ),
                        Expanded(
                          child: Text('Unit : ' + dspUnit,
                              textAlign: TextAlign.left),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            dspStatus,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: Colors.pink,
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                            ),
                          ),
                        ),
                        Expanded(
                          child: RaisedButton(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Icon(
                                  Icons.done,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 8.0,
                                ),
                                Text(
                                  'Approve',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            color: Colors.green,
                            elevation: 4.0,
                            splashColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                side: BorderSide.none,
                                borderRadius: BorderRadius.circular(10.0)),
                            onPressed: () {
                              print('Approve Detail!!!');
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  chkWh
                      ? Padding(
                          padding: EdgeInsets.only(top: 4.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[Text(dspWh)],
                          ),
                        )
                      : SizedBox(
                          width: 0.0,
                        ),
                  SizedBox(
                    height: 4.0,
                  ),
                  Container(
                    child: Text(
                      dspReason,
                      textAlign: TextAlign.start,
                    ),
                  ),
                  SizedBox(
                    height: 4.0,
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 4.0, left: 8.0, right: 8.0, bottom: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                      flex: 1,
                      child: Container(
                        color: Colors.pink,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            'FS Code',
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )),
                  Expanded(
                      flex: 1,
                      child: Container(
                        color: Colors.pink,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            'FS Name',
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )),
                  Expanded(
                      flex: 1,
                      child: Container(
                        color: Colors.pink,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            'QTY',
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )),
                  Expanded(
                      flex: 1,
                      child: Container(
                        color: Colors.pink,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            'Receive',
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ),
          Expanded(child: null),
        ],
      ),
    );

    /*
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 8.0, right: 8.0),
          color: Colors.white,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(child: null),
              Expanded(child: null),
              Expanded(child: null),
            ],
          ),
        ),
        Expanded(child: null),
      ],
    );
    */
  }
}
