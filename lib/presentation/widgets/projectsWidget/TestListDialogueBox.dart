import 'dart:convert';

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
  late DatabaseReference _dbref_testModel;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _dbref_testModel = FirebaseDatabase.instance.ref("meditest/testModel");
  }

  Future<void> deleteFromStore(id) async {
    await _dbref_testModel.child(id.toString()).remove();
  }

  CreateRequest_controller createRequest_controller =
      Get.put(CreateRequest_controller());

  @override
  Widget build(BuildContext context) {
    Future<void> addTestData() async {
      DatabaseReference _dbref_testModel;
      _dbref_testModel = FirebaseDatabase.instance.ref("meditest/testModel/");

      _dbref_testModel.onValue.listen((event) {
        final newTestItem = event.snapshot
            .child(createRequest_controller.testKey.value.toString())
            .value;

        TestData testData =
            TestData.fromJson(json.decode(jsonEncode(newTestItem)));

        createRequest_controller.testData.add(testData);
        createRequest_controller.getTotal(testData);
      });
    }

  

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          Container(
              color: creamColor,
              height: DM.screenHeight * 0.8,
              width: DM.screenWidth * 0.9,
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Test list",
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 25,
                        color: Color.fromARGB(255, 26, 1, 1)),
                  ),
                  Card(
                      color: Colors.white,
                      child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Container(
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.60,
                              child: FirebaseAnimatedList(
                                query: _dbref_testModel,
                                padding:
                                    EdgeInsets.symmetric(horizontal: DM.p15),
                                itemBuilder:
                                    (context, snapshot, animation, index) {
                                  return Container(
                                    color: Color.fromARGB(255, 255, 237, 237),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: DM.p10, vertical: DM.p10),
                                    margin:
                                        EdgeInsets.symmetric(vertical: DM.p10),
                                    height: DM.p50,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: DM.p55,
                                          child: Text(
                                            snapshot
                                                .child("name")
                                                .value
                                                .toString(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontSize: DM.p12,
                                                color: Color.fromARGB(
                                                    255, 26, 1, 1)),
                                          ),
                                        ),
                                        Text(
                                          snapshot
                                              .child("testprice")
                                              .value
                                              .toString(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: DM.p12,
                                              color: Color.fromARGB(
                                                  255, 26, 1, 1)),
                                        ),
                                        MaterialButton(
                                          onPressed: () {
                                            createRequest_controller
                                                    .testKey.value =
                                                snapshot.key.toString();

                                            addTestData();

                                            Get.back();

                                            // deleteFromStore(snapshot.key);
                                          },
                                          height: DM.p45,
                                          minWidth: DM.p70,
                                          shape: const StadiumBorder(),
                                          color: Colors.greenAccent,
                                          child: Text(
                                            "Add",
                                            style: TextStyle(
                                                color: fullWhiteColor,
                                                fontSize: DM.p10,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        MaterialButton(
                                          onPressed: () {
                                            createRequest_controller
                                                    .testKey.value =
                                                snapshot.key.toString();

                                            createRequest_controller.removeTestData();

                                            Get.back();

                                            // deleteFromStore(snapshot.key);
                                          },
                                          height: DM.p45,
                                          minWidth: DM.p70,
                                          shape: const StadiumBorder(),
                                          color: orangeColor,
                                          child: Text(
                                            "Remove",
                                            style: TextStyle(
                                                color: fullWhiteColor,
                                                fontSize: DM.p10,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ))),
                  MaterialButton(
                    onPressed: () {
                      Get.to(new CreateRequest());
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