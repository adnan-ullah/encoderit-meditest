import 'dart:convert';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthcare_homelab/constants/colors.dart';
import 'package:healthcare_homelab/db/databse_model.dart';
import 'package:healthcare_homelab/presentation/pages/Create_Request.dart';
import 'package:healthcare_homelab/presentation/pages/adminPanel/TestRequestItem.dart';
import 'package:healthcare_homelab/presentation/pages/adminPanel/TestRequestItemTypeThree.dart';
import 'package:healthcare_homelab/presentation/widgets/projectsWidget/AgentReportList.dart';
import 'package:healthcare_homelab/presentation/widgets/projectsWidget/Notifications/GenerateNotification.dart';
import 'package:healthcare_homelab/presentation/widgets/projectsWidget/Notifications/NotificationServices.dart';
import 'package:healthcare_homelab/state_programming/Create_Request_Controller.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/app_info.dart';
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
// var localTestStatusRequestList = <TestDataRequest>[];
var isLoading = false;

var type;
var phone;

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
    DbrefTestReqModel = FirebaseDatabase.instance.ref("$database_name/");
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
      softdelete: requestItem.softdelete,
      latitude: requestItem.latitude,
      longitude: requestItem.longitude,
      teststatus: requestItem.teststatus + 1,
      invoice_call: requestItem.invoice_call,
      type: requestItem.type,
      image_one: requestItem.image_one,
      image_two: requestItem.image_two,
      comments: requestItem.comments,
      total_payable_imagine_cost: requestItem.total_payable_imagine_cost,
      total_payable_pathology_cost: requestItem.total_payable_pathology_cost,
      total_payable: requestItem.total_payable,
      total_unpayable: requestItem.total_unpayable,
      admin_pathology_discount: requestItem.admin_pathology_discount,
      admin_radiology_discount: requestItem.admin_radiology_discount,
      agent_commission: requestItem.agent_commission,
      agent_pathology_discount: requestItem.agent_pathology_discount,
      agent_radiology_discount: requestItem.agent_radiology_discount,
      area: requestItem.area,
      advanced: requestItem.advanced,
      delivery_date: requestItem.delivery_date,
      due_amount: requestItem.due_amount,
      test_item_cost: requestItem.test_item_cost,
      test_item_discount: requestItem.test_item_discount,
      total_admin_discount: requestItem.total_admin_discount,
      total_agent_discount: requestItem.total_agent_discount,
      total_discount: requestItem.total_discount,
      is_paid: requestItem.is_paid,
      total_unpayable_pathology: requestItem.total_unpayable_pathology,
      total_unpayable_imagine: requestItem.total_unpayable_imagine,
      payment_date: requestItem.payment_date,
      pathology_done: requestItem.pathology_done,
      radiology_done: requestItem.radiology_done,
      assigning: requestItem.assigning,
      radiology_assigning: requestItem.radiology_assigning,
      assigning_commission: requestItem.assigning_commission,
      radiology_assigning_commission:
          requestItem.radiology_assigning_commission,
      imageDiscountFile: requestItem.imageDiscountFile
    );

    if (updateTestRequestItem != null) {
      await DbrefTestReqModel.child("testRequest")
          .child(updateTestRequestItem.mobile)
          .child(updateTestRequestItem.id)
          .update(jsonDecode(jsonEncode(updateTestRequestItem.toJson())));
    }
  }

  Future<void> getStatusData(context) async {
    _onLoading(true);

    SharedPreferences ref = await SharedPreferences.getInstance();
    type = ref.getString("type");
    phone = ref.getString("phoneNumber");

    late DatabaseReference _dbref_testReqModel;
    _dbref_testReqModel =
        await FirebaseDatabase.instance.ref("$database_name/testRequest/");

    _dbref_testReqModel.onValue.listen((event) async {
      _newTestRequestList.clear();
      testStatusRequestList.clear();
      //localTestStatusRequestList.clear();

      //  setState(() {
      //   _newTestRequestList.clear();
      //   testStatusRequestList.clear();
      // });

      for (DataSnapshot ds in event.snapshot.children) {
        for (DataSnapshot dsLater in ds.children) {
          TestDataRequest testData =
              TestDataRequest.fromJson(json.decode(jsonEncode(dsLater.value)));

          if (type == "4" && phone != superUser) {
            if (testData.assigning == phone ||
                testData.radiology_assigning == phone) {
              if (widget.statusKey.toString() == "PRECOLLECTED") {
                if ((testData.pathology_done == true &&
                        testData.radiology_done == false) ||
                    (testData.pathology_done == false &&
                        testData.radiology_done == true)) {
                  testStatusRequestList.add(testData);
                }
              } else if (widget.statusKey.toString() == "RECIEVED") {
                if (testData.pathology_done == false ||
                    testData.radiology_done == false) {
                  testStatusRequestList.add(testData);
                }
              } else {
                if (widget.statusKey.toString() == "COLLECTED") {
                  if (testData.pathology_done == true &&
                      testData.radiology_done == true) {
                    print("COLLECTED");
                    testStatusRequestList.add(testData);
                  }
                } else {
                  testStatusRequestList.add(testData);
                }
              }
            }
          } else if (type == "3" && phone != superUser) {
            if (widget.statusKey.toString() == "PRECOLLECTED") {
              if ((testData.assigning != "" &&
                      testData.assigning != null &&
                      testData.assigning != "null") ||
                  (testData.radiology_assigning != "" &&
                      testData.radiology_assigning != null &&
                      testData.radiology_assigning != "null")) {
                if (!(testData.pathology_done && testData.radiology_done))
                  testStatusRequestList.add(testData);
              }
            } else if (widget.statusKey.toString() == "COLLECTED") {
              if (testData.pathology_done != null &&
                  testData.radiology_done != null) if (testData
                      .pathology_done &&
                  testData.radiology_done) testStatusRequestList.add(testData);
            } else {
              testStatusRequestList.add(testData);
            }
          } else {
            testStatusRequestList.add(testData);
          }

          // setState(() {
          //   testStatusRequestList.add(testData);
          // });
        }
      }
      // setState(() {
      //   tabStatusList();
      // });

      tabStatusList();

      if (testStatusRequestList != null) _onLoading(false);
      //Get.back();
    });
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
      this.getStatusData(context);
    });
    // TODO: implement initState
    super.initState();
  }

  List<TestDataRequest> _newTestRequestList = [];

  void tabStatusList() async {
    setState(() {
      // if (widget.statusKey == "PRECOLLECTED" && type == "3") {
      //   _newTestRequestList.addAll(testStatusRequestList
      //       .where((p0) =>
      //           createRequest_controller.status[p0.teststatus].toString() ==
      //           "RECIEVED")
      //       .toList());
      // }
      // else if (widget.statusKey == "COLLECTED"  && (type == "3" || type=="4") ) {
      //   _newTestRequestList.addAll(testStatusRequestList
      //       .where((p0) =>
      //   createRequest_controller.status[p0.teststatus].toString() ==
      //       widget.statusKey.toString())
      //       .toList());
      //
      // }

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
                                    width: DM.p30,
                                    child: Text(
                                      "T",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: DM.p14,
                                          color: Color.fromARGB(255, 26, 1, 1)),
                                    ),
                                  ),
                                  Container(
                                    width: DM.p80,
                                    child: Text(
                                      "Name",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: DM.p14,
                                          color: Color.fromARGB(255, 26, 1, 1)),
                                    ),
                                  ),
                                  Container(
                                    width: DM.p100,
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
                                shrinkWrap: true,
                                physics: BouncingScrollPhysics(),
                                itemCount: _newTestRequestList.length,
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () async {
                                      if (type == "3"&&
                                          phone != "$superUser") {
                                        if (createRequest_controller
                                                .toStatus[widget.statusKey]! <
                                            3 || createRequest_controller
                                            .toStatus[widget.statusKey]! ==8)
                                          Get.to(TestRequestCreateTypeThree(
                                              testEachRequest:
                                                  _newTestRequestList[index]));
                                      }
                                      else if (type == "4" &&
                                          phone != "$superUser") {
                                        if (createRequest_controller.toStatus[
                                                    widget.statusKey]! ==
                                                8 ||
                                            createRequest_controller.toStatus[
                                                    widget.statusKey]! !=
                                                3)
                                          {
                                            if (_newTestRequestList[
                                            index]
                                                .assigning ==phone  &&
                                                !_newTestRequestList[index]
                                                    .pathology_done) {
                                              Get.to(TestRequestCreate(
                                                  testEachRequest:
                                                  _newTestRequestList[index]));
                                          }
                                            else if (_newTestRequestList[index]
                                                .radiology_assigning ==phone  &&
                                                !_newTestRequestList[index]
                                                    .radiology_done) {
                                              Get.to(TestRequestCreate(
                                                  testEachRequest:
                                                  _newTestRequestList[index]));
                                        }


                                        }
                                      }


                                      else {
                                        if ( type =="7" &&  phone != "$superUser" && createRequest_controller
                                                .toStatus[widget.statusKey]! <
                                            7  || createRequest_controller
                                            .toStatus[widget.statusKey] == 8 ) {
                                          Get.to(TestRequestCreate(
                                              testEachRequest:
                                                  _newTestRequestList[index]));
                                        }
                                        else {

                                            Get.to(TestRequestCreate(
                                                testEachRequest:
                                                _newTestRequestList[
                                                index]));

                                        }
                                      }
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
                                            width: DM.p30,
                                            child: Text(
                                              "${createRequest_controller.typeName[_newTestRequestList[index].type]![0]}",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: DM.p12,
                                                  color: Color.fromARGB(
                                                      255, 26, 1, 1)),
                                            ),
                                          ),
                                          SizedBox(
                                            width: DM.p80,
                                            child: Text(
                                              // "${_newTestRequestList[index].name.toString().split(' ').last}",
                                              "${getFirstName(_newTestRequestList[index].name)}",
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
                                            width: DM.p80,
                                            child: Text(
                                              (DateFormat('dd-MMM HH:mm').format(
                                                      DateTime.fromMillisecondsSinceEpoch(
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
                                          widget.isButton &&
                                                  (createRequest_controller
                                                              .toStatus[
                                                          widget.statusKey]! <
                                                      5)
                                              ? Container(
                                                  width: DM.p65,
                                                  child: MaterialButton(
                                                    onPressed: () async {
                                                      _updateStatus(
                                                          _newTestRequestList[
                                                              index]);
                                                    },
                                                    height: DM.p40,
                                                    shape:
                                                        const StadiumBorder(),
                                                    color: orangeColor,
                                                    child: Text(
                                                      "Done",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color: fullWhiteColor,
                                                          fontSize: DM.p13,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                )
                                              : widget.isButton &&
                                                      (type == "7" ||
                                                          type == "3" ||
                                                          phone == "$superUser")
                                                  ? Container(
                                                      width: DM.p65,
                                                      child: MaterialButton(
                                                        onPressed: () async {
                                                          _updateStatus(
                                                              _newTestRequestList[
                                                                  index]);
                                                        },
                                                        height: DM.p40,
                                                        shape:
                                                            const StadiumBorder(),
                                                        color: orangeColor,
                                                        child: Text(
                                                          "Done",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              color:
                                                                  fullWhiteColor,
                                                              fontSize: DM.p13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
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
                            )
                            // : Container(
                            //     height: DM.screenHeight * 0.75,
                            //     child: ListView.builder(
                            //       shrinkWrap: true,
                            //       physics: BouncingScrollPhysics(),
                            //       itemCount: _newTestRequestList.length,
                            //       itemBuilder: (context, index) {
                            //         return InkWell(
                            //           onTap: () {
                            //             if (type == "3" &&
                            //                 phone != "$superUser" ) {
                            //               Get.to(TestRequestCreateTypeThree(
                            //                   testEachRequest:
                            //                       localTestStatusRequestList[
                            //                           index]));
                            //             }
                            //           },
                            //           child: Container(
                            //             decoration: BoxDecoration(
                            //               color: whiteColor,
                            //               borderRadius:
                            //                   BorderRadius.circular(DM.p10),
                            //             ),
                            //             padding: EdgeInsets.symmetric(
                            //                 horizontal: DM.p10,
                            //                 vertical: DM.p5),
                            //             margin: EdgeInsets.symmetric(
                            //                 vertical: DM.p5),
                            //             height: DM.p60,
                            //             child: Row(
                            //               children: [
                            //                 SizedBox(
                            //                   width: DM.p30,
                            //                   child: Text(
                            //                     "${createRequest_controller.typeName[_newTestRequestList[index].type]![0]}",
                            //                     style: TextStyle(
                            //                         fontWeight:
                            //                             FontWeight.w900,
                            //                         fontSize: DM.p12,
                            //                         color: Color.fromARGB(
                            //                             255, 26, 1, 1)),
                            //                   ),
                            //                 ),
                            //                 SizedBox(
                            //                   width: DM.p80,
                            //                   child: Text(
                            //                     // "${_newTestRequestList[index].name.toString().split(' ').last}",
                            //                     "${getFirstName(_newTestRequestList[index].name)}",
                            //                     style: TextStyle(
                            //                         fontWeight:
                            //                             FontWeight.w900,
                            //                         fontSize: DM.p12,
                            //                         color: Color.fromARGB(
                            //                             255, 26, 1, 1)),
                            //                   ),
                            //                 ),
                            //                 SizedBox(
                            //                   width: DM.p100,
                            //                   child: Text(
                            //                     "#${_newTestRequestList[index].invoice_call.toString()}",
                            //                     style: TextStyle(
                            //                         fontWeight:
                            //                             FontWeight.w900,
                            //                         fontSize: DM.p12,
                            //                         color: Color.fromARGB(
                            //                             255, 26, 1, 1)),
                            //                   ),
                            //                 ),
                            //                 SizedBox(
                            //                   width: DM.p80,
                            //                   child: Text(
                            //                     (DateFormat('dd-MMM HH:mm')
                            //                             .format(DateTime
                            //                                 .fromMillisecondsSinceEpoch(
                            //                                     _newTestRequestList[
                            //                                             index]
                            //                                         .dateofcreated)))
                            //                         .toString(),
                            //                     style: TextStyle(
                            //                         fontWeight:
                            //                             FontWeight.w900,
                            //                         fontSize: DM.p12,
                            //                         color: Color.fromARGB(
                            //                             255, 26, 1, 1)),
                            //                   ),
                            //                 ),
                            //               ],
                            //             ),
                            //           ),
                            //         );
                            //       },
                            //     ),
                            //   ),
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

Future<void> getAdminNotification(phone, type, context) async {
  late DatabaseReference DbrefTestModel;
  DbrefTestModel = FirebaseDatabase.instance.ref("$database_name/admin_user/");
  FirebaseDatabase.instance.setPersistenceEnabled(true);
  DbrefTestModel.keepSynced(true);

  DbrefTestModel.onValue.listen((event) async {
    for (DataSnapshot ds in event.snapshot.children) {
      AdminUserModel testData =
          AdminUserModel.fromJson(json.decode(jsonEncode(ds.value)));

      if (testData.phone == phone || phone == "$superUser") {
        if (type == "1" || type == "7" || phone == "$superUser") {
          createPlantFoodNotification();
          showNotification(context);
        }
      }
    }
  });
}

String getFirstName(String name) {
  String firstName;

  List<String> test = name.split(" ");
  String finalName;

  if (test.first == "Mr." ||
      test.first == "Mr" ||
      test.first == "Mrs." ||
      test.first == "Mrs" ||
      test.first == "Md." ||
      test.first == "Md" ||
      test.first == "Ms." ||
      test.first == "Ms") {
    firstName = test[1];
  } else {
    firstName = test.first;
  }

  return firstName.toString();
}
