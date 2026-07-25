import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthcare_homelab/constants/colors.dart';
import 'package:healthcare_homelab/db/models/TestData.dart';
import 'package:healthcare_homelab/state_programming/CreateRequestController.dart';

import '../../../responsives/dimensions.dart';

class TestItemDialogueBox extends StatefulWidget {
  dynamic keyTitle;

  TestItemDialogueBox({super.key, required this.keyTitle});

  @override
  State<TestItemDialogueBox> createState() => _TestItemDialogueBoxState();
}

class _TestItemDialogueBoxState extends State<TestItemDialogueBox> {
  late CreateRequestController cr_Controller;

  bool isClear = false;

  var searchingText = TextEditingController();
  String _query = "";

  /// Filtered view computed live from the controller list, so it always
  /// reflects the latest catalog even if data arrives after the dialog opens.
  List<TestData> get _visibleItems {
    if (_query.isEmpty) return cr_Controller.testItemList;
    return cr_Controller.testItemList
        .where((element) =>
            element.name.toString().toLowerCase().contains(_query))
        .toList();
  }

  void filterigTestItem(dynamic value) {
    setState(() {
      _query = value.toString().toLowerCase().trim();
      isClear = _query.isNotEmpty;
    });
  }

  @override
  void initState() {
    cr_Controller = Get.put(CreateRequestController());
    // Ensure the catalog is loaded (guards against a partial/failed initial load).
    cr_Controller.loadTestItems();
    super.initState();
  }

  var totalCost = 0;
  var testCost = 0;
  var serviceCost = 0;
  var tubeCost = 0;
  var totalDiscount = 0;

  void calculationProcess() {
    cr_Controller.testData.clear();
    cr_Controller.testItemList.map((item) {
      if (cr_Controller.testItemListWithSelected[item.id] == true) {
        cr_Controller.testData.add(item);
        cr_Controller.testItemListWithSelected[item.id] == false;
      }
    }).toList();

    setState(() {
      cr_Controller.testData.map((testItem) {
        testCost = testCost + int.parse(testItem.testprice.toString());
        serviceCost =
            max(serviceCost, int.parse(testItem.servicecharge.toString()));

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

    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(DM.p8),
      child: Obx(
        () => Stack(
          children: [
            Container(
                color: secondaryColor,
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
                          Flexible(
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
                                            child: cr_Controller.clearBox.value)
                                        : cr_Controller.searchBox.value,
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(40),
                                        borderSide: BorderSide(
                                            width: DM.p1, color: appTheme)),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(40),
                                      borderSide: BorderSide(
                                          width: DM.p1,
                                          color: appTheme), //<-- SEE HERE
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
                        ],
                      ),
                    ),
                    Card(
                        child: Container(
                      height: DM.screenHeight * 0.60,
                      child: Builder(
                        builder: (context) {
                          final items = _visibleItems;

                          if (cr_Controller.isTestItemsLoading.value &&
                              cr_Controller.testItemList.isEmpty) {
                            return Center(
                              child: CircularProgressIndicator(color: appTheme),
                            );
                          }

                          if (items.isEmpty) {
                            return Center(
                              child: Text(
                                cr_Controller.testItemList.isEmpty
                                    ? "No test items found"
                                    : "No match for your search",
                                style: TextStyle(
                                    fontSize: DM.p14, color: Colors.grey),
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final TestData item = items[index];
                              final bool isSelected = cr_Controller
                                      .testItemListWithSelected[item.id] ==
                                  true;
                              return Container(
                                color: whiteColor,
                                padding: EdgeInsets.symmetric(
                                    horizontal: DM.p10, vertical: DM.p4),
                                margin: EdgeInsets.symmetric(vertical: DM.p8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: DM.p130,
                                      child: Text(
                                        item.name +
                                            " (${item.diagnostic_center})",
                                        overflow: TextOverflow.visible,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: DM.p12,
                                            color:
                                                Color.fromARGB(255, 26, 1, 1)),
                                      ),
                                    ),
                                    Text(
                                      "Price: " + "${item.testprice}".toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: DM.p12,
                                          color: Color.fromARGB(255, 26, 1, 1)),
                                    ),
                                    SizedBox(
                                        height: DM.p35,
                                        width: DM.p80,
                                        child: !isSelected
                                            ? MaterialButton(
                                                onPressed: () {
                                                  setState(() {
                                                    cr_Controller
                                                            .testItemListWithSelected[
                                                        item.id] = true;
                                                  });
                                                },
                                                shape: const StadiumBorder(),
                                                color: appTheme,
                                                child: Text(
                                                  "Add",
                                                  style: TextStyle(
                                                      color: fullWhiteColor,
                                                      fontSize: DM.p10,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ))
                                            : MaterialButton(
                                                onPressed: () {
                                                  setState(() {
                                                    cr_Controller
                                                            .testItemListWithSelected[
                                                        item.id] = false;
                                                  });
                                                },
                                                shape: const StadiumBorder(),
                                                color: redColor,
                                                child: Text(
                                                  "Remove",
                                                  style: TextStyle(
                                                      color: fullWhiteColor,
                                                      fontSize: DM.p8,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ))),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    )),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: DM.p10),
                      child: MaterialButton(
                        onPressed: () {
                          calculationProcess();

                          // Get.to(CreateRequest());
                        },
                        height: DM.p45,
                        minWidth: DM.p130,
                        shape: const StadiumBorder(),
                        color: appTheme,
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
                    cr_Controller.testItemListWithSelected
                        .updateAll((key, value) => value = false);
                    Navigator.pop(context);
                  },
                ))
          ],
        ),
      ),
    );
  }
}


//radious
//backgrounddd