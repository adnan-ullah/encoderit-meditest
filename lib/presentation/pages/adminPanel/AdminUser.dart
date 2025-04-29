import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthcare_homelab/constants/colors.dart';
import 'package:healthcare_homelab/db/databse_model.dart';
import 'package:healthcare_homelab/presentation/pages/adminPanel/AdminUserData.dart';
import 'package:healthcare_homelab/state_programming/Create_Request_Controller.dart';

import '../../../constants/app_info.dart';
import '../../../responsives/dimensions.dart';

class AdminUser extends StatefulWidget {
  AdminUser({super.key});

  @override
  State<AdminUser> createState() => _AdminUserState();
}

class _AdminUserState extends State<AdminUser> {
  List<AdminUserModel> _testItemsListAdmin = [];
  List<AdminUserModel> _filterTestItemsList = [];

  Future<void> getTestItemList() async {
    _onLoading(true);
    late DatabaseReference DbrefTestModel;
    DbrefTestModel = FirebaseDatabase.instance.ref("$database_name/admin_user/");
    FirebaseDatabase.instance.setPersistenceEnabled(true);
    DbrefTestModel.keepSynced(true);

    DbrefTestModel.onValue.listen((event) {
      setState(() {
        _testItemsListAdmin.clear();
        _filterTestItemsList.clear();
      });

      for (DataSnapshot ds in event.snapshot.children) {
        AdminUserModel testData =
            AdminUserModel.fromJson(json.decode(jsonEncode(ds.value)));

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
        if (element.phone
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

  Future<void> removeFromFirebase(phoneNumber) async {
    DatabaseReference DbrefTestReqModel;
    DbrefTestReqModel = FirebaseDatabase.instance.ref("$database_name/");

    if (phoneNumber != null) {
      await DbrefTestReqModel.child("admin_user").child(phoneNumber).remove();
    }
  }

  CreateRequest_controller cr_controller = Get.put(CreateRequest_controller());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(backgroundColor: appTheme, actions: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: DM.p50, vertical: DM.p10),
          width: DM.screenWidth,
          child: Text(
            "Admin User",
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
                          "Admin User List",
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
                          ? Container(
                              height: DM.screenHeight * 0.65,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  Expanded(
                                    child: Card(
                                        child: Container(
                                      height: DM.screenHeight * 0.65,
                                      width: DM.screenWidth * 1.2,
                                      child: ListView.builder(
                                        itemCount: _filterTestItemsList.length,
                                        itemBuilder: (context, index) {
                                          return Container(
                                            color: whiteColor,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: DM.p10,
                                                vertical: DM.p10),
                                            margin: EdgeInsets.symmetric(
                                                vertical: DM.p5),
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  width: DM.p150,
                                                  child: Text(
                                                    " ${_filterTestItemsList[index].surname}_${_filterTestItemsList[index].phone.substring(8)}_${_filterTestItemsList[index].short_address}",
                                                    overflow:
                                                        TextOverflow.visible,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        fontSize: DM.p12,
                                                        color: Color.fromARGB(
                                                            255, 26, 1, 1)),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: DM.p60,
                                                  child: Text(
                                                    "Active: " +
                                                        _filterTestItemsList[
                                                                index]
                                                            .active
                                                            .toString(),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        fontSize: DM.p12,
                                                        color: Color.fromARGB(
                                                            255, 26, 1, 1)),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: DM.p50,
                                                  child: Text(
                                                    "Type: " +
                                                        _filterTestItemsList[
                                                                index]
                                                            .type
                                                            .toString(),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        fontSize: DM.p12,
                                                        color: Color.fromARGB(
                                                            255, 26, 1, 1)),
                                                  ),
                                                ),
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      left: DM.p10),
                                                  child: Row(
                                                    children: [
                                                      SizedBox(
                                                          height: DM.p45,
                                                          width: DM.p70,
                                                          child: MaterialButton(
                                                              onPressed: () {
                                                                Get.to(AdminUserData(
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
                                                              color:
                                                                  appTheme,
                                                              child: Text(
                                                                "Update",
                                                                style: TextStyle(
                                                                    color:
                                                                        fullWhiteColor,
                                                                    fontSize:
                                                                        DM.p10,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ))),
                                                      IconButton(
                                                        padding:
                                                            EdgeInsets.zero,
                                                        color: appTheme,
                                                        icon: Icon(
                                                          CupertinoIcons.delete,
                                                          size: DM.p25,
                                                        ),
                                                        onPressed: () {
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) {
                                                                return Scaffold(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .transparent,
                                                                  body: Center(
                                                                    child: Container(
                                                                        margin: EdgeInsets.all(DM.p10),
                                                                        height: DM.p250,
                                                                        color: secondaryColor,
                                                                        child: Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.center,
                                                                          children: [
                                                                            Container(
                                                                              padding: EdgeInsets.all(16),
                                                                              margin: EdgeInsets.all(16),
                                                                              child: Text(
                                                                                "Do you want to delete test item \"${_filterTestItemsList[index].phone}?",
                                                                                style: TextStyle(fontWeight: FontWeight.w400, fontSize: DM.p20, color: Color.fromARGB(255, 26, 1, 1)),
                                                                              ),
                                                                            ),
                                                                            Row(
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                Container(
                                                                                  margin: EdgeInsets.symmetric(horizontal: DM.p20, vertical: DM.p10),
                                                                                  child: MaterialButton(
                                                                                    onPressed: () {
                                                                                      Get.back();
                                                                                    },
                                                                                    height: DM.p40,
                                                                                    minWidth: DM.p120,
                                                                                    shape: const StadiumBorder(),
                                                                                    color: appTheme,
                                                                                    child: Text(
                                                                                      "Cancel",
                                                                                      style: TextStyle(color: fullWhiteColor, fontSize: DM.p15, fontWeight: FontWeight.bold),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                Container(
                                                                                  margin: EdgeInsets.symmetric(horizontal: DM.p20, vertical: DM.p10),
                                                                                  child: MaterialButton(
                                                                                    onPressed: () async {
                                                                                      removeFromFirebase(_filterTestItemsList[index].phone);

                                                                                      //cr_controller.filter_testItemList.removeAt(index);
                                                                                      Get.back();
                                                                                    },
                                                                                    height: DM.p40,
                                                                                    minWidth: DM.p120,
                                                                                    shape: const StadiumBorder(),
                                                                                    color: appTheme,
                                                                                    child: Text(
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
                                    )),
                                  ),
                                ],
                              ),
                            )
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
                            Get.to(AdminUserData())!
                                .then((value) => setState(() {}));
                          },
                          height: DM.p45,
                          minWidth: DM.p130,
                          shape: const StadiumBorder(),
                          color: appTheme,
                          child: Text(
                            "Create User",
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
  //   _dbref_testModel = FirebaseDatabase.instance.ref("$database_name/testModel/");

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