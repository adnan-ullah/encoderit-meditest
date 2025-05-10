import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthcare_homelab/constants/api.dart';
import 'package:healthcare_homelab/constants/colors.dart';
import 'package:healthcare_homelab/presentation/pages/adminPanel/TestData.dart';
import 'package:healthcare_homelab/state_programming/CreateRequestController.dart';

import '../../../constants/app_info.dart';
import '../../../db/models/TestData.dart';
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
    _onLoading(true);  // Show loading indicator

    // Clear the lists before adding new data
    _testItemsListAdmin.clear();
    _filterTestItemsList.clear();

    // Enable Firebase persistence for offline data
    FirebaseDatabase.instance.setPersistenceEnabled(true);

    // Get the paths for the last six months
    List<String> paths = getLastSixMonthTestDataPaths();

    try {
      // Use Future.wait to fetch all months in parallel
      await Future.wait(paths.map((path) async {
        final dbRef = FirebaseDatabase.instance.ref(path);
        dbRef.keepSynced(true);

        // Fetch data for each path
        final snapshot = await dbRef.get();
        if (snapshot.exists) {
          for (DataSnapshot ds in snapshot.children) {
            final testData = TestData.fromJson(json.decode(jsonEncode(ds.value)));

            // Add data to lists
            _testItemsListAdmin.add(testData);
            _filterTestItemsList.add(testData);
          }
        }
      }));

      // Once all data is fetched, call setState() to update the UI
      setState(() {});
    } catch (e) {
      // Handle errors in the process
      print("Error fetching test items: $e");
    } finally {
      _onLoading(false);  // Hide loading indicator after fetching is complete
    }
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
                    color: appTheme,
                  ),
                  SizedBox(
                    width: DM.p10,
                  ),
                  new Text(
                    "Loading, please wait...",
                    style: TextStyle(color: appTheme),
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

  Future<void> removeFromFirebase(String testItemId) async {
    List<String> paths = getLastSixMonthTestDataPaths();

    for (String path in paths) {
      DatabaseReference dbRef = FirebaseDatabase.instance.ref(path);

      final snapshot = await dbRef.child(testItemId).get();

      if (snapshot.exists) {
        await dbRef.child(testItemId).remove();
        print("Removed $testItemId from $path");
        break; // Exit after removing from the first match
      }
    }
  }


  CreateRequestController cr_controller = Get.put(CreateRequestController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(backgroundColor: appTheme, actions: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: DM.p50, vertical: DM.p10),
          width: DM.screenWidth,
          child: Text(
            "Admin",
            textAlign: TextAlign.left,
            style: TextStyle(color: secondaryColor, fontSize: DM.p30),
          ),
        ),
      ]),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(DM.p8),
          child: Column(
            children: [
              Container(
                  color: secondaryColor,
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
                                                BorderRadius.circular(DM.p40),
                                            borderSide: BorderSide(
                                                width: DM.p1,
                                                color: appTheme)),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(DM.p40),
                                          borderSide: BorderSide(
                                              width: DM.p1,
                                              color:
                                                  appTheme), //<-- SEE HERE
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
                      _filterTestItemsList != null
                          ? Card(
                              child: Container(
                              height: DM.screenHeight * 0.65,
                              child: ListView.builder(
                                itemCount: _filterTestItemsList.length,
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
                                            _filterTestItemsList[index].name +
                                                " (${_filterTestItemsList[index].diagnostic_center})",
                                            overflow: TextOverflow.visible,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontSize: DM.p12,
                                                color: Color.fromARGB(
                                                    255, 26, 1, 1)),
                                          ),
                                        ),
                                        SizedBox(
                                          width: DM.p70,
                                          child: Text(
                                            "Price: " +
                                                _filterTestItemsList[index]
                                                    .testprice
                                                    .toString(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontSize: DM.p12,
                                                color: Color.fromARGB(
                                                    255, 26, 1, 1)),
                                          ),
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
                                                                setState(
                                                                    () {}));

                                                        // deleteFromStore(snapshot.key);
                                                      },
                                                      shape:
                                                          const StadiumBorder(),
                                                      color: appTheme,
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
                                                color: appTheme,
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
                                                              Colors
                                                                  .transparent,
                                                          body: Center(
                                                            child: Container(
                                                                margin: EdgeInsets
                                                                    .all(
                                                                        DM.p10),
                                                                height: DM.p250,
                                                                color:
                                                                    secondaryColor,
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
                                                                          EdgeInsets.all(
                                                                              16),
                                                                      margin: EdgeInsets
                                                                          .all(
                                                                              16),
                                                                      child:
                                                                          Text(
                                                                        "Do you want to delete test item \"${_filterTestItemsList[index].name + " (${_filterTestItemsList[index].diagnostic_center})\" ?"}",
                                                                        style: TextStyle(
                                                                            fontWeight: FontWeight
                                                                                .w400,
                                                                            fontSize: DM
                                                                                .p20,
                                                                            color: Color.fromARGB(
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
                                                                              horizontal: DM.p20,
                                                                              vertical: DM.p10),
                                                                          child:
                                                                              MaterialButton(
                                                                            onPressed:
                                                                                () {
                                                                              Get.back();
                                                                            },
                                                                            height:
                                                                                DM.p40,
                                                                            minWidth:
                                                                                DM.p120,
                                                                            shape:
                                                                                const StadiumBorder(),
                                                                            color:
                                                                                appTheme,
                                                                            child:
                                                                                Text(
                                                                              "Cancel",
                                                                              style: TextStyle(color: fullWhiteColor, fontSize: DM.p15, fontWeight: FontWeight.bold),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          margin: EdgeInsets.symmetric(
                                                                              horizontal: DM.p20,
                                                                              vertical: DM.p10),
                                                                          child:
                                                                              MaterialButton(
                                                                            onPressed:
                                                                                () async {
                                                                              removeFromFirebase(_filterTestItemsList[index].id);

                                                                              //cr_controller.filter_testItemList.removeAt(index);
                                                                              Get.back();
                                                                            },
                                                                            height:
                                                                                DM.p40,
                                                                            minWidth:
                                                                                DM.p120,
                                                                            shape:
                                                                                const StadiumBorder(),
                                                                            color:
                                                                                appTheme,
                                                                            child:
                                                                                Text(
                                                                              "Delete",
                                                                              style: TextStyle(color: fullWhiteColor, fontSize: DM.p15, fontWeight: FontWeight.bold),
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
                            ))
                          : Container(
                              height: DM.screenHeight * 0.60,
                              margin: EdgeInsets.symmetric(vertical: DM.p16),
                              color: whiteColor,
                              child: Center(
                                child: Text(
                                  "Request list empty",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: DM.p25,
                                      color: appTheme),
                                ),
                              ),
                            ),
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
                          color: appTheme,
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