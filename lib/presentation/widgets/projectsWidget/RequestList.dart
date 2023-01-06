import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthcare_homelab/constants/colors.dart';
import 'package:healthcare_homelab/db/databse_model.dart';
import 'package:healthcare_homelab/presentation/pages/Create_Request.dart';
import 'package:healthcare_homelab/presentation/widgets/projectsWidget/Notifications/GenerateNotification.dart';
import 'package:healthcare_homelab/state_programming/Create_Request_Controller.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../responsives/dimensions.dart';
import '../../../state_programming/Request_Enum.dart';
import 'Notifications/NotificationServices.dart';

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

    _dbref_testReqModel = await FirebaseDatabase.instance
        .ref("meditest/testRequest/${phoneNumber}/");

    _dbref_testReqModel.onValue.listen((event) {
  

      setState(() {
        testDataEach.clear();
      });
      for (DataSnapshot ds in event.snapshot.children) {
        TestDataRequest testData =
            TestDataRequest.fromJson(json.decode(jsonEncode(ds.value)));

        setState(() {
          testDataEach.add(testData);
        });
      }

      if (testDataEach != null) _onLoading(false);
      //Get.back();
    });
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
  void initState() {
    Future.delayed(Duration.zero, () {
      this.getPhoneData();
    });
    // TODO: implement initState
    super.initState();
  }

  CreateRequest_controller createRequest_controller =
      Get.put(CreateRequest_controller());

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
                                            Text(
                                              createRequest_controller.status[
                                                      testDataEach[index]
                                                          .teststatus]
                                                  .toString(),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: DM.p12,
                                                  color: Color.fromARGB(
                                                      255, 26, 1, 1)),
                                            ),
                                            Text(
                                              (DateFormat('dd-MMM-yyy').format(DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                          testDataEach[index]
                                                              .dateofcreated)))
                                                  .toString(),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: DM.p12,
                                                  color: Color.fromARGB(
                                                      255, 26, 1, 1)),
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
                                    color: orangeColor),
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
