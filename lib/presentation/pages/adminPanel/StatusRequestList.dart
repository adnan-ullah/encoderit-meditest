import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthcare_homelab/constants/colors.dart';
import 'package:healthcare_homelab/db/databse_model.dart';
import 'package:healthcare_homelab/presentation/pages/Create_Request.dart';
import 'package:healthcare_homelab/presentation/pages/adminPanel/TestData.dart';
import 'package:healthcare_homelab/presentation/pages/adminPanel/TestItemList.dart';
import 'package:healthcare_homelab/presentation/pages/adminPanel/TestRequestItem.dart';
import 'package:healthcare_homelab/state_programming/Create_Request_Controller.dart';

import '../../../constants/app_info.dart';
import '../../../responsives/dimensions.dart';

class StatusRequestList extends StatefulWidget {
  StatusRequestList({super.key});

  @override
  State<StatusRequestList> createState() => _StatusRequestListState();
}

String messageTitle = "Empty";
String notificationAlert = "alert";

FirebaseMessaging messaging = FirebaseMessaging.instance;

class _StatusRequestListState extends State<StatusRequestList> {
  @override
  void initState() {
    populateAllRequest();

    // TODO: implement initState
    super.initState();
  }

  CreateRequest_controller cr_controller = Get.put(CreateRequest_controller());

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamColor,
      appBar: AppBar(backgroundColor: orangeColor, actions: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: DM.p50, vertical: DM.p10),
          width: DM.screenWidth,
          child: Text(
            "Admin",
            textAlign: TextAlign.left,
            style: TextStyle(color: creamColor, fontSize: DM.p30),
          ),
        ),
      ]),
      body: Padding(
        padding: EdgeInsets.all(DM.p8),
        child: Column(
          children: [
            Container(
                color: creamColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: DM.p180,
                            width: DM.screenWidth * 0.4,
                            margin: EdgeInsets.symmetric(
                                vertical: DM.p25, horizontal: DM.p16),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: DM.p30, vertical: DM.p20),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(DM.p10)),
                                  primary: orangeColor),
                              onPressed: () {
                                _onLoading(true);
                                Timer(Duration(seconds: 2), () {
                                  _onLoading(false);
                                  Get.to(TestItemList());
                                });
                              },
                              child: Text(
                                "Test Item",
                                style: TextStyle(
                                    color: fullWhiteColor,
                                    fontSize: DM.p15,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Container(
                            height: DM.p180,
                            width: DM.screenWidth * 0.4,
                            margin: EdgeInsets.symmetric(
                                vertical: DM.p25, horizontal: DM.p16),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: DM.p30, vertical: DM.p20),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(DM.p10)),
                                  primary: orangeColor),
                              onPressed: () {
                                Get.to(TestRequestCreate());
                              },
                              child: Text(
                                "Test Request",
                                style: TextStyle(
                                    color: fullWhiteColor,
                                    fontSize: DM.p15,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: DM.p25),
                      child: MaterialButton(
                        onPressed: () {
                          //
                        },
                        height: DM.p45,
                        minWidth: DM.p130,
                        shape: const StadiumBorder(),
                        color: orangeColor,
                        child: Text(
                          "Add Item",
                          style: TextStyle(
                              color: fullWhiteColor,
                              fontSize: DM.p15,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  ],
                )),
          ],
        ),
      ),
    );
  }
}

Future<void> populateAllRequest() async {
  CreateRequest_controller createRequestController =
      Get.put(CreateRequest_controller());
  late DatabaseReference dbrefTestRequest;
  dbrefTestRequest = FirebaseDatabase.instance.ref("meditest/testRequest/");

  createRequestController.testItemList.clear();
  createRequestController.testItemListWithSelected.clear();

  dbrefTestRequest.onValue.listen((event) {
    // for (DataSnapshot ds in event.snapshot.children.forEach((element) {element. })) {
    // print(ds.value);
    print("\n\n\n\n");
    // for (var element in event.snapshot.children) {
    //   print(element.children.forEach((element) {
    //     print("object");
    //   }));
    // }

    // TestDataRequest testDataRequest =
    //     TestDataRequest.fromJson(json.decode(jsonEncode(ds.value)));
    // print(testDataRequest.id);

    //   TestData testData = TestData.fromJson(json.decode(jsonEncode(ds.value)));

    // createRequestController.testItemList.add(testData);
    // createRequestController.testItemListWithSelected[testData.id] = false;
    //false -> add button
    //true -> remove button

    // print(testData.name);
    // }
  });
}
