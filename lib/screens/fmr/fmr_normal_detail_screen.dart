import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

// ignore: must_be_immutable
class FmrNormalDetailScreen extends StatefulWidget {
  String params;

  FmrNormalDetailScreen(this.params);

  @override
  _FmrNormalDetailScreenState createState() =>
      _FmrNormalDetailScreenState(params);
}

class _FmrNormalDetailScreenState extends State<FmrNormalDetailScreen> {
  String params;

  _FmrNormalDetailScreenState(this.params);

  var doc, docDtl;
  bool isLoading = true;
  String dspDocNo = 'xxx',
      dspDocDate = 'xxx',
      dspDept = 'xxx',
      dspCharge = 'xxx',
      dspReason = 'xxx',
      dspStorer = 'xxx',
      dspStorerName = 'xxx',
      dspDelType = 'xxx',
      dspDelRemark = 'xxx';

  Future<Null> getDocNormalDetail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String server = (prefs.getString('server') ?? 'Unknow Server');
    final response = await http
        //.get(server + 'fmr/getDocDetail.php?docno=1900000002&user=' + userID);
        .get(server + 'fmr/getDocNormalDetail.php?docno=' + params);

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
      dspReason = doc['header']['reason'];
      dspStorer = doc['header']['storerer'];
      dspStorerName = doc['header']['storername'];
      docDtl = doc['detail'];
      print('JSON : ' + doc.toString());
      setState(() {});
    } else {}
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDocNormalDetail();
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

    Widget appBar = AppBar(
      title: Text(
        'FMR Document',
      ),
      centerTitle: true,
      actions: <Widget>[
        IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: () {
              print('Refresh Button!');
            }),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar,
      body: RefreshIndicator(
        onRefresh: getDocNormalDetail,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: EdgeInsets.all(4.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Card(
                      elevation: 8.0,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Expanded(
                                  child: CircleAvatar(
                                    backgroundColor: Colors.pink,
                                    radius: 20.0,
                                    child: Text(
                                      dspDept,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: fontSize,
                                          color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                Expanded(
                                    child: Text(
                                  dspDocNo,
                                  style: TextStyle(
                                      color: Colors.pink,
                                      fontWeight: FontWeight.bold),
                                )),
                                Expanded(
                                    child: Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Text(
                                    dspDocDate,
                                    textAlign: TextAlign.right,
                                  ),
                                )),
                              ],
                            ),
                            SizedBox(
                              height: 4.0,
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Expanded(child: Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Text('Charge To',textAlign: TextAlign.right,),
                                )),
                                Expanded(child: Text(dspCharge, textAlign: TextAlign.center,)),
                                Expanded(child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(Icons.search, color: Colors.pink,),
                                  ],
                                )),
                              ],
                            ),
                            SizedBox(
                              height: 4.0,
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Expanded(child: Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Text('Storer',textAlign: TextAlign.right,),
                                )),
                                Expanded(child: Text(dspStorer, textAlign: TextAlign.center,)),
                                Expanded(child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(Icons.search, color: Colors.pink,),
                                  ],
                                )),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Text(dspCharge),
                    Text(dspReason),
                    Text(docDtl.toString()),
                  ],
                ),
              ),
      ),
    );
  }
}
