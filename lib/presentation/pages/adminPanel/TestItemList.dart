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
  List<TestData> _testItemsListAdmin = [];
  List<TestData> _filterTestItemsList = [];

  Future<void> getTestItemList() async {
    _onLoading(true);
    late DatabaseReference DbrefTestModel;
    DbrefTestModel = FirebaseDatabase.instance.ref("meditest/testModel/");

    DbrefTestModel.onValue.listen((event) {
      setState(() {
        _testItemsListAdmin.clear();
        _filterTestItemsList.clear();
      });

      for (DataSnapshot ds in event.snapshot.children) {
        TestData testData =
            TestData.fromJson(json.decode(jsonEncode(ds.value)));

        setState(() {
          _testItemsListAdmin.add(testData);
          _filterTestItemsList.add(testData);
        });

      }
      if (_testItemsListAdmin != null) _onLoading(false);
    });
  }

  bool isYes = false;
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
      this.getTestItemList();
    });

    // TODO: implement initState
    super.initState();
  }

  bool isClear = false;
  var searchingText = new TextEditingController();

  void filterigTestItem(dynamic value) {
    if (value.toString().isNotEmpty) {
      setState(() {
        _filterTestItemsList.clear();
        isClear = true;
      });

      _testItemsListAdmin.map((element) {
        if (element.name
            .toString()
            .toLowerCase()
            .contains(value.toString().toLowerCase())) {
          _filterTestItemsList.add(element);
        }
      }).toList();
    } else {
      setState(() {
        isClear = false;
      });
      
      _filterTestItemsList.clear();
      _filterTestItemsList.addAll(_testItemsListAdmin);
    }
  }

  Future<void> removeFromFirebase(testItemId) async {
    DatabaseReference DbrefTestReqModel;
    DbrefTestReqModel = FirebaseDatabase.instance.ref("meditest/");

    if (testItemId != null) {
      await DbrefTestReqModel.child("testModel").child(testItemId).remove();
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
                                                  searchingText.text = "";
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
                      _filterTestItemsList!=null? Card(
                          child: Container(
                        height: DM.screenHeight * 0.65,
                        child: ListView.builder(
                          itemCount: _filterTestItemsList.length,
                          itemBuilder: (context, index) {
                            return Container(
                              color: whiteColor,
                              padding: EdgeInsets.symmetric(
                                  horizontal: DM.p10, vertical: DM.p10),
                              margin: EdgeInsets.symmetric(vertical: DM.p5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: DM.p130,
                                    child: Text(
                                      _filterTestItemsList[index].name +
                                          " (${_filterTestItemsList[index].diagnostic_center})",
                                      overflow: TextOverflow.visible,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: DM.p12,
                                          color: Color.fromARGB(255, 26, 1, 1)),
                                    ),
                                  ),
                                  Text(
                                    "Price: " +
                                        _filterTestItemsList[index]
                                            .testprice
                                            .toString(),
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
                                                  Get.to(TestDataCreate(
                                                          testItem:
                                                              _filterTestItemsList[
                                                                  index]))!
                                                      .then((value) =>
                                                          setState(() {}));

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
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return Scaffold(
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    body: Center(
                                                      child: Container(
                                                          margin:
                                                              EdgeInsets.all(
                                                                  DM.p10),
                                                          height: DM.p250,
                                                          color: creamColor,
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Container(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            16),
                                                                margin:
                                                                    EdgeInsets
                                                                        .all(
                                                                            16),
                                                                child: Text(
                                                                  "Do you want to delete test item ${_testItemsListAdmin[index].name + " (${_testItemsListAdmin[index].diagnostic_center})?"}",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      fontSize: DM
                                                                          .p20,
                                                                      color: Color
                                                                          .fromARGB(
                                                                              255,
                                                                              26,
                                                                              1,
                                                                              1)),
                                                                ),
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Container(
                                                                    margin: EdgeInsets.symmetric(
                                                                        horizontal: DM
                                                                            .p20,
                                                                        vertical:
                                                                            DM.p10),
                                                                    child:
                                                                        MaterialButton(
                                                                      onPressed:
                                                                          () {
                                                                        Get.back();
                                                                      },
                                                                      height: DM
                                                                          .p40,
                                                                      minWidth:
                                                                          DM.p120,
                                                                      shape:
                                                                          const StadiumBorder(),
                                                                      color:
                                                                          orangeColor,
                                                                      child:
                                                                          Text(
                                                                        "Cancel",
                                                                        style: TextStyle(
                                                                            color:
                                                                                fullWhiteColor,
                                                                            fontSize:
                                                                                DM.p15,
                                                                            fontWeight: FontWeight.bold),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    margin: EdgeInsets.symmetric(
                                                                        horizontal: DM
                                                                            .p20,
                                                                        vertical:
                                                                            DM.p10),
                                                                    child:
                                                                        MaterialButton(
                                                                      onPressed:
                                                                          () async {
                                                                        removeFromFirebase(
                                                                            _filterTestItemsList[index].id);

                                                                        //cr_controller.filter_testItemList.removeAt(index);
                                                                        Get.back();
                                                                      },
                                                                      height: DM
                                                                          .p40,
                                                                      minWidth:
                                                                          DM.p120,
                                                                      shape:
                                                                          const StadiumBorder(),
                                                                      color:
                                                                          orangeColor,
                                                                      child:
                                                                          Text(
                                                                        "Delete",
                                                                        style: TextStyle(
                                                                            color:
                                                                                fullWhiteColor,
                                                                            fontSize:
                                                                                DM.p15,
                                                                            fontWeight: FontWeight.bold),
                                                                      ),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ],
                                                          )),
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
                      )):
                       Container(
                            height: DM.screenHeight * 0.60,
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
                            ),),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: DM.p10),
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


  // Future<void> getTestItemList() async {
  //   _onLoading(true);
  //   CreateRequest_controller createRequest_controller =
  //       Get.put(CreateRequest_controller());
  //   late DatabaseReference _dbref_testModel;
  //   _dbref_testModel = FirebaseDatabase.instance.ref("meditest/testModel/");

  //   createRequest_controller.testItemList.clear();

  //   createRequest_controller.testItemListWithSelected.clear();
  //   _dbref_testModel.onValue.listen((event) {
  //     for (DataSnapshot ds in event.snapshot.children) {
  //       TestData testData =
  //           TestData.fromJson(json.decode(jsonEncode(ds.value)));

  //       createRequest_controller.testItemList.add(testData);

  //       createRequest_controller.testItemListWithSelected[testData.id] = false;
  //       //false -> add button
  //       //true -> remove button

  //       print(testData.name);
  //     }
  //     cr_controller.filter_testItemList.addAll(cr_controller.testItemList);
  //     if (createRequest_controller.testItemList != null) _onLoading(false);
  //   });
  // }