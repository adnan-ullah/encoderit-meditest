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

class ConfirmationList extends StatefulWidget {
  VoidCallback addTestRequest;
  ConfirmationList({
    super.key,
    required this.addTestRequest
  });

  @override
  State<ConfirmationList> createState() => _ConfirmationListState();
}

class _ConfirmationListState extends State<ConfirmationList> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  CreateRequest_controller cr_controller = Get.put(CreateRequest_controller());
  var totalCost = 0.0;
  var testCost = 0.0;
  var serviceCost = 0.0;

  void calculationProcess() {
    setState(() {
      cr_controller.testData.map((testItem) {
        testCost = testCost +
            testItem.testprice +
            testItem.testkitprice -
            testItem.discount;
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
    // Future<void> addTestData() async {
    //   DatabaseReference _dbref_testModel;
    //   _dbref_testModel = FirebaseDatabase.instance.ref("meditest/testModel/");

    //   _dbref_testModel.onValue.listen((event) {
    //     final newTestItem =
    //         event.snapshot.child(cr_controller.testKey.value.toString()).value;

    //     TestData testData =
    //         TestData.fromJson(json.decode(jsonEncode(newTestItem)));

    //     cr_controller.testData.add(testData);
    //     cr_controller.getTotal(testData);
    //   });
    // }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          Container(
              color: creamColor,
              height: DM.screenHeight * 0.8,
              width: DM.screenWidth * 0.9,
              padding: EdgeInsets.all(15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Confirmation",
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 25,
                        color: Color.fromARGB(255, 26, 1, 1)),
                  ),
                  Text(
                    "Name: Adnan Ullah",
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: DM.p15,
                        color: Color.fromARGB(255, 26, 1, 1)),
                  ),
                  Text(
                    "Phone: 4585834387",
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
                        height: MediaQuery.of(context).size.height * 0.40,
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
                    "Test Cost: ${cr_controller.totalTestCost.value}",
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: DM.p15,
                        color: Color.fromARGB(255, 26, 1, 1)),
                  ),
                  Text(
                    "Collection Charge: ${cr_controller.serviceCost.value}",
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: DM.p15,
                        color: Color.fromARGB(255, 26, 1, 1)),
                  ),
                  Divider(
                    thickness: DM.p1,
                    color: blackFontColor,
                    endIndent: 100,
                  ),
                  Text(
                    "Total Cost: ${cr_controller.totalCost.value}",
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
                        onPressed: () {
                          widget.addTestRequest();
                          Get.back();
                        },
                        height: DM.p45,
                        minWidth: DM.p120,
                        shape: const StadiumBorder(),
                        color: orangeColor,
                        child: Text(
                          "Submit",
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
              right: 10,
              top: 10,
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