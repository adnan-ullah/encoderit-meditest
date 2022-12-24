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

class TestItemDialogueBox extends StatefulWidget {
  dynamic keyTitle;

  TestItemDialogueBox({super.key, required this.keyTitle});

  @override
  State<TestItemDialogueBox> createState() => _TestItemDialogueBoxState();
}

class _TestItemDialogueBoxState extends State<TestItemDialogueBox> {
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
    return Padding(
      padding: EdgeInsets.all(DM.p8),
      child: Stack(
        children: [
          Container(
              color: creamColor,
              height: DM.screenHeight * 0.8,
              width: DM.screenWidth * 0.9,
              padding: EdgeInsets.all(DM.p10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Test list",
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: DM.p25,
                        color: Color.fromARGB(255, 26, 1, 1)),
                  ),
                  Card(
                      child: Container(
                    height: DM.screenHeight * 0.60,
                    child: ListView.builder(
                      itemCount: cr_controller.testItemList.length,
                      itemBuilder: (context, index) {
                        return Container(
                          color: whiteColor,
                          padding: EdgeInsets.symmetric(
                              horizontal: DM.p10, vertical: DM.p10),
                          margin: EdgeInsets.symmetric(vertical: DM.p10),
                          height: DM.p50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: DM.p130,
                                child: Text(
                                  cr_controller.testItemList[index].name,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: DM.p12,
                                      color: Color.fromARGB(255, 26, 1, 1)),
                                ),
                              ),
                              Text(
                                "Price: " +
                                    (cr_controller
                                                .testItemList[index].testprice +
                                            cr_controller.testItemList[index]
                                                .testkitprice -
                                            cr_controller
                                                .testItemList[index].discount)
                                        .toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: DM.p12,
                                    color: Color.fromARGB(255, 26, 1, 1)),
                              ),
                              Obx(
                                () => SizedBox(
                                    height: DM.p45,
                                    width: DM.p80,
                                    child: cr_controller
                                                    .testItemListWithSelected[
                                                cr_controller
                                                    .testItemList[index].id] ==
                                            true
                                        ? MaterialButton(
                                            onPressed: () {
                                              // cr_controller
                                              //         .testKey.value =
                                              //     snapshot.key.toString();

                                              // addTestData();
                                              cr_controller.testData.add(
                                                  cr_controller
                                                      .testItemList[index]);

                                              setState(() {
                                                cr_controller
                                                            .testItemListWithSelected[
                                                        cr_controller
                                                            .testItemList[index]
                                                            .id] =
                                                    !cr_controller
                                                            .testItemListWithSelected[
                                                        cr_controller
                                                            .testItemList[index]
                                                            .id]!;
                                              });

                                              // deleteFromStore(snapshot.key);
                                            },
                                            shape: const StadiumBorder(),
                                            color: orangeColor,
                                            child: Text(
                                              "Add",
                                              style: TextStyle(
                                                  color: fullWhiteColor,
                                                  fontSize: DM.p10,
                                                  fontWeight: FontWeight.bold),
                                            ))
                                        : MaterialButton(
                                            onPressed: () {
                                              cr_controller.testData
                                                  .removeWhere((element) =>
                                                      element.id ==
                                                      cr_controller
                                                          .testItemList[index]
                                                          .id);

                                              setState(() {
                                                cr_controller
                                                            .testItemListWithSelected[
                                                        cr_controller
                                                            .testItemList[index]
                                                            .id] =
                                                    !cr_controller
                                                            .testItemListWithSelected[
                                                        cr_controller
                                                            .testItemList[index]
                                                            .id]!;
                                              });

                                              // deleteFromStore(snapshot.key);
                                            },
                                            shape: const StadiumBorder(),
                                            color: redColor,
                                            child: Text(
                                              "Remove",
                                              style: TextStyle(
                                                  color: fullWhiteColor,
                                                  fontSize: DM.p10,
                                                  fontWeight: FontWeight.bold),
                                            ))),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  )),
                  MaterialButton(
                    onPressed: () {
                      calculationProcess();

                      // Get.to(CreateRequest());
                      Get.back();
                    },
                    height: DM.p45,
                    minWidth: DM.p130,
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