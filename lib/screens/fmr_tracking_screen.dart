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
  var doc, docDtl, dtl, rest;
  List<Detail> list;
  bool isLoading = true, isLoading2 = true;
  String dspDocNo = 'xxx',
      dspDocDate = 'xxx',
      dspDept = 'xxx',
      dspCharge = 'xxx',
      dspWh = 'xxx',
      dspUnit = 'xxx',
      dspReason = 'xxx',
      dspStatus = 'xxx',
      dspResponse = 'xxx';

  // Step Counter
  int current_step = 0;

  //List<Step> steps;

  List<Step> steps = [
    /*  Step(
      title: Text('Step 1'),
      content: Text('Hello!'),
      isActive: true,
    ),
    Step(
      title: Text('Step 2'),
      content: Text('World!'),
      isActive: true,
    ),
    Step(
      title: Text('Step 3'),
      content: Text('Hello World!'),
      state: StepState.complete,
      isActive: true,
    ), */
  ];

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

      rest = docDtl as List;
      list = rest.map<Detail>((json) => Detail.fromJson(json)).toList();

      print("List Size: ${list.length}");

      //int cnt = 0;

      current_step = list.length - 1;

      for (var n in list) {
        print('Hello ${n.status}');
        steps.add(Step(
          title: Text(
            n.status.toUpperCase(),
            softWrap: true,
          ),
          subtitle: Text(n.updateby + '  ' + n.date + ''),
          content: Text(' '),
          //content: Text(n.updateby + ' (' + n.date + ')'),
          isActive: true, // this is the issue
          state: StepState.indexed,
        ));
        //cnt = cnt + 1;
      }

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
    return RefreshIndicator(
      onRefresh: getDocTracking,
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
                                              print('Approve Detail!!!');
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
                                              print('Approve Detail!!!');
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
                new Expanded(
                  child: Card(
                    margin: EdgeInsets.only(
                        left: 8.0, right: 8.0, top: 4.0, bottom: 4.0),
                    color: Colors.white,
                    child: Stepper(
                      controlsBuilder: (BuildContext context,
                          {VoidCallback onStepContinue,
                          VoidCallback onStepCancel}) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[],
                          ),
                        );
                      },
                      currentStep: this.current_step,
                      steps: steps,
                      type: StepperType.vertical,
                      onStepTapped: (step) {
                        setState(() {
                          current_step = step;
                        });
                      },
                      /*onStepContinue: () {
                        setState(() {
                          if (current_step < steps.length - 1) {
                            current_step = current_step + 1;
                          } else {
                            current_step = 0;
                          }
                        });
                      },
                      onStepCancel: () {
                        setState(() {
                          if (current_step > 0) {
                            current_step = current_step - 1;
                          } else {
                            current_step = 0;
                          }
                        });
                      },*/
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

class Detail {
  String status;
  String date;
  String updateby;

  Detail({this.status, this.date, this.updateby});

  factory Detail.fromJson(Map<String, dynamic> json) {
    return Detail(
        status: json["status"], date: json["date"], updateby: json["updateby"]);
  }
}
