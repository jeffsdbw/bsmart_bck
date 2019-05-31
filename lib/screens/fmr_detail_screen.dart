import 'package:bsmart/screens/fmr_tracking_screen.dart';
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
  var doc, docDtl, dtl, updDtl;
  bool isLoading = true, isLoading2 = true;
  String dspDocNo = 'xxx',
      dspDocDate = 'xxx',
      dspDept = 'xxx',
      dspCharge = 'xxx',
      dspWh = 'xxx',
      dspUnit = 'xxx',
      dspReason = 'xxx',
      dspStatus = 'xxx',
      dspResponse = 'xxx',
      dspApv = 'xxx',
      dspRespCode = 'x';

  Future<void> updateDocStatus(String respCode, String reason) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String server = (prefs.getString('server') ?? 'Unknow Server');
    String userID = (prefs.getString('userID') ?? 'Unknow userID');
    String docNo = (prefs.getString('docNo') ?? 'Unknow DocNo.');
    bool success = false;
    String resStatus = "0",
        resMsg = "Error!",
        resTitle = "Error!",
        resBody = "Hello, I am showDialog!";
    print('Servive:' +
        server +
        'fmr/updateDocStatus.php?docno=' +
        docNo +
        '&user=NAPRAPAT' +
        '&prog=BSMARTAPP' +
        '&status=' +
        respCode +
        '&reason=' +
        reason);
    final response = await http
        //.get(server + 'fmr/getDocDetail.php?docno=1900000002&user=' + userID);
        .post(server +
            'fmr/updateDocStatus.php?docno=' +
            docNo +
            '&user=NAPRAPAT' +
            '&prog=BSMARTAPP' +
            '&status=' +
            respCode +
            '&reason=' +
            reason); //userID);

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      print('Update Doc Status:' + jsonResponse.toString());
      updDtl = jsonResponse['results'];
      resStatus = updDtl[0]['status'];
      if (resStatus == "0") {
        success = true;
        resTitle = 'Success!';
        if (updDtl[0]['msg'].isEmpty || updDtl[0]['msg'] == '') {
          if (respCode == '9') {
            resMsg = 'Cancel Success!';
          } else {
            resMsg = 'Approve Success!';
          }
        } else {
          resMsg = updDtl[0]['msg'];
        }
      } else {
        resMsg = 'Process Error!';
        print('Update Error:' + updDtl[0]['msg']);
      }
      //print('updDtl : ' + updDtl.toString());

      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(resTitle),
            content: Text(resMsg),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
//                  if (success) {
//                    Navigator.pushReplacement(
//                        context,
//                        MaterialPageRoute(
//                            builder: (context) => FmrTrackingScreen()));
//                  }
                },
              ),
            ],
          );
        },
      );
    } else {
      print('Connection Error!');
    }
  }

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
      dspApv = doc['header']['apv'];
      dspRespCode = doc['header']['responsecode'];
      docDtl = doc['detail'];
      print('doc : ' + doc.toString());
      print('docDtl : ' + docDtl.toString());
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

  Future<String> _asyncInputDialog(
      BuildContext context, String respCode) async {
    String reason = '';
    return showDialog<String>(
      context: context,
      barrierDismissible:
          false, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter cancel reason'),
          content: new Row(
            children: <Widget>[
              new Expanded(
                  child: new TextField(
                autofocus: true,
                decoration: new InputDecoration(
                    //labelText: 'Cancel Reason Detail',
                    hintText: 'Fill your cancel reason here!'),
                onChanged: (value) {
                  reason = value;
                },
              ))
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(
                'OK',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () {
                print('OK : ' + reason);
                Navigator.of(context).pop();
                updateDocStatus(respCode, reason);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double fontSize = 13.0;
    int chkLength;
    //int chkLength = dspDept.length;
    if (dspDept.isEmpty || dspDept == '') {
      chkLength = 2;
    } else {
      chkLength = dspDept.length;
    }

    if (chkLength == 2) {
      fontSize = 20.0;
    } else if (chkLength == 3) {
      fontSize = 15.0;
    } else if (chkLength == 4) {
      fontSize = 14.0;
    }
    bool chkWh = true, chkApv = true;
    if (dspWh.isEmpty || dspWh == "") {
      chkWh = false;
    }
    if (dspApv == '0') {
      chkApv = false;
    }
    return RefreshIndicator(
      onRefresh: getDocDetail,
      child: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Container(
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
                                child:
                                    Text(dspDocDate, textAlign: TextAlign.left),
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
                                  //child: Text('Unit : ' + dspUnit, textAlign: TextAlign.left),
                                  child: Text(' ', textAlign: TextAlign.left),
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
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 2.0, right: 2.0),
                                    child: chkApv
                                        ? RaisedButton(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Icon(
                                                  Icons.done,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(
                                                  width: 4.0,
                                                ),
                                                Text(
                                                  'Approve',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15.0,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            color: Colors.green,
                                            elevation: 4.0,
                                            splashColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                                side: BorderSide.none,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10.0)),
                                            onPressed: () {
                                              updateDocStatus(dspRespCode, '');
                                            },
                                          )
                                        : Text(
                                            dspStatus,
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              color: Colors.pink,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20.0,
                                            ),
                                          ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 2.0, right: 2.0),
                                    child: chkApv
                                        ? RaisedButton(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Icon(
                                                  Icons.cancel,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(
                                                  width: 4.0,
                                                ),
                                                Text(
                                                  'Cancel',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15.0,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            color: Colors.red,
                                            elevation: 4.0,
                                            splashColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                                side: BorderSide.none,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10.0)),
                                            onPressed: () {
                                              _asyncInputDialog(context, '9');
                                            },
                                          )
                                        : Text(' '),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[Text(dspWh)],
                                  ),
                                )
                              : SizedBox(
                                  width: 0.0,
                                ),
                          SizedBox(
                            height: 4.0,
                          ),
//                  Container(
//                    child: Text(
//                      dspReason,
//                      textAlign: TextAlign.start,
//                    ),
//                  ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Expanded(child: Text(dspReason))
                            ],
                          ),
                          SizedBox(
                            height: 4.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 4.0, bottom: 8.0, left: 4.0, right: 4.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                              flex: 2,
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
                              flex: 3,
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
                          chkApv
                              ? SizedBox(
                                  width: 0.0,
                                )
                              : Expanded(
                                  flex: 1,
                                  child: Container(
                                    color: Colors.pink,
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text(
                                        'RCV',
                                        style: TextStyle(color: Colors.white),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  )),
                        ],
                      ),
                    ),
                  ),
                ),
                new Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                    child: Card(
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemBuilder: (context, int index) {
                          return Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 4.0,
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                        flex: 2,
                                        child: Text(
                                          docDtl[index]['fscode'],
                                          textAlign: TextAlign.center,
                                        )),
                                    Expanded(
                                        flex: 3,
                                        child: Text(docDtl[index]['fsname'])),
                                    Expanded(
                                        flex: 1,
                                        child: Text(
                                          docDtl[index]['unit'],
                                          textAlign: TextAlign.center,
                                        )),
                                    chkApv
                                        ? SizedBox(
                                            width: 0.0,
                                          )
                                        : Expanded(
                                            flex: 1,
                                            child: Text(
                                              docDtl[index]['receive'],
                                              textAlign: TextAlign.center,
                                            )),
                                  ],
                                ),
                              ),
                              Divider(),
                            ],
                          );
                        },
                        itemCount: docDtl != null ? docDtl.length : 0,
                      ),
                    ),
                  ),
                ),
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
