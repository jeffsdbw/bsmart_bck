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
  var doc, docDtl, dtl, rest, updDtl;
  List<Detail> list;
  bool isLoading = true, isLoading2 = true, chkCancel = false, chkImg = false;
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
      cancelReason = '';

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
        '&user=' + userID +
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
    } else {

    }
  }

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
        '&user='+userID); //userID);

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
      dspRespCode = doc['header']['responsecode'];
      dspApv = doc['header']['apv'];
      docDtl = doc['detail'];
      cancelReason = doc['header']['cancelreason'];
      if(cancelReason.isEmpty||cancelReason==''){

      } else {
        chkCancel = true;
      }

      rest = docDtl as List;
      list = rest.map<Detail>((json) => Detail.fromJson(json)).toList();

      current_step = list.length - 1;

      for (var n in list) {

        if(n.image.isEmpty||n.image==''){
          chkImg = false;
        } else {
          chkImg = true;
        }

        steps.add(Step(
          title: Text(
            n.status.toUpperCase(),
            softWrap: true,
          ),
          //subtitle: Text(n.updateby + '  ' + n.date),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(n.updateby),
              Text(n.date),
            ],
          ),
          //content: Text(' '),
          content:
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: chkImg
              ?Row(
               mainAxisAlignment: MainAxisAlignment.start,
               children: <Widget>[
                 Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: <Widget>[
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        backgroundImage: NetworkImage(n.image,),
                        radius: 30.0,
                      ),
                      Text(n.username, style: TextStyle(color: Colors.pink, fontWeight: FontWeight.bold),),
                      Text(n.dept),
                   ],
                 ),
               ],
               )
              :Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(n.username, style: TextStyle(color: Colors.pink, fontWeight: FontWeight.bold),),
                      Text(n.dept),
                    ],
                  ),
                ],
              ),
            ),
//          content:
//          chkImg
//              ?
//          Row(
//            mainAxisSize: MainAxisSize.max,
//            children: <Widget>[
//              CircleAvatar(
//                backgroundColor: Colors.white,
//                backgroundImage: NetworkImage(n.image,),
//                radius: 30.0,
//              ),
//              Padding(
//                padding: const EdgeInsets.only(left: 8.0),
//                child: Column(
//                  crossAxisAlignment: CrossAxisAlignment.start,
//                  children: <Widget>[
//                    Text(
//                      n.username,
//                      textAlign: TextAlign.left,
//                      style: TextStyle(
//                          fontWeight: FontWeight.bold,
//                          color: Colors.pink,
//                          fontSize: 17.0),
//                    ),
//                    Text(
//                      n.dept,
//                      textAlign: TextAlign.left,
//                    ),
//                  ],
//                ),
//              )
//            ],
//          )
//              :
//          Row(
//              children: <Widget>[
//                Column(
//                  crossAxisAlignment: CrossAxisAlignment.start,
//                  children: <Widget>[
//                    Text(
//                      n.username,
//                      textAlign: TextAlign.left,
//                      style: TextStyle(
//                          fontWeight: FontWeight.bold,
//                          color: Colors.pink,
//                          fontSize: 17.0),
//                    ),
//                    Text(
//                      n.dept,
//                      textAlign: TextAlign.left,
//                    ),
//                  ],
//                )
//              ]),
          isActive: true, // this is the issue
          state: StepState.indexed,
        ));
        //cnt = cnt + 1;
      }

      setState(() {});
    } else {

    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDocTracking();
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
    return RefreshIndicator(
      onRefresh: getDocTracking,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(4.0),
                child: Column(
                  children: <Widget>[
                    Row(
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
                    Divider(),
                    Stepper(
                      physics: NeverScrollableScrollPhysics(),
                      controlsBuilder: (BuildContext context,
                          {VoidCallback onStepContinue,
                            VoidCallback onStepCancel}) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 0.0),
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
                  ],
                ),
              ),
              /*Card(
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
                    ),
                  ),*/
            ],
          ),
        ),
      ),
    );


  }
}

class Detail {
  String status;
  String date;
  String updateby;
  String username;
  String dept;
  String image;


  Detail({this.status, this.date, this.updateby, this.username, this.dept, this.image});

  factory Detail.fromJson(Map<String, dynamic> json) {
    return Detail(
        status: json["status"],
        date: json["date"],
        updateby: json["updateby"],
        username: json["username"],
        dept: json["dept"],
        image: json["image"]
    );
  }
}
