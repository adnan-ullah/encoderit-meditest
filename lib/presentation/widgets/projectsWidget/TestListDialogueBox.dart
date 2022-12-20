import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthcare_homelab/constants/colors.dart';
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
  Widget build(BuildContext context) {
    CreateRequest_controller createRequest_controller =
        Get.put(CreateRequest_controller());
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
                              child: ListView.builder(
                                itemCount: 10,
                                padding:
                                    EdgeInsets.symmetric(horizontal: DM.p15),
                                itemBuilder: (context, index) {
                                  return Container(
                                    color: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: DM.p1, vertical: DM.p10),
                                    margin:
                                        EdgeInsets.symmetric(vertical: DM.p5),
                                    height: DM.p50,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: DM.p55,
                                          child: Text(
                                            "Test 1",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontSize: DM.p12,
                                                color: Color.fromARGB(
                                                    255, 26, 1, 1)),
                                          ),
                                        ),
                                        Text(
                                          "Price: 200",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: DM.p12,
                                              color: Color.fromARGB(
                                                  255, 26, 1, 1)),
                                        ),
                                        MaterialButton(
                                          onPressed: () {
                                            Get.back();
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
