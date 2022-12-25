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
import 'package:healthcare_homelab/presentation/pages/adminPanel/TestData.dart';
import 'package:healthcare_homelab/state_programming/Create_Request_Controller.dart';

import '../../../responsives/dimensions.dart';

class TestItemList extends StatefulWidget {
  TestItemList({super.key});

  @override
  State<TestItemList> createState() => _TestItemListState();
}

class _TestItemListState extends State<TestItemList> {
  @override
  void initState() {
    getTestItemList();

    // TODO: implement initState
    super.initState();
  }

  CreateRequest_controller cr_controller = Get.put(CreateRequest_controller());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(DM.p8),
        child: Column(
          children: [
            Container(
                color: creamColor,
                height: DM.screenHeight * 0.9,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Test Item list",
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: DM.p25,
                          color: Color.fromARGB(255, 26, 1, 1)),
                    ),
                    Obx(
                      () => Card(
                          child: Container(
                        height: DM.screenHeight * 0.70,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                        cr_controller.testItemList[index]
                                                    .testprice.toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: DM.p12,
                                        color: Color.fromARGB(255, 26, 1, 1)),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: DM.p10),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                            height: DM.p45,
                                            width: DM.p80,
                                            child: MaterialButton(
                                                onPressed: () {
                                                  Get.to(TestDataCreate( testItem: cr_controller
                                                      .testItemList[index]));
                                                 

                                                  // deleteFromStore(snapshot.key);
                                                },
                                                shape: const StadiumBorder(),
                                                color: orangeColor,
                                                child: Text(
                                                  "Update",
                                                  style: TextStyle(
                                                      color: fullWhiteColor,
                                                      fontSize: DM.p10,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ))),
                                        IconButton(
                                          padding: EdgeInsets.zero,
                                          color: orangeColor,
                                          icon: Icon(
                                            CupertinoIcons.delete,
                                            size: DM.p25,
                                          ),
                                          onPressed: () {
                                            setState(() {});
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      )),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MaterialButton(
                          onPressed: () {
                            //

                         Get.to(TestDataCreate());
                           
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
                      ],
                    )
                  ],
                )),
          ],
        ),
      ),
    );
  }
}


//radious
//backgrounddd