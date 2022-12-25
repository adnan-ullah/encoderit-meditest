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
import 'package:healthcare_homelab/presentation/pages/adminPanel/TestItemList.dart';
import 'package:healthcare_homelab/state_programming/Create_Request_Controller.dart';

import '../../../responsives/dimensions.dart';

class TestItemDialogueBox extends StatefulWidget {
  dynamic keyTitle;

  TestItemDialogueBox({super.key, required this.keyTitle});

  @override
  State<TestItemDialogueBox> createState() => _TestItemDialogueBoxState();
}

class _TestItemDialogueBoxState extends State<TestItemDialogueBox> {
  late CreateRequest_controller cr_Controller;

  bool isClear = false;

  var searchinText = TextEditingController();
  List<dynamic> newTestItemList = [];

  void filterigTestItem(dynamic value) {
    if (value.toString().isNotEmpty) {
      setState(() {
        isClear = true;
      });

      cr_Controller.filter_testItemList.clear();

      cr_Controller.testItemList.map((element) {
        if (element.name
            .toString()
            .toLowerCase()
            .contains(value.toString().toLowerCase())) {
          cr_Controller.filter_testItemList.add(element);
        }
      }).toList();
    } else {
      setState(() {
        isClear = false;
      });
      cr_Controller.filter_testItemList.clear();
      cr_Controller.filter_testItemList.addAll(cr_Controller.testItemList);
    }
  }

  @override
  void initState() {
    
    cr_Controller = Get.put(CreateRequest_controller());
    cr_Controller.filter_testItemList.clear();
    cr_Controller.filter_testItemList.addAll(cr_Controller.testItemList);

    // print("ADNAN" + cr_Controller.testItemList.length.toString());
    // TODO: implement initState
    super.initState();
  }

  var totalCost = 0;
  var testCost = 0;
  var serviceCost = 0;
  var tubeCost = 0;
  var totalDiscount = 0;
  void calculationProcess() {
    setState(() {
      cr_Controller.testData.map((testItem) {
        testCost = testCost + int.parse(testItem.testprice.toString());
        serviceCost = max(serviceCost, testItem.servicecharge);

        tubeCost = tubeCost + int.parse(testItem.testkitprice.toString());
        totalDiscount = totalDiscount + int.parse(testItem.discount.toString());
      }).toList();

      totalCost = testCost + serviceCost + tubeCost - totalDiscount;
    });

    cr_Controller.totalCost.value = totalCost;
    cr_Controller.totalTestCost.value = testCost;
    cr_Controller.serviceCost.value = serviceCost;
    cr_Controller.tubeCost.value = tubeCost;
    cr_Controller.totalDiscount.value = totalDiscount;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(DM.p8),
      child: Stack(
        children: [
          Container(
              color: creamColor,
              height: DM.screenHeight * 0.9,
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
                  Padding(
                    padding: EdgeInsets.all(DM.p10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Obx(
                          () => Flexible(
                            child: Container(
                              height: DM.p45,
                              child: TextFormField(
                                keyboardType: TextInputType.text,
                                controller: searchinText,
                                onChanged: ((value) {
                                  filterigTestItem(value);
                                }),
                                decoration: InputDecoration(
                                    suffixIcon: isClear
                                        ? InkWell(
                                            onTap: (() {
                                              searchinText.text = "";
                                            }),
                                            child: cr_Controller.clearBox.value)
                                        : cr_Controller.searchBox.value,
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(40),
                                        borderSide: BorderSide(
                                            width: DM.p1, color: orangeColor)),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(40),
                                      borderSide: BorderSide(
                                          width: DM.p1,
                                          color: orangeColor), //<-- SEE HERE
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: InputBorder.none,
                                    hintText: "Search",
                                    hintStyle: TextStyle(
                                      color: Colors.grey,
                                      fontSize: DM.p14,
                                    )),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Card(
                      child: Container(
                    height: DM.screenHeight * 0.60,
                    child: Obx(
                      () => ListView.builder(
                        itemCount: cr_Controller.filter_testItemList.length,
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
                                    cr_Controller
                                        .filter_testItemList[index].name,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: DM.p12,
                                        color: Color.fromARGB(255, 26, 1, 1)),
                                  ),
                                ),
                                Text(
                                  "Price: " +
                                      "${cr_Controller.filter_testItemList[index].testprice}"
                                          .toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: DM.p12,
                                      color: Color.fromARGB(255, 26, 1, 1)),
                                ),
                                SizedBox(
                                    height: DM.p45,
                                    width: DM.p80,
                                    child: cr_Controller
                                                    .testItemListWithSelected[
                                                cr_Controller
                                                    .filter_testItemList[index]
                                                    .id] ==
                                            true
                                        ? MaterialButton(
                                            onPressed: () {
                                              cr_Controller.testData.add(
                                                  cr_Controller
                                                          .filter_testItemList[
                                                      index]);

                                              setState(() {
                                                cr_Controller
                                                            .testItemListWithSelected[
                                                        cr_Controller
                                                            .filter_testItemList[
                                                                index]
                                                            .id] =
                                                    !cr_Controller
                                                            .testItemListWithSelected[
                                                        cr_Controller
                                                            .filter_testItemList[
                                                                index]
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
                                              cr_Controller.testData
                                                  .removeWhere((element) =>
                                                      element.id ==
                                                      cr_Controller
                                                          .filter_testItemList[
                                                              index]
                                                          .id);

                                              setState(() {
                                                cr_Controller
                                                            .testItemListWithSelected[
                                                        cr_Controller
                                                            .filter_testItemList[
                                                                index]
                                                            .id] =
                                                    !cr_Controller
                                                            .testItemListWithSelected[
                                                        cr_Controller
                                                            .filter_testItemList[
                                                                index]
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
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  )),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: DM.p10),
                    child: MaterialButton(
                      onPressed: () {
                       // cr_Controller.testItemListWithSelected.ma

                        calculationProcess();



                        // Get.to(CreateRequest());
                        Get.back();
                      },
                      height: DM.p45,
                      minWidth: DM.p130,
                      shape: const StadiumBorder(),
                      color: orangeColor,
                      child: Text(
                        "Add",
                        style: TextStyle(
                            color: fullWhiteColor,
                            fontSize: DM.p15,
                            fontWeight: FontWeight.bold),
                      ),
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
                  Navigator.pop(context);
                },
              ))
        ],
      ),
    );
  }
}


//radious
//backgrounddd