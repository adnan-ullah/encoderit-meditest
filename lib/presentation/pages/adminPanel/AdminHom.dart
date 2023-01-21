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
import 'package:healthcare_homelab/presentation/pages/adminPanel/AdminUser.dart';
import 'package:healthcare_homelab/presentation/pages/adminPanel/StatusRequestList.dart';
import 'package:healthcare_homelab/presentation/pages/adminPanel/TestData.dart';
import 'package:healthcare_homelab/presentation/pages/adminPanel/TestItemList.dart';
import 'package:healthcare_homelab/presentation/pages/adminPanel/TestRequestItem.dart';
import 'package:healthcare_homelab/presentation/widgets/projectsWidget/AdminReportList.dart';
import 'package:healthcare_homelab/presentation/widgets/projectsWidget/AdminSuperReport.dart';
import 'package:healthcare_homelab/presentation/widgets/projectsWidget/AdminUserReport.dart';
import 'package:healthcare_homelab/presentation/widgets/projectsWidget/AgentReportList.dart';
import 'package:healthcare_homelab/presentation/widgets/projectsWidget/RequestListTabView.dart';
import 'package:healthcare_homelab/state_programming/Create_Request_Controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/app_info.dart';
import '../../../responsives/dimensions.dart';

class AdminHome extends StatefulWidget {
  var check_type;
  var check_number;
  AdminHome({super.key, required this.check_type, required this.check_number});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  @override
  void initState() {
    // getTestItemList();

    // TODO: implement initState
    super.initState();
  }

  CreateRequest_controller cr_controller = Get.put(CreateRequest_controller());

  var isLoading = true;

  var type;
  var phone;

  Future<void> getTypeData() async {
    SharedPreferences ref = await SharedPreferences.getInstance();
    type = ref.getString("type");

    phone = ref.getString("phoneNumber");
  }

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
            type == "7" || phone == "$superUser" ? "Admin" : "Agent",
            textAlign: TextAlign.left,
            style: TextStyle(color: creamColor, fontSize: DM.p30),
          ),
        ),
      ]),
      body: Padding(
        padding: EdgeInsets.all(DM.p8),
        child: SingleChildScrollView(
          child: Column(
            children: [
              widget.check_number == "$superUser" ||
                      widget.check_type == 7 ||
                      widget.check_type == 1
                  ? Container(
                      color: creamColor,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                widget.check_type == 7 ||
                                        widget.check_number == "$superUser"
                                    ? Container(
                                        height: DM.p180,
                                        width: DM.screenWidth * 0.4,
                                        margin: EdgeInsets.symmetric(
                                            vertical: DM.p25,
                                            horizontal: DM.p10),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: DM.p30,
                                                  vertical: DM.p20),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          DM.p10)),
                                              primary: orangeColor),
                                          onPressed: () async {
                                            SharedPreferences ref =
                                                await SharedPreferences
                                                    .getInstance();
                                            var type = ref.getString("type");

                                            var phone =
                                                ref.getString("phoneNumber");
                                            if (phone!
                                                    .contains("@superUser") ||
                                                (type != null &&
                                                    type!.contains("7"))) {
                                              Get.to(TestItemList());
                                            }
                                          },
                                          child: Text(
                                            "Test Item",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: fullWhiteColor,
                                                fontSize: DM.p15,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      )
                                    : SizedBox(),
                                Container(
                                  height: DM.p180,
                                  width: DM.screenWidth * 0.4,
                                  margin: EdgeInsets.symmetric(
                                      vertical: DM.p25, horizontal: DM.p10),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: DM.p30,
                                            vertical: DM.p20),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(DM.p10)),
                                        primary: orangeColor),
                                    onPressed: () {
                                      Get.to(StatusRequestList());
                                    },
                                    child: Text(
                                      "Test Request",
                                      textAlign: TextAlign.center,
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                widget.check_number == "$superUser"
                                    ? Container(
                                        height: DM.p180,
                                        width: DM.screenWidth * 0.4,
                                        margin: EdgeInsets.symmetric(
                                            vertical: DM.p25,
                                            horizontal: DM.p10),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: DM.p30,
                                                  vertical: DM.p20),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          DM.p10)),
                                              primary: orangeColor),
                                          onPressed: () async {
                                            SharedPreferences ref =
                                                await SharedPreferences
                                                    .getInstance();

                                            var phone =
                                                ref.getString("phoneNumber");
                                            if (phone!
                                                .contains("$superUser")) {
                                              Get.to(AdminUser());
                                            }
                                          },
                                          child: Text(
                                            "Admin User",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: fullWhiteColor,
                                                fontSize: DM.p15,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      )
                                    : SizedBox(),
                                Container(
                                    color: creamColor,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        widget.check_number == "$superUser" ||
                                                widget.check_type == 7
                                            ? Container(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      height: DM.p180,
                                                      width:
                                                          DM.screenWidth * 0.4,
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                              vertical: DM.p25,
                                                              horizontal:
                                                                  DM.p10),
                                                      child: ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        DM.p30,
                                                                    vertical:
                                                                        DM.p20),
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(DM
                                                                            .p10)),
                                                            primary:
                                                                orangeColor),
                                                        onPressed: () async {
                                                          SharedPreferences
                                                              ref =
                                                              await SharedPreferences
                                                                  .getInstance();

                                                          var phone =
                                                              ref.getString(
                                                                  "phoneNumber");
                                                          var type =
                                                              ref.getString(
                                                                  "type");
                                                          if (phone!.contains(
                                                              "$superUser")) {
                                                            Get.to(
                                                                AdminSuperReport());
                                                          } else if (type ==
                                                                  "1" ||
                                                              type == "7") {
                                                            Get.to(
                                                                AdminUserReport());
                                                          }
                                                        },
                                                        child: Text(
                                                          "Report",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              color:
                                                                  fullWhiteColor,
                                                              fontSize: DM.p15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : SizedBox(),
                                      ],
                                    )),
                              ],
                            ),
                          ),
                          widget.check_number == "$superUser" ||
                                  widget.check_type == 7
                              ? Container(
                                  height: DM.p180,
                                  width: DM.screenWidth * 0.4,
                                  margin: EdgeInsets.symmetric(
                                      vertical: DM.p25, horizontal: DM.p10),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: DM.p30,
                                            vertical: DM.p20),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(DM.p10)),
                                        primary: orangeColor),
                                    onPressed: () async {
                                      SharedPreferences ref =
                                          await SharedPreferences.getInstance();

                                      var phone = ref.getString("phoneNumber");
                                      var type = ref.getString("type");
                                      if (phone!.contains("$superUser")) {
                                        Get.to(AgentReportList());
                                      } else if (type == "1" || type == "7") {
                                        Get.to(AgentReportList());
                                      }
                                    },
                                    child: Text(
                                      "Agent Report",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: fullWhiteColor,
                                          fontSize: DM.p15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                )
                              : SizedBox(),
                        ],
                      ))
                  : widget.check_type == 2
                      ?
                      //report section
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
                                          vertical: DM.p25, horizontal: DM.p10),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: DM.p30,
                                                vertical: DM.p20),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        DM.p10)),
                                            primary: orangeColor),
                                        onPressed: () async {
                                          Get.to(AgentReportList());
                                        },
                                        child: Text(
                                          "Daily Report",
                                          textAlign: TextAlign.center,
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
                            ],
                          ))
                      : Container(),
            ],
          ),
        ),
      ),
    );
  }
}

//radious
//backgrounddd

