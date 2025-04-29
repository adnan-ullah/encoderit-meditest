import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthcare_homelab/constants/colors.dart';
import 'package:healthcare_homelab/db/databse_model.dart';
import 'package:healthcare_homelab/state_programming/Create_Request_Controller.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/app_info.dart';
import '../../../db/models/TestDataRequest.dart';
import '../../../responsives/dimensions.dart';

class AdminUserReport extends StatefulWidget {
  AdminUserReport({
    super.key,
  });

  @override
  State<AdminUserReport> createState() => _AdminUserReportState();
}

var isLoading = false;
var referrer_code;
var commission;

var end_datetime = DateTime(DateTime.now().year, DateTime.now().month,  DateTime.now().day ,23 , 59, 00)
    .millisecondsSinceEpoch;

var start_datetime = DateTime(DateTime.now().year, DateTime.now().month, 1)
    .millisecondsSinceEpoch;
double totalEarning = 0;

var referrer_input = new TextEditingController();
List<TestDataRequest> _cancelRequestList = [];

class _AdminUserReportState extends State<AdminUserReport> {
  CreateRequest_controller createRequest_controller =
      Get.put(CreateRequest_controller());

  void _onLoading(isClosed) {
    if (isClosed) {
      setState(() {
        isLoading = true;
      });
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              height: DM.p120,
              padding: EdgeInsets.all(DM.p16),
              child: new Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  new CircularProgressIndicator(
                    color: appTheme,
                  ),
                  SizedBox(
                    width: DM.p10,
                  ),
                  new Text(
                    "Loading, please wait...",
                    style: TextStyle(color: appTheme),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else if (!isClosed && isLoading) {
      setState(() {
        isLoading = false;
      });
      Navigator.pop(context);
    }
  }

  Future<void> getStatusData() async {
    _onLoading(true);
    late DatabaseReference _dbref_testReqModel;
    _dbref_testReqModel =
        await FirebaseDatabase.instance.ref("$database_name/testRequest/");

    _dbref_testReqModel.onValue.listen((event) async {
      _newTestRequestList.clear();

      //  setState(() {
      //   _newTestRequestList.clear();
      //   testStatusRequestList.clear();
      // });
      SharedPreferences ref = await SharedPreferences.getInstance();
      commission = ref.getString("commission");
      referrer_code = ref.getString("referrer_code");

      for (DataSnapshot ds in event.snapshot.children) {
        for (DataSnapshot dsLater in ds.children) {
          TestDataRequest testData =
              TestDataRequest.fromJson(json.decode(jsonEncode(dsLater.value)));

          _newTestRequestList.add(testData);

          _allRequestListAdmin.add(testData);

          // setState(() {
          //   testStatusRequestList.add(testData);
          // });
        }
      }

      // _newTestRequestList = _allRequestListAdmin
      //     .where((element) =>
      //         element.referrer.toString() == referrer_code.toString())
      //     .toList();

      print(_newTestRequestList.length);
      totalEarning = 0;

      _newTestRequestList.map((e) {
        if (e.teststatus == 5) {
          totalEarning = totalEarning +
              ((e.test_item_cost - e.test_item_discount) *
                      int.parse(commission) /
                      100)
                  .toInt() -
              e.total_agent_discount;
        }
      }).toList();

      if (_newTestRequestList != null) _onLoading(false);
      //Get.back();
    });
  }

  Future filterStatusDateTime() async {
    _newTestRequestList.clear();
    _newTestRequestList.addAll(_allRequestListAdmin);
    print(_newTestRequestList);

    if (referrer_input.text.isNotEmpty) {
      _newTestRequestList = _allRequestListAdmin
          .where((element) =>
              element.referrer
                  .toString()
                  .contains(referrer_input.text.toString()) &&
              (start_datetime <= element.dateofcreated &&
                  element.dateofcreated <= end_datetime))
          .toList();
    } else {
      _newTestRequestList = _allRequestListAdmin
          .where((element) => (start_datetime <= element.dateofcreated &&
              element.dateofcreated <= end_datetime))
          .toList();
    }

    totalEarning = 0;
    _newTestRequestList.map((e) {
      if (e.teststatus == 5) {
        totalEarning = totalEarning +
            ((e.test_item_cost - e.test_item_discount) *
                int.parse(commission) /
                100) -
            e.total_agent_discount;
      }
    }).toList();

    // var end_dateFormat = DateTime.fromMillisecondsSinceEpoch(end_datetime);
    // var now_1m = new DateTime(
    //     end_dateFormat.year, end_dateFormat.month - 1, end_dateFormat.day);
    // _newTestRequestList = _allRequestListAdmin
    //     .where((element) =>
    //         now_1m.isBefore(
    //             DateTime.fromMillisecondsSinceEpoch(element.dateofcreated)) &&
    //         end_dateFormat.month ==
    //             DateTime.fromMillisecondsSinceEpoch(element.dateofcreated)
    //                 .month)
    //     .toList();
  }

  Future getStoragePermission() async {
    PermissionStatus status = await Permission.storage.request();
    //PermissionStatus status1 = await Permission.accessMediaLocation.request();
    PermissionStatus status2 = await Permission.manageExternalStorage.request();
    print('status $status   -> $status2');
    if (status.isGranted && status2.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied || status2.isPermanentlyDenied) {
      await openAppSettings();
    } else if (status.isDenied) {
      print('Permission Denied');
    }
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      this.getStatusData();
    });
    // TODO: implement initState
    super.initState();
  }

  List<TestDataRequest> _newTestRequestList = [];
  List<TestDataRequest> _allRequestListAdmin = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: secondaryColor,
      appBar: AppBar(backgroundColor: appTheme, actions: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: DM.p50, vertical: DM.p10),
          width: DM.screenWidth,
          child: Text(
            "Report",
            textAlign: TextAlign.left,
            style: TextStyle(color: secondaryColor, fontSize: DM.p30),
          ),
        ),
      ]),
      body: Padding(
          padding: EdgeInsets.symmetric(horizontal: DM.p8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(DM.p10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: DM.p70,
                      child: Text(
                        "Referrer Code",
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: DM.p14,
                            color: blackFontColor),
                      ),
                    ),
                    SizedBox(
                      width: DM.p5,
                    ),
                    Text(":"),
                    SizedBox(
                      width: DM.p10,
                    ),
                    Flexible(
                      child: Container(
                        height: DM.p50,
                        child: TextFormField(
                          keyboardType: TextInputType.name,
                          controller: referrer_input,
                          // inputFormatters: <TextInputFormatter>[
                          //   FilteringTextInputFormatter.digitsOnly
                          // ],
                          // validator: validateMobile,
                          onChanged: ((value) {
                            setState(() {
                              filterStatusDateTime();
                            });

                            //_formKey.currentState?.validate();
                          }),
                          decoration: InputDecoration(
                              errorStyle: TextStyle(fontSize: DM.p9),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: DM.p1, color: appTheme)),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: DM.p1,
                                    color: appTheme), //<-- SEE HERE
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: InputBorder.none,
                              hintText: "0",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: DM.p14,
                              )),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.all(DM.p15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Container(
                        height: DM.p60,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: appTheme, elevation: 0),
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: start_datetime == null
                                    ? DateTime(DateTime.now().year,
                                        DateTime.now().month, 1, 0, 0, 1)
                                    : DateTime.fromMillisecondsSinceEpoch(
                                        start_datetime),
                                initialDatePickerMode: DatePickerMode.day,
                                firstDate: DateTime.fromMillisecondsSinceEpoch(
                                    1669831200000),
                                lastDate: DateTime.fromMillisecondsSinceEpoch(
                                    1922292000000));
                            if (picked != null)
                              setState(() {
                                // end_datetime =
                                //     DateFormat.yMMMd().format(picked);

                                //start_datetime = picked.millisecondsSinceEpoch;
                                DateTime? start = DateTime(picked.year,
                                    picked.month, picked.day, 0, 0, 1);

                                start_datetime = start.millisecondsSinceEpoch;

                                filterStatusDateTime();
                              });
                          },
                          child: Text(
                            "Pick a first date time ${DateFormat.yMMMd().format(DateTime.fromMillisecondsSinceEpoch(start_datetime))}",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: DM.p15,
                    ),
                    Flexible(
                      child: Container(
                        height: DM.p60,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: appTheme, elevation: 0),
                            onPressed: () async {
                              final DateTime? picked_end = await showDatePicker(
                                  context: context,
                                  initialDate: end_datetime == null
                                      ? DateTime.fromMillisecondsSinceEpoch(
                                          1669831200000)
                                      : DateTime.fromMillisecondsSinceEpoch(
                                          end_datetime),
                                  initialDatePickerMode: DatePickerMode.day,
                                  firstDate:
                                      DateTime.fromMillisecondsSinceEpoch(
                                          1669831200000),
                                  lastDate: DateTime.fromMillisecondsSinceEpoch(
                                      1922292000000));
                              if (picked_end != null)
                                setState(() {
                                  // end_datetime =
                                  //     DateFormat.yMMMd().format(picked);
                                  DateTime? end = DateTime(
                                      picked_end.year,
                                      picked_end.month,
                                      picked_end.day,
                                      23,
                                      59,
                                      59);

                                  end_datetime = end.millisecondsSinceEpoch;

                                  filterStatusDateTime();
                                });
                            },
                            child: Text(
                              "Pick a last date time \n ${DateFormat.yMMMd().format(DateTime.fromMillisecondsSinceEpoch(end_datetime))}",
                              textAlign: TextAlign.center,
                            )),
                      ),
                    ),
                  ],
                ),
              ),
              // Flexible(
              //   child: Container(
              //     height: DM.p45,
              //     width: DM.p150,
              //     child: ElevatedButton(
              //         style: ElevatedButton.styleFrom(
              //             backgroundColor: orangeColor, elevation: 0),
              //         onPressed: () {
              //           filterStatusDateTime();
              //         },
              //         child: Text("Submit")),
              //   ),
              // ),
              Container(
                height: DM.p10,
              ),
              Container(
                  child: _newTestRequestList.isEmpty == false
                      ? Container(
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(DM.p8),
                                child: Row(
                                  children: [
                                    Container(
                                      width: DM.p75,
                                      child: Text(
                                        "Invoice Call",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: DM.p8,
                                            color:
                                                Color.fromARGB(255, 26, 1, 1)),
                                      ),
                                    ),
                                    Container(
                                      width: DM.p55,
                                      child: Text(
                                        "Test Cost",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: DM.p8,
                                            color:
                                                Color.fromARGB(255, 26, 1, 1)),
                                      ),
                                    ),
                                    Container(
                                      width: DM.p55,
                                      child: Text(
                                        "Commission",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: DM.p8,
                                            color:
                                                Color.fromARGB(255, 26, 1, 1)),
                                      ),
                                    ),
                                    SizedBox(
                                      width: DM.p70,
                                      child: Text(
                                        "Agent Discount",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: DM.p8,
                                            color:
                                                Color.fromARGB(255, 26, 1, 1)),
                                      ),
                                    ),
                                    Container(
                                      width: DM.p50,
                                      child: Text(
                                        "Earning",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: DM.p8,
                                            color:
                                                Color.fromARGB(255, 26, 1, 1)),
                                      ),
                                    ),
                                    Container(
                                      width: DM.p50,
                                      child: Text(
                                        "Status",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: DM.p8,
                                            color:
                                                Color.fromARGB(255, 26, 1, 1)),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Divider(
                                thickness: DM.p2,
                                color: Colors.black,
                              ),
                              Container(
                                height: DM.screenHeight * 0.55,
                                child: ListView.builder(
                                  itemCount: _newTestRequestList.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: whiteColor,
                                        borderRadius:
                                            BorderRadius.circular(DM.p10),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: DM.p10, vertical: DM.p5),
                                      margin:
                                          EdgeInsets.symmetric(vertical: DM.p5),
                                      height: DM.p60,
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: DM.p75,
                                            child: Text(
                                              "#${_newTestRequestList[index].invoice_call.toString()}",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: DM.p8,
                                                  color: Color.fromARGB(
                                                      255, 26, 1, 1)),
                                            ),
                                          ),
                                          _newTestRequestList[index]
                                                      .teststatus !=
                                                  1
                                              ? SizedBox(
                                                  width: DM.p55,
                                                  child: Text(
                                                    ((_newTestRequestList[
                                                                            index]
                                                                        .test_item_cost ==
                                                                    null) ||
                                                                (_newTestRequestList[
                                                                            index]
                                                                        .test_item_discount ==
                                                                    null) ||
                                                                (_newTestRequestList[
                                                                            index]
                                                                        .total_admin_discount ==
                                                                    null)) !=
                                                            true
                                                        ? "${(_newTestRequestList[index].test_item_cost - _newTestRequestList[index].test_item_discount - _newTestRequestList[index].total_admin_discount).toString()}"
                                                        : "0",
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        fontSize: DM.p8,
                                                        color: Color.fromARGB(
                                                            255, 26, 1, 1)),
                                                  ),
                                                )
                                              : SizedBox(
                                                  width: DM.p55,
                                                  child: Text(
                                                    "Processing",
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        fontSize: DM.p8,
                                                        color: Color.fromARGB(
                                                            255, 26, 1, 1)),
                                                  ),
                                                ),
                                          _newTestRequestList[index]
                                                      .teststatus !=
                                                  1
                                              ? SizedBox(
                                                  width: DM.p55,
                                                  child: Text(
                                                    ((_newTestRequestList[
                                                                            index]
                                                                        .test_item_cost ==
                                                                    null) ||
                                                                (_newTestRequestList[
                                                                            index]
                                                                        .test_item_discount ==
                                                                    null) ||
                                                                (_newTestRequestList[
                                                                            index]
                                                                        .total_admin_discount ==
                                                                    null)) !=
                                                            true
                                                        ? "${(((_newTestRequestList[index].test_item_cost - _newTestRequestList[index].test_item_discount) * int.parse(commission)) / 100).toInt().toString()}"
                                                        : "0",
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        fontSize: DM.p8,
                                                        color: Color.fromARGB(
                                                            255, 26, 1, 1)),
                                                  ),
                                                )
                                              : SizedBox(
                                                  width: DM.p55,
                                                  child: Text(
                                                    "Processing",
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        fontSize: DM.p8,
                                                        color: Color.fromARGB(
                                                            255, 26, 1, 1)),
                                                  ),
                                                ),
                                          _newTestRequestList[index]
                                                      .teststatus !=
                                                  1
                                              ? SizedBox(
                                                  width: DM.p70,
                                                  child: Text(
                                                    ((_newTestRequestList[index]
                                                                    .total_agent_discount ==
                                                                null) !=
                                                            true)
                                                        ? _newTestRequestList[
                                                                index]
                                                            .total_agent_discount
                                                            .toString()
                                                        : "0",
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        fontSize: DM.p8,
                                                        color: Color.fromARGB(
                                                            255, 26, 1, 1)),
                                                  ),
                                                )
                                              : SizedBox(
                                                  width: DM.p70,
                                                  child: Text(
                                                    "Processing",
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        fontSize: DM.p8,
                                                        color: Color.fromARGB(
                                                            255, 26, 1, 1)),
                                                  ),
                                                ),
                                          SizedBox(
                                            width: DM.p50,
                                            child: _newTestRequestList[index]
                                                        .teststatus ==
                                                    5
                                                ? Text(
                                                    ((_newTestRequestList[
                                                                            index]
                                                                        .test_item_cost ==
                                                                    null) ||
                                                                (_newTestRequestList[
                                                                            index]
                                                                        .test_item_discount ==
                                                                    null) ||
                                                                (_newTestRequestList[
                                                                            index]
                                                                        .total_agent_discount ==
                                                                    null)) !=
                                                            true
                                                        ? "${((((_newTestRequestList[index].test_item_cost - _newTestRequestList[index].test_item_discount) * int.parse(commission)) / 100).toInt() - _newTestRequestList[index].total_agent_discount).toString()}"
                                                        : "0",

                                                    // "${((int.parse(((_newTestRequestList[index].test_item_cost - _newTestRequestList[index].test_item_discount) * int.parse(commission)) / 100)) - int.parse(_newTestRequestList[index].agent_discount)).toString()}",
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        fontSize: DM.p8,
                                                        color: Color.fromARGB(
                                                            255, 26, 1, 1)),
                                                  )
                                                : SizedBox(
                                                    width: DM.p50,
                                                    child: Text(
                                                      "Processing",
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          fontSize: DM.p8,
                                                          color: Color.fromARGB(
                                                              255, 26, 1, 1)),
                                                    ),
                                                  ),
                                          ),
                                          SizedBox(
                                            width: DM.p55,
                                            child: Text(
                                              createRequest_controller.status[
                                                      _newTestRequestList[index]
                                                          .teststatus]
                                                  .toString(),
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: DM.p8,
                                                  color: Color.fromARGB(
                                                      255, 26, 1, 1)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(right: DM.p10),
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Divider(
                                        thickness: DM.p1,
                                        color: blackFontColor,
                                      ),
                                      Text(
                                        "Total Earning =  ${totalEarning}",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: DM.p15,
                                            color:
                                                Color.fromARGB(255, 26, 1, 1)),
                                      ),
                                    ]),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          height: DM.screenHeight * 0.65,
                          margin: EdgeInsets.symmetric(vertical: DM.p16),
                          child: Center(
                            child: Text(
                              "Request list empty ",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: DM.p25,
                                  color: appTheme),
                            ),
                          ))),
            ],
          )),
    );
  }

  //Return String

}
