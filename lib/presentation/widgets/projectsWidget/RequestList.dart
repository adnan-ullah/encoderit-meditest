import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthcare_homelab/constants/api.dart';
import 'package:healthcare_homelab/constants/colors.dart';
import 'package:healthcare_homelab/state_programming/CreateRequestController.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/app_info.dart';
import '../../../db/models/TestDataRequest.dart';
import '../../../responsives/dimensions.dart';

class RequestList extends StatefulWidget {
  RequestList({
    super.key,
  });

  @override
  State<RequestList> createState() => _RequestListState();
}

class _RequestListState extends State<RequestList> {
  List<TestDataRequest> testDataEach = [];
  late DatabaseReference _dbref_testReqModel;
  String? phoneNumber;

  Future<void> getPhoneData() async {
    _onLoading(true);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    phoneNumber = prefs.getString("phoneNumber")!;

    setState(() {
      testDataEach.clear();
    });

    List<String> lastThreeMonths = getLastThreeMonthTestRequestPaths();

    for (String monthPath in lastThreeMonths) {
      final dbRef = FirebaseDatabase.instance.ref("$monthPath/$phoneNumber/");
      final snapshot = await dbRef.get();

      if (snapshot.exists) {
        for (DataSnapshot ds in snapshot.children) {
          final testData = TestDataRequest.fromJson(json.decode(jsonEncode(ds.value)));
          setState(() {
            testDataEach.add(testData);
          });
        }
      }
    }

    _onLoading(false);
  }

  var isLoading = true;

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

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      this.getPhoneData();
    });
    // TODO: implement initState
    super.initState();
  }

  CreateRequestController createRequest_controller =
      Get.put(CreateRequestController());

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(DM.p8),
        child: Column(
          children: [
            Text(
              "Request list",
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: DM.p25,
                  color: Color.fromARGB(255, 26, 1, 1)),
            ),
            isLoading == false
                ? Container(
                    child: testDataEach.isEmpty == false
                        ? Container(
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(DM.p8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Invoice Call",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: DM.p14,
                                            color:
                                                Color.fromARGB(255, 26, 1, 1)),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(right: DM.p40),
                                        child: Text(
                                          "Status",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: DM.p14,
                                              color: Color.fromARGB(
                                                  255, 26, 1, 1)),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(right: DM.p10),
                                        child: Text(
                                          "Date",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: DM.p14,
                                              color: Color.fromARGB(
                                                  255, 26, 1, 1)),
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
                                  height: DM.screenHeight * 0.60,
                                  child: ListView.builder(
                                    itemCount: testDataEach.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: whiteColor,
                                          borderRadius:
                                              BorderRadius.circular(DM.p10),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: DM.p10,
                                            vertical: DM.p5),
                                        margin: EdgeInsets.symmetric(
                                            vertical: DM.p5),
                                        height: DM.p60,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              child: Text(
                                                "#${testDataEach[index].invoice_call.toString()}",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: DM.p12,
                                                    color: Color.fromARGB(
                                                        255, 26, 1, 1)),
                                              ),
                                            ),
                                            createRequest_controller.status[
                                                        testDataEach[index]
                                                            .teststatus] ==
                                                    "R.RECIEVED"
                                                ? Container(
                                                    child: MaterialButton(
                                                      onPressed: () async {
                                                        _updateStatus(
                                                            testDataEach[
                                                                index]);
                                                      },
                                                      height: DM.p40,
                                                      shape:
                                                          const StadiumBorder(),
                                                      color: appTheme,
                                                      child: Text(
                                                        "RECIEVED",
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
                                                : Text(
                                                    createRequest_controller
                                                        .status[
                                                            testDataEach[index]
                                                                .teststatus]
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        fontSize: DM.p12,
                                                        color: Color.fromARGB(
                                                            255, 26, 1, 1)),
                                                  ),
                                            Text(
                                              testDataEach[index].dateofcreated != null
                                                  ? DateFormat('dd-MMM-yyyy').format(
                                                  DateTime.fromMillisecondsSinceEpoch(testDataEach[index].dateofcreated!))
                                                  : "No Date",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontSize: DM.p12,
                                                color: Color.fromARGB(255, 26, 1, 1),
                                              ),
                                            ),

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
                            margin: EdgeInsets.symmetric(vertical: DM.p16),
                            color: whiteColor,
                            child: Center(
                              child: Text(
                                "Request list empty",
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: DM.p25,
                                    color: appTheme),
                              ),
                            )))
                : Container(
                    height: DM.screenHeight * 0.70,
                  ),
          ],
        ));
  }

  //Return String

}

Future<void> _updateStatus(TestDataRequest requestItem) async {
  int currentTime = DateTime.now().millisecondsSinceEpoch;
  List<String> paths = getLastThreeMonthTestRequestPaths();

  if (requestItem.dateofcreated < DateTime.now().subtract(Duration(days: 90)).millisecondsSinceEpoch) {
    print("This item is older than 3 months, update will not be performed.");
    return;
  }

  TestDataRequest updateTestRequestItem = TestDataRequest(
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
    is_paid: requestItem.is_paid,
    total_unpayable_pathology: requestItem.total_unpayable_pathology,
    total_unpayable_imagine: requestItem.total_unpayable_imagine,
    payment_date: requestItem.payment_date,
    pathology_done: requestItem.pathology_done,
    radiology_done: requestItem.radiology_done,
    radiology_assigning: requestItem.radiology_assigning,
    radiology_assigning_commission: requestItem.radiology_assigning_commission,
    imageDiscountFile: requestItem.imageDiscountFile,
  );

  await Future.wait(paths.map((path) async {
    final dbRef = FirebaseDatabase.instance.ref(path);
    dbRef.keepSynced(true);

    final snapshot = await dbRef.get();
    if (snapshot.exists) {
      for (DataSnapshot ds in snapshot.children) {
        if (ds.key == updateTestRequestItem.id) {
          await dbRef
              .child(updateTestRequestItem.id)
              .update(jsonDecode(jsonEncode(updateTestRequestItem.toJson())));
          print("Updated item with ID: ${updateTestRequestItem.id}");
        }
      }
    }
  }));

  print("Update performed successfully for ${updateTestRequestItem.id}");
}

