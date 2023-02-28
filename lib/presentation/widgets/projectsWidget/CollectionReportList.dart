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
import 'package:healthcare_homelab/presentation/widgets/projectsWidget/AdminSuperReport.dart';
import 'package:healthcare_homelab/state_programming/Create_Request_Controller.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/app_info.dart';
import '../../../responsives/dimensions.dart';
import '../../../state_programming/Request_Enum.dart';

class CollectionReportList extends StatefulWidget {
  CollectionReportList({
    super.key,
  });

  @override
  State<CollectionReportList> createState() => _CollectionReportListState();
}

var isLoading = false;

var commission;

var end_datetime = DateTime(DateTime.now().year, DateTime.now().month,
    DateTime.now().day, 23, 59, 59)
    .millisecondsSinceEpoch;

var start_datetime = DateTime(DateTime.now().year, DateTime.now().month, 1)
    .millisecondsSinceEpoch;
double totalEarning = 0;
double totalTestCost = 0;
double totalPaidAmount = 0;
int totalQuantity = 0;
List<TestDataRequest> _newTestRequestList = [];
List<TestDataRequest> _allRequestListAdmin = [];

late TabController tabController;

var type = "0";
var phone = "0";

class _CollectionReportListState extends State<CollectionReportList>
    with TickerProviderStateMixin {
  CreateRequest_controller createRequest_controller =
  Get.put(CreateRequest_controller());

  int _selectedIndex = 0;

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

  Future<void> _updatePay(TestDataRequest requestItem) async {
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
        teststatus: requestItem.teststatus,
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
        assigning: requestItem.assigning,
        assigning_commission: requestItem.assigning_commission,
        advanced: requestItem.advanced,
        delivery_date: requestItem.delivery_date,
        due_amount: requestItem.due_amount,
        test_item_cost: requestItem.test_item_cost,
        test_item_discount: requestItem.test_item_discount,
        total_admin_discount: requestItem.total_admin_discount,
        total_agent_discount: requestItem.total_agent_discount,
        total_discount: requestItem.total_discount,
        is_paid: true,
        total_unpayable_pathology: requestItem.total_unpayable_pathology,
        total_unpayable_imagine: requestItem.total_unpayable_imagine,
        payment_date: currentTime,
         pathology_done: requestItem.pathology_done,
        radiology_done: requestItem.radiology_done,
        radiology_assigning: requestItem.radiology_assigning,
        radiology_assigning_commission: requestItem.radiology_assigning_commission,


    );

    if (updateTestRequestItem != null) {
      await DbrefTestReqModel.child("testRequest")
          .child(updateTestRequestItem.mobile)
          .child(updateTestRequestItem.id)
          .update(jsonDecode(jsonEncode(updateTestRequestItem.toJson())));
    }

    setState(() {
      filterStatusDateTime(referrer_input.text);
    });
  }

  Future<void> getStatusData() async {
    _onLoading(true);

    SharedPreferences ref = await SharedPreferences.getInstance();
    phone = ref.getString('phoneNumber')!;
    type = ref.getString("type")!;

    late DatabaseReference _dbref_testReqModel;
    _dbref_testReqModel =
    await FirebaseDatabase.instance.ref("$database_name/testRequest/");

    _dbref_testReqModel.onValue.listen((event) async {
      _newTestRequestList.clear();
      _allRequestListAdmin.clear();

      for (DataSnapshot ds in event.snapshot.children) {
        for (DataSnapshot dsLater in ds.children) {
          TestDataRequest testData =
          TestDataRequest.fromJson(json.decode(jsonEncode(dsLater.value)));
            if (testData.assigning == phone ||
                testData.radiology_assigning == phone) {
                _allRequestListAdmin.add(testData);
            }
        }
      }

setState(() {


  _newTestRequestList.addAll(_allRequestListAdmin);

      totalEarning = 0;
      totalTestCost = 0;
      totalPaidAmount = 0;
      totalQuantity =0;

      _newTestRequestList.map((e) {


        if(e.assigning==phone)
          {
            totalEarning =
                totalEarning + e.assigning_commission;
            totalTestCost = totalTestCost + e.total_payable_pathology_cost;
            print("total_payable_pathology_cost"+e.total_payable_pathology_cost.toString());
          }
         if(e.radiology_assigning==phone)
          {
            totalEarning =
                totalEarning + e.radiology_assigning_commission;
            totalTestCost = totalTestCost + e.total_payable_imagine_cost;
            print("total_payable_imagine_cost"+e.total_payable_imagine_cost.toString());
          }


         totalQuantity++;


      }).toList();
    });
    });
    if (_newTestRequestList != null) _onLoading(false);

    //Get.back();
  }

  Future<void> filterStatusDateTime(var referrer) async {
    // _newTestRequestList.clear();
    // _newTestRequestList.addAll(_allRequestListAdmin);

      _newTestRequestList = _allRequestListAdmin
          .where((element) =>
          (start_datetime <= element.dateofcreated &&
              element.dateofcreated <= end_datetime))
          .toList();

      totalEarning = 0;
      totalTestCost = 0;
      totalPaidAmount = 0;
      totalQuantity =0;

      _newTestRequestList.map((e) {

          if(e.assigning==phone)
          {
            totalEarning =
                totalEarning + e.assigning_commission;

            totalTestCost = totalTestCost + e.total_payable_pathology_cost;

          }
          if(e.radiology_assigning==phone)
          {
            totalEarning =
                totalEarning + e.radiology_assigning_commission;

            totalTestCost = totalTestCost + e.total_payable_imagine_cost;

          }

          totalQuantity++;

      }).toList();

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
    referrer_input.text = "0";
    tabController = TabController(length: 0, vsync: this, initialIndex: 0);

    _selectedIndex = tabController.index;

    Future.delayed(Duration.zero, () {
      this.getStatusData();
    });

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamColor,
      appBar: AppBar(backgroundColor: orangeColor, actions: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: DM.p50, vertical: DM.p10),
          width: DM.screenWidth,
          child: Text(
            "Collection Report",
            textAlign: TextAlign.left,
            style: TextStyle(color: creamColor, fontSize: DM.p30),
          ),
        ),
      ]),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [

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
                            backgroundColor: orangeColor, elevation: 0),
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

                              filterStatusDateTime(
                                  referrer_input.text.toString());
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
                              backgroundColor: orangeColor, elevation: 0),
                          onPressed: () async {
                            final DateTime? picked_end = await showDatePicker(
                                context: context,
                                initialDate: end_datetime == null
                                    ? DateTime.fromMillisecondsSinceEpoch(
                                    1669831200000)
                                    : DateTime.fromMillisecondsSinceEpoch(
                                    end_datetime),
                                initialDatePickerMode: DatePickerMode.day,
                                firstDate: DateTime.fromMillisecondsSinceEpoch(
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

                                filterStatusDateTime(
                                    referrer_input.text.toString());
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
            Container(
              height: DM.screenHeight * 0.62,
              margin: EdgeInsets.symmetric(horizontal: DM.p5),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: DM.p50,
                        width: DM.screenWidth * 1.2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: DM.p80,
                              child: Text(
                                "Invoice Call",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: DM.p10,
                                    color: Color.fromARGB(255, 26, 1, 1)),
                              ),
                            ),


                            Container(
                              width: DM.p80,
                              child: Text(
                                "Test Cost",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: DM.p10,
                                    color: Color.fromARGB(255, 26, 1, 1)),
                              ),
                            ),
                            Container(
                              width: DM.p80,
                              child: Text(
                                "Commission",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: DM.p10,
                                    color: Color.fromARGB(255, 26, 1, 1)),
                              ),
                            ),

                            Container(
                              width: DM.p80,
                              child: Text(
                                "Payment Date",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: DM.p10,
                                    color: Color.fromARGB(255, 26, 1, 1)),
                              ),
                            ),
                            Container(
                              width: DM.p80,
                              child: Text(
                                "Status",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: DM.p10,
                                    color: Color.fromARGB(255, 26, 1, 1)),
                              ),
                            ),

                          ],
                        ),
                      ),
                      Expanded(
                        child: isLoading == false
                            ? Container(
                            height: DM.screenHeight * 0.50,
                            width: DM.screenWidth * 1.2,
                            child: _newTestRequestList.isNotEmpty
                                ? Container(
                              height: DM.p100,
                              child: Column(
                                children: [
                                  Divider(
                                    thickness: DM.p2,
                                    color: Colors.black,
                                  ),
                                  Container(
                                    height: DM.screenHeight * 0.50,
                                    width: DM.screenWidth * 2.5,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount:
                                      _newTestRequestList.length,
                                      itemBuilder: (context, index) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: whiteColor,
                                            borderRadius:
                                            BorderRadius.circular(
                                                DM.p10),
                                          ),
                                          margin:
                                          EdgeInsets.symmetric(
                                              vertical: DM.p5),
                                          height: DM.p60,
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                            children: [
                                              Container(
                                                width: DM.p80,
                                                child: Text(
                                                  "#${_newTestRequestList[index].invoice_call.toString()}",
                                                  textAlign: TextAlign
                                                      .center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                      FontWeight
                                                          .w900,
                                                      fontSize:
                                                      DM.p10,
                                                      color: Color
                                                          .fromARGB(
                                                          255,
                                                          26,
                                                          1,
                                                          1)),
                                                ),
                                              ),
                                              Container(
                                                width: DM.p80,
                                                child: Text(
                                                    _newTestRequestList[index].assigning ==phone  && _newTestRequestList[index].radiology_assigning ==phone?
                                                  "${_newTestRequestList[index].total_payable_pathology_cost+_newTestRequestList[index].total_payable_imagine_cost}":
                                                    _newTestRequestList[index].assigning==phone?"${_newTestRequestList[index].total_payable_pathology_cost.toString()}"
                                                  : "${_newTestRequestList[index].total_payable_imagine_cost.toString()}",

                                                  textAlign: TextAlign
                                                      .center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                      FontWeight
                                                          .w900,
                                                      fontSize:
                                                      DM.p10,
                                                      color: Color
                                                          .fromARGB(
                                                          255,
                                                          26,
                                                          1,
                                                          1)),
                                                ),
                                              ),
                                            SizedBox(
                                                width: DM.p80,
                                                child: Text(
                                                  _newTestRequestList[index].assigning ==phone  && _newTestRequestList[index].radiology_assigning ==phone?
                                                  "${_newTestRequestList[index].assigning_commission+_newTestRequestList[index].radiology_assigning_commission}":
                                                  _newTestRequestList[index].assigning==phone?"${_newTestRequestList[index].assigning_commission.toString()}"
                                                      : "${_newTestRequestList[index].radiology_assigning_commission.toString()}",
                                                  textAlign:
                                                  TextAlign
                                                      .center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                      FontWeight
                                                          .w900,
                                                      fontSize: DM
                                                          .p10,
                                                      color: Color
                                                          .fromARGB(
                                                          255,
                                                          26,
                                                          1,
                                                          1)),
                                                ),
                                              )
                                               ,

                                              SizedBox(
                                                width: DM.p80,
                                                child: _newTestRequestList[
                                                index]
                                                    .payment_date ==
                                                    0
                                                    ? Text(
                                                  "NA",
                                                  textAlign:
                                                  TextAlign
                                                      .center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                      FontWeight
                                                          .w900,
                                                      fontSize: DM
                                                          .p10,
                                                      color: Color
                                                          .fromARGB(
                                                          255,
                                                          26,
                                                          1,
                                                          1)),
                                                )
                                                    : Text(
                                                  (DateFormat('dd-MMM-yyyy')
                                                      .format(
                                                      DateTime.fromMillisecondsSinceEpoch(_newTestRequestList[index].payment_date)))
                                                      .toString(),
                                                  textAlign:
                                                  TextAlign
                                                      .center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                      FontWeight
                                                          .w900,
                                                      fontSize: DM
                                                          .p10,
                                                      color: Color
                                                          .fromARGB(
                                                          255,
                                                          26,
                                                          1,
                                                          1)),
                                                ),
                                              ),
                                              SizedBox(
                                                  width: DM.p80,
                                                  child: _newTestRequestList[
                                                  index]
                                                      .is_paid
                                                      ? Text(
                                                    "Paid",
                                                    textAlign:
                                                    TextAlign
                                                        .center,
                                                    style: TextStyle(
                                                        fontWeight:
                                                        FontWeight
                                                            .w900,
                                                        fontSize: DM
                                                            .p10,
                                                        color: Color.fromARGB(
                                                            255,
                                                            26,
                                                            1,
                                                            1)),
                                                  )
                                                      : (type == "7" ||
                                                      phone ==
                                                          "$superUser")
                                                      ? MaterialButton(
                                                    onPressed:
                                                        () async {
                                                      _updatePay(
                                                          _newTestRequestList[index]);
                                                    },
                                                    height:
                                                    DM.p40,
                                                    shape:
                                                    const StadiumBorder(),
                                                    color:
                                                    orangeColor,
                                                    child:
                                                    Text(
                                                      "Pay",
                                                      textAlign:
                                                      TextAlign.center,
                                                      style: TextStyle(
                                                          color: fullWhiteColor,
                                                          fontSize: DM.p13,
                                                          fontWeight: FontWeight.bold),
                                                    ),
                                                  )
                                                      : Text(
                                                    "Not Paid",
                                                    textAlign:
                                                    TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight: FontWeight
                                                            .w900,
                                                        fontSize: DM
                                                            .p10,
                                                        color: Color.fromARGB(
                                                            255,
                                                            26,
                                                            1,
                                                            1)),
                                                  ))
                                            ],
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
                                margin: EdgeInsets.symmetric(
                                    vertical: DM.p16),
                                child: Text(
                                  "Request list empty ",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: DM.p25,
                                      color: orangeColor),
                                )))
                            : SizedBox(),
                      )
                    ],
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: DM.p10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(
                      thickness: DM.p1,
                      color: blackFontColor,
                    ),
                    Text(
                      "Total Collection Quantity =  ${totalQuantity}",
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: DM.p15,
                          color: Color.fromARGB(255, 26, 1, 1)),
                    ),
                  ]),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: DM.p10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(
                      thickness: DM.p1,
                      color: blackFontColor,
                    ),
                    Text(
                      "Total Test Cost =  ${totalTestCost}",
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: DM.p15,
                          color: Color.fromARGB(255, 26, 1, 1)),
                    ),
                  ]),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: DM.p10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(
                      thickness: DM.p1,
                      color: blackFontColor,
                    ),
                    Text(
                      "Total Earning =  ${totalEarning}/-",
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: DM.p15,
                          color: Color.fromARGB(255, 26, 1, 1)),
                    ),
                  ]),
            ),
          ],
        ),
      ),
    );
  }

//Return String

}
