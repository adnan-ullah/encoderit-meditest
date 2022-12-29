import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthcare_homelab/constants/colors.dart';
import 'package:healthcare_homelab/db/databse_model.dart';
import 'package:healthcare_homelab/presentation/pages/Create_Request.dart';
import 'package:healthcare_homelab/presentation/pages/adminPanel/TestRequestItem.dart';
import 'package:healthcare_homelab/state_programming/Create_Request_Controller.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../responsives/dimensions.dart';
import '../../../state_programming/Request_Enum.dart';

class RequestListTabView extends StatefulWidget {
  var statusKey;

  var isButton;
  RequestListTabView(
      {super.key, required this.statusKey, required this.isButton});

  @override
  State<RequestListTabView> createState() => _RequestListTabViewState();
}

var testStatusRequestList = <TestDataRequest>[];
var isLoading = false;

class _RequestListTabViewState extends State<RequestListTabView> {
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
                    color: orangeColor,
                  ),
                  SizedBox(
                    width: DM.p10,
                  ),
                  new Text(
                    "Loading, please wait...",
                    style: TextStyle(color: orangeColor),
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

  Future<void> _updateStatus(TestDataRequest requestItem) async {
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    late DatabaseReference DbrefTestReqModel;
    DbrefTestReqModel = FirebaseDatabase.instance.ref("meditest/");
    TestDataRequest updateTestRequestItem;
    updateTestRequestItem = TestDataRequest(
        id: requestItem.id,
        name: requestItem.name,
        gender: requestItem.gender,
        mobile: requestItem.mobile,
        age: requestItem.age,
        testlist: requestItem.testlist,
        totalprice: requestItem.totalprice,
        servicecharge: requestItem.servicecharge,
        address: requestItem.address,
        referrer: requestItem.referrer,
        lastupdate: currentTime,
        dateofcreated: requestItem.dateofcreated,
        softdelete: 0,
        latitude: requestItem.latitude,
        longitude: requestItem.longitude,
        teststatus: requestItem.teststatus + 1,
        invoice_call: requestItem.invoice_call,
        type: requestItem.type,
        image_one: requestItem.image_one,
        image_two: requestItem.image_two,
        comments: requestItem.comments);

    if (updateTestRequestItem != null) {
      await DbrefTestReqModel.child("testRequest")
          .child(updateTestRequestItem.mobile)
          .child(updateTestRequestItem.id)
          .update(jsonDecode(jsonEncode(updateTestRequestItem.toJson())));
    }
  }

  Future<void> getStatusData() async {
    _onLoading(true);
    late DatabaseReference _dbref_testReqModel;
    _dbref_testReqModel =
        await FirebaseDatabase.instance.ref("meditest/testRequest/");

    _dbref_testReqModel.onValue.listen((event) {
      setState(() {
        _newTestRequestList.clear();
        testStatusRequestList.clear();
      });

      for (DataSnapshot ds in event.snapshot.children) {
        for (DataSnapshot dsLater in ds.children) {
          TestDataRequest testData =
              TestDataRequest.fromJson(json.decode(jsonEncode(dsLater.value)));
          setState(() {
            testStatusRequestList.add(testData);
          });
        }
      }
      setState(() {
        tabStatusList();
      });

      if (testStatusRequestList != null) _onLoading(false);
      //Get.back();
    });
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

  void tabStatusList() async {
    setState(() {
      _newTestRequestList.addAll(testStatusRequestList
          .where((p0) =>
              createRequest_controller.status[p0.teststatus].toString() ==
              widget.statusKey.toString())
          .toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: DM.p8),
        child: Column(
          children: [
            Container(
                child: _newTestRequestList.isEmpty == false
                    ? Container(
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(DM.p8),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: DM.p80,
                                    child: Text(
                                      "Type",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: DM.p14,
                                          color: Color.fromARGB(255, 26, 1, 1)),
                                    ),
                                  ),
                                  Container(
                                    width: DM.p120,
                                    child: Text(
                                      "Invoice Call",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: DM.p14,
                                          color: Color.fromARGB(255, 26, 1, 1)),
                                    ),
                                  ),
                                  Container(
                                    width: DM.p120,
                                    child: Text(
                                      "Date",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: DM.p14,
                                          color: Color.fromARGB(255, 26, 1, 1)),
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
                              height: DM.screenHeight * 0.75,
                              child: ListView.builder(
                                itemCount: _newTestRequestList.length,
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () {
                                      Get.to(TestRequestCreate(
                                          testEachRequest:
                                              _newTestRequestList[index]));
                                    },
                                    child: Container(
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
                                            width: DM.p80,
                                            child: Text(
                                              "${createRequest_controller.typeName[_newTestRequestList[index].type]}",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: DM.p12,
                                                  color: Color.fromARGB(
                                                      255, 26, 1, 1)),
                                            ),
                                          ),
                                          SizedBox(
                                            width: DM.p100,
                                            child: Text(
                                              "#${_newTestRequestList[index].invoice_call.toString()}",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: DM.p12,
                                                  color: Color.fromARGB(
                                                      255, 26, 1, 1)),
                                            ),
                                          ),
                                          SizedBox(
                                            width: DM.p100,
                                            child: Text(
                                              (DateFormat('dd-MMM-yyy').format(DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                          _newTestRequestList[
                                                                  index]
                                                              .dateofcreated)))
                                                  .toString(),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: DM.p12,
                                                  color: Color.fromARGB(
                                                      255, 26, 1, 1)),
                                            ),
                                          ),
                                          widget.isButton == true
                                              ? Container(
                                                  width: DM.p70,
                                                  child: MaterialButton(
                                                    onPressed: () async {
                                                      _updateStatus(
                                                          _newTestRequestList[
                                                              index]);
                                                    },
                                                    height: DM.p50,
                                                    shape:
                                                        const StadiumBorder(),
                                                    color: orangeColor,
                                                    child: Text(
                                                      "Done",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color: fullWhiteColor,
                                                          fontSize: DM.p15,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                )
                                              : Container()
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
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
                                color: orangeColor),
                          ),
                        )))
          ],
        ));
  }

  //Return String

}
