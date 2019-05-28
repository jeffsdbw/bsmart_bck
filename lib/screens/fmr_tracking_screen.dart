import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

// ignore: must_be_immutable
class FmrTrackingScreen extends StatefulWidget {
  @override
  _FmrTrackingScreenState createState() => _FmrTrackingScreenState();
}

class _FmrTrackingScreenState extends State<FmrTrackingScreen> {
  var doc, docDtl, dtl;
  Map data, myMap;
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

  Future<Null> getDocTracking() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String server = (prefs.getString('server') ?? 'Unknow Server');
    String userID = (prefs.getString('userID') ?? 'Unknow userID');
    String docNo = (prefs.getString('docNo') ?? 'Unknow DocNo.');
    final response = await http
        //.get(server + 'fmr/getDocDetail.php?docno=1900000002&user=' + userID);
        .get(server +
            'fmr/getDocTracking.php?docno=' +
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
      docDtl = doc['detail'];
      print('doc : ' + doc.toString());
      print('docDtl : ' + docDtl.toString());

      /*
      data = json.decode(response.body);
      dtl = data['detail']; //returns a List of Maps
      for (var items in dtl) {
        //iterate over the list
        myMap = items; //store each map
        print('myMap:' + myMap['status']);
      }
      */
      setState(() {});
    } else {
      print('Connection Error!');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDocTracking();
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
    if (dspStatus == 'Approve' ||
        dspStatus == 'Receive' ||
        dspStatus == 'Cancel') {
      chkApv = false;
    }
    return Column(
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
                          child: chkApv
                              ? RaisedButton(
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
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  onPressed: () {
                                    print('Approve Detail!!!');
                                  },
                                )
                              : Text(' '),
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
                    children: <Widget>[Text(dspReason)],
                  ),
                  SizedBox(
                    height: 4.0,
                  ),
                ],
              ),
            ),
          ),
        ),
        new Expanded(
          child: RefreshIndicator(
            onRefresh: getDocTracking,
            child: Padding(
              padding: const EdgeInsets.only(left: 4.0, right: 4.0),
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Card(
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemBuilder: (context, int index) {
                          return Text('555');
                          /*
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
                              Expanded(
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
                    );*/
                        },
                        itemCount: docDtl != null ? docDtl.length : 0,
                      ),
                    ),
            ),
          ),
        ),
      ],
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
