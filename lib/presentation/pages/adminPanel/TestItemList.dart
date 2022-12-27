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
import 'package:healthcare_homelab/presentation/widgets/projectsWidget/WarningDialogu.dart';
import 'package:healthcare_homelab/state_programming/Create_Request_Controller.dart';

import '../../../animations/Custom_Dialog.dart';
import '../../../constants/app_info.dart';
import '../../../responsives/dimensions.dart';

class TestItemList extends StatefulWidget {
  TestItemList({super.key});

  @override
  State<TestItemList> createState() => _TestItemListState();
}

class _TestItemListState extends State<TestItemList> {
  bool isYes = false;

  @override
  void initState() {
    cr_controller.filter_testItemList.clear();
    cr_controller.filter_testItemList.addAll(cr_controller.testItemList);
    // TODO: implement initState
    super.initState();
  }

  var isLoading = true;

  bool isClear = false;
  var searchingText = new TextEditingController();

  void filterigTestItem(dynamic value) {
    if (value.toString().isNotEmpty) {
      setState(() {
        cr_controller.filter_testItemList.clear();
        isClear = true;
      });

      cr_controller.testItemList.map((element) {
        if (element.name
            .toString()
            .toLowerCase()
            .contains(value.toString().toLowerCase())) {
          cr_controller.filter_testItemList.add(element);
        }
      }).toList();
    } else {
      setState(() {
        isClear = false;
      });
      cr_controller.filter_testItemList.clear();
      cr_controller.filter_testItemList.addAll(cr_controller.testItemList);
    }
  }

  Future<void> removeFromFirebase(testItemId) async {
    DatabaseReference _dbref_testReqModel;
    _dbref_testReqModel = FirebaseDatabase.instance.ref("meditest/");

    if (testItemId != null) {
      await _dbref_testReqModel.child("testModel").child(testItemId).remove();
    }
  }

  CreateRequest_controller cr_controller = Get.put(CreateRequest_controller());

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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(DM.p8),
          child: Column(
            children: [
              Container(
                  color: creamColor,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: DM.p10),
                        child: Text(
                          "Test Item list",
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: DM.p25,
                              color: Color.fromARGB(255, 26, 1, 1)),
                        ),
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
                                    controller: searchingText,
                                    onChanged: ((value) {
                                      filterigTestItem(value);
                                    }),
                                    decoration: InputDecoration(
                                        suffixIcon: isClear
                                            ? InkWell(
                                                onTap: (() {
                                                  filterigTestItem("");
                                                }),
                                                child: cr_controller
                                                    .clearBox.value)
                                            : cr_controller.searchBox.value,
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(40),
                                            borderSide: BorderSide(
                                                width: DM.p1,
                                                color: orangeColor)),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(40),
                                          borderSide: BorderSide(
                                              width: DM.p1,
                                              color:
                                                  orangeColor), //<-- SEE HERE
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
                            height: DM.screenHeight * 0.67,
                            child: Obx(
                              () => ListView.builder(
                                itemCount:
                                    cr_controller.filter_testItemList.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    color: whiteColor,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: DM.p10, vertical: DM.p10),
                                    margin:
                                        EdgeInsets.symmetric(vertical: DM.p5),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: DM.p130,
                                          child: Text(
                                            cr_controller
                                                    .filter_testItemList[index]
                                                    .name +
                                                " (${cr_controller.filter_testItemList[index].diagnostic_center})",
                                            overflow: TextOverflow.visible,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontSize: DM.p12,
                                                color: Color.fromARGB(
                                                    255, 26, 1, 1)),
                                          ),
                                        ),
                                        Text(
                                          "Price: " +
                                              cr_controller
                                                  .filter_testItemList[index]
                                                  .testprice
                                                  .toString(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: DM.p12,
                                              color: Color.fromARGB(
                                                  255, 26, 1, 1)),
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
                                                        Get.to(TestDataCreate(
                                                                testItem:
                                                                    cr_controller
                                                                            .filter_testItemList[
                                                                        index]))!
                                                            .then((value) =>
                                                                setState(
                                                                    () {}));

                                                        // deleteFromStore(snapshot.key);
                                                      },
                                                      shape:
                                                          const StadiumBorder(),
                                                      color: orangeColor,
                                                      child: Text(
                                                        "Update",
                                                        style: TextStyle(
                                                            color:
                                                                fullWhiteColor,
                                                            fontSize: DM.p10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ))),
                                              IconButton(
                                                padding: EdgeInsets.zero,
                                                color: orangeColor,
                                                icon: Icon(
                                                  CupertinoIcons.delete,
                                                  size: DM.p25,
                                                ),
                                                onPressed: () {
                                                   void removeItem()  {
                                                    removeFromFirebase(
                                                        cr_controller
                                                            .filter_testItemList[
                                                                index]
                                                            .id);

                                                    cr_controller
                                                        .filter_testItemList
                                                        .removeAt(index);
                                                  }
                                                  showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return MyDialogView(
                                                          myChild:
                                                              WarningDialogue(
                                                            remove: removeItem,
                                                          ),
                                                        );
                                                      });
                                                
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
                      Container(
                        margin: EdgeInsets.symmetric(vertical: DM.p25),
                        child: MaterialButton(
                          onPressed: () {
                            Get.to(TestDataCreate())!
                                .then((value) => setState(() {}));
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
      ),
    );
  }
}


//radious
//backgrounddd