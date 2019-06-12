import 'package:bsmart/screens/fmr/fmr_tracking_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:math' as math;

// ignore: must_be_immutable
class FmrDetailScreen extends StatefulWidget {
  @override
  _FmrDetailScreenState createState() => _FmrDetailScreenState();
}

class _FmrDetailScreenState extends State<FmrDetailScreen> {
  var doc, docDtl, dtl, updDtl;
  bool isLoading = true, isLoading2 = true, chkCancel = false;
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
      dspRespCode = 'x',
      cancelReason = 'xxx',
      dspEmail = 'xxx',
      dspPhone = 'xxx';

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
    final response = await http
    //.get(server + 'fmr/getDocDetail.php?docno=1900000002&user=' + userID);
        .post(server +
        'fmr/updateDocStatus.php?docno=' +
        docNo +
        '&user=' +
        userID +
        '&prog=BSMARTAPP' +
        '&status=' +
        respCode +
        '&reason=' +
        reason); //userID);

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
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
      }

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
                  Navigator.of(context).pop('OK');
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
    } else {}
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
        '&user=' +
        userID); //userID);

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
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
      dspEmail = doc['header']['email'];
      dspPhone = doc['header']['phoneno'];
      dspRespCode = doc['header']['responsecode'];
      cancelReason = doc['header']['cancelreason'];
      if (cancelReason.isEmpty || cancelReason == '') {
      } else {
        chkCancel = true;
      }
      docDtl = doc['detail'];
      setState(() {});
    } else {}
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

    Widget makeHeader = SliverPersistentHeader(
      pinned: true,
      delegate: _SliverAppBarDelegate(
        minHeight: 30.0,
        maxHeight: 30.0,
        child: Container(
          padding: EdgeInsets.only(left: 4.0, right: 4.0),
          color: Colors.white,
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
                        style:
                        TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );


    return RefreshIndicator(
      onRefresh: getDocDetail,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : CustomScrollView(
            slivers: <Widget>[
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.all(4.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                              flex: 2,
                              child: Container(
                                color: Colors.white,
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
                              )),
                          Expanded(
                              flex: 8,
                              child: Container(
                                color: Colors.white,
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      dspDocNo,
                                      style: TextStyle(
                                          color: Colors.pink,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 4.0, bottom: 4.0),
                                      child: Text(dspDocDate),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 4.0, bottom: 4.0),
                                      child:
                                      Text('Charge to : ' + dspCharge),
                                    ),
                                    chkApv
                                        ? Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      children: <Widget>[
                                        RaisedButton(
                                          child: Padding(
                                            padding:
                                            const EdgeInsets.all(
                                                4.0),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .center,
                                              mainAxisSize:
                                              MainAxisSize.min,
                                              children: <Widget>[
                                                Icon(
                                                  Icons.done,
                                                  color: Colors.white,
                                                ),
                                              ],
                                            ),
                                          ),
                                          color: Colors.green,
                                          elevation: 4.0,
                                          splashColor: Colors.white,
                                          shape:
                                          RoundedRectangleBorder(
                                              side:
                                              BorderSide.none,
                                              borderRadius:
                                              BorderRadius
                                                  .circular(
                                                  10.0)),
                                          onPressed: () {
                                            updateDocStatus(
                                                dspRespCode, '');
                                          },
                                        ),
                                        SizedBox(
                                          width: 24.0,
                                          height: 4.0,
                                        ),
                                        RaisedButton(
                                          child: Padding(
                                            padding:
                                            const EdgeInsets.all(
                                                4.0),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .center,
                                              mainAxisSize:
                                              MainAxisSize.min,
                                              children: <Widget>[
                                                Icon(
                                                  Icons.cancel,
                                                  color: Colors.white,
                                                ),
                                              ],
                                            ),
                                          ),
                                          color: Colors.red,
                                          elevation: 4.0,
                                          splashColor: Colors.white,
                                          shape:
                                          RoundedRectangleBorder(
                                              side:
                                              BorderSide.none,
                                              borderRadius:
                                              BorderRadius
                                                  .circular(
                                                  10.0)),
                                          onPressed: () {
                                            _asyncInputDialog(
                                                context, '9');
                                          },
                                        ),
                                      ],
                                    )
                                        : Padding(
                                      padding: const EdgeInsets.only(
                                          top: 4.0, bottom: 4.0),
                                      child: Text(
                                        dspStatus,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: Colors.pink,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    chkCancel
                                        ? Padding(
                                        padding: const EdgeInsets.only(
                                            top: 4.0, bottom: 4.0),
                                        child: Text('Cancel Reason : ' +
                                            cancelReason))
                                        : SizedBox(
                                      height: 0.0,
                                    ),
                                    /*Padding(
                                      padding: const EdgeInsets.only(
                                          top: 4.0, bottom: 4.0),
                                      child: Text(dspEmail),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 4.0, bottom: 4.0),
                                      child: Text('Ext. ' + dspPhone),
                                    ),*/
                                    chkWh
                                        ? Padding(
                                        padding: const EdgeInsets.only(
                                            top: 4.0, bottom: 4.0),
                                        child: Text(dspWh))
                                        : SizedBox(
                                      width: 0.0,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 4.0, bottom: 4.0),
                                      child: Text(dspReason),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              makeHeader,
              // Yes, this could also be a SliverFixedExtentList. Writing
              // this way just for an example of SliverList construction.

              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return Container(
                    padding: EdgeInsets.only(left: 4.0, right: 4.0,top: 4.0),
                    color: Colors.white,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                                flex: 2,
                                child: Text(
                                  docDtl[index]['fscode'],
                                  textAlign: TextAlign.center,
                                )),
                            Expanded(
                                flex: 3,
                                child: Text(
                                  docDtl[index]['fsname'],
                                )),
                            Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 4.0),
                                  child: Text(
                                    docDtl[index]['unit'],
                                    textAlign: TextAlign.right,
                                  ),
                                )),
                            chkApv
                                ? SizedBox(
                              width: 0.0,
                            )
                                : Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 4.0),
                                  child: Text(
                                    docDtl[index]['receive'],
                                    textAlign: TextAlign.right,
                                  ),
                                )),
                          ],
                        ),
                        Divider(
                          //height: 1.0,
                        ),
                      ],
                    ),
                  );
                }, childCount: docDtl != null ? docDtl.length : 0,),
              ),


            ],
          ),
        ),
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

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    @required this.minHeight,
    @required this.maxHeight,
    @required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => math.max(maxHeight, minHeight);

  @override
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent)
  {
    return new SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}