import 'dart:convert';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthcare_homelab/constants/colors.dart';
import 'package:healthcare_homelab/db/databse_model.dart';
import 'package:healthcare_homelab/presentation/pages/Create_Request.dart';
import 'package:healthcare_homelab/state_programming/Create_Request_Controller.dart';

import '../../../responsives/dimensions.dart';
import '../../pages/Login_info.dart';

class ConfirmationTestItem extends StatefulWidget {
  VoidCallback addTestRequest;
  TestDataRequest newRequestData;
  ConfirmationTestItem(
      {super.key, required this.addTestRequest, required this.newRequestData});

  @override
  State<ConfirmationTestItem> createState() => _ConfirmationTestItemState();
}

class _ConfirmationTestItemState extends State<ConfirmationTestItem> {
  CreateRequest_controller cr_controller = Get.put(CreateRequest_controller());
  var totalCost = 0;
  var testCost = 0;
  var serviceCost = 0;

  void calculationProcess() {
    setState(() {
      cr_controller.testData.map((testItem) {
        testCost = testCost + int.parse(testItem.testprice);
        serviceCost = max(serviceCost, testItem.servicecharge.toDouble());
      }).toList();

      totalCost = testCost + serviceCost;
    });

    cr_controller.totalCost.value = totalCost;
    cr_controller.totalTestCost.value = testCost;
    cr_controller.serviceCost.value = serviceCost;
  }

  @override
  Widget build(BuildContext context) {
    chechkingInternet();
    return Padding(
      padding: EdgeInsets.all(DM.p8),
      child: Stack(
        children: [
          Container(
              color: creamColor,
              height: DM.screenHeight * 0.8,
              width: DM.screenWidth * 0.9,
              padding: EdgeInsets.all(DM.p15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Confirmation",
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: DM.p25,
                        color: Color.fromARGB(255, 26, 1, 1)),
                  ),
                  Text(
                    "Name: ${widget.newRequestData.name}",
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: DM.p15,
                        color: Color.fromARGB(255, 26, 1, 1)),
                  ),
                  Text(
                    "Phone: ${widget.newRequestData.mobile}",
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: DM.p15,
                        color: Color.fromARGB(255, 26, 1, 1)),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Test List",
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: DM.p20,
                            color: Color.fromARGB(255, 26, 1, 1)),
                      ),
                      Divider(
                        thickness: DM.p1,
                        color: blackFontColor,
                        indent: DM.screenWidth * 0.2,
                        endIndent: DM.screenWidth * 0.2,
                      ),
                      Card(
                          child: Container(
                        height: DM.screenHeight * 0.40,
                        child: ListView.builder(
                          itemCount: cr_controller.testData.length,
                          itemBuilder: (context, index) {
                            return Container(
                              color: whiteColor,
                              padding: EdgeInsets.symmetric(
                                  horizontal: DM.p10, vertical: DM.p10),
                              margin: EdgeInsets.symmetric(vertical: DM.p10),
                              height: DM.p50,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: DM.p130,
                                    child: Text(
                                      cr_controller.testData[index].name,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: DM.p12,
                                          color: Color.fromARGB(255, 26, 1, 1)),
                                    ),
                                  ),
                                  Text(
                                    "Price: " +
                                        (cr_controller
                                                    .testData[index].testprice +
                                                cr_controller.testData[index]
                                                    .testkitprice -
                                                cr_controller
                                                    .testData[index].discount)
                                            .toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: DM.p12,
                                        color: Color.fromARGB(255, 26, 1, 1)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      )),
                    ],
                  ),
                  Text(
                    "Test Cost: ${widget.newRequestData.totalprice}",
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: DM.p15,
                        color: Color.fromARGB(255, 26, 1, 1)),
                  ),
                  Text(
                    "Collection Charge: ${widget.newRequestData.servicecharge}",
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: DM.p15,
                        color: Color.fromARGB(255, 26, 1, 1)),
                  ),
                  Divider(
                    thickness: DM.p1,
                    color: blackFontColor,
                    endIndent: DM.p100,
                  ),
                  Text(
                    "Total Cost: ${widget.newRequestData.totalprice}",
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: DM.p18,
                        color: Color.fromARGB(255, 26, 1, 1)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      MaterialButton(
                        onPressed: () {
                          Get.back();
                        },
                        height: DM.p45,
                        minWidth: DM.p120,
                        shape: const StadiumBorder(),
                        color: redColor,
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                              color: fullWhiteColor,
                              fontSize: DM.p15,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      MaterialButton(
                        onPressed: () async {
                          if (await chechkingInternet()) {
                            widget.addTestRequest();
                            Get.back();
                          }
                        },
                        height: DM.p45,
                        minWidth: DM.p120,
                        shape: const StadiumBorder(),
                        color: orangeColor,
                        child: Text(
                          "Confirm",
                          style: TextStyle(
                              color: fullWhiteColor,
                              fontSize: DM.p15,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  )
                ],
              )),
          Positioned(
              right: DM.p10,
              top: DM.p10,
              child: IconButton(
                icon: Icon(CupertinoIcons.xmark),
                onPressed: () {
                  Get.back();
                },
              ))
        ],
      ),
    );
  }
}


//radious
//backgrounddd