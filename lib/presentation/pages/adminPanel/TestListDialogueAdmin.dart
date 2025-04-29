import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthcare_homelab/constants/colors.dart';
import 'package:healthcare_homelab/state_programming/CreateRequestController.dart';

import '../../../responsives/dimensions.dart';

class TestListDialogueAdmin extends StatefulWidget {
  var testItemList;
  var testItemWithSelected;

  TestListDialogueAdmin({
    super.key,
    required this.testItemList,
    required this.testItemWithSelected,
  });

  @override
  State<TestListDialogueAdmin> createState() => _TestListDialogueAdminState();
}

class _TestListDialogueAdminState extends State<TestListDialogueAdmin> {
  late CreateRequestController cr_Controller;
  var filter_testItemList = [];

  bool isClear = false;

  var searchingText = TextEditingController();

  void filterigTestItem(dynamic value) {
    if (value.toString().isNotEmpty) {
      setState(() {
        isClear = true;
      });

      filter_testItemList.clear();

      widget.testItemList.map((element) {
        if (element.name
            .toString()
            .toLowerCase()
            .contains(value.toString().toLowerCase())) {
          filter_testItemList.add(element);
        }
      }).toList();
    } else {
      setState(() {
        isClear = false;
      });
      filter_testItemList.clear();
      filter_testItemList.addAll(widget.testItemList);
    }
  }

  @override
  void initState() {
    cr_Controller = Get.put(CreateRequestController());

    filter_testItemList.addAll(widget.testItemList);

    // print("ADNAN" + cr_Controller.testItemList.length.toString());
    // TODO: implement initState
    super.initState();
  }

  var totalCost = 0;
  var testCost = 0;
  var serviceCost = 0;
  var tubeCost = 0;
  var totalDiscount = 0;

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
                      child: ListView.builder(
                        itemCount: filter_testItemList.length,
                        itemBuilder: (context, index) {
                          return Container(
                            color: whiteColor,
                            padding: EdgeInsets.symmetric(
                                horizontal: DM.p10, vertical: DM.p4),
                            margin: EdgeInsets.symmetric(vertical: DM.p8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: DM.p130,
                                  child: Text(
                                    filter_testItemList[index].name +
                                        " (${filter_testItemList[index].diagnostic_center})",
                                    overflow: TextOverflow.visible,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: DM.p12,
                                        color: Color.fromARGB(255, 26, 1, 1)),
                                  ),
                                ),
                                Text(
                                  "Price: " +
                                      "${filter_testItemList[index].testprice}"
                                          .toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: DM.p12,
                                      color: Color.fromARGB(255, 26, 1, 1)),
                                ),
                                SizedBox(
                                    height: DM.p35,
                                    width: DM.p80,
                                    child: widget.testItemWithSelected[
                                                filter_testItemList[index]
                                                    .id] ==
                                            false
                                        ? MaterialButton(
                                            onPressed: () {
                                              setState(() {
                                                widget.testItemWithSelected[
                                                        filter_testItemList[
                                                                index]
                                                            .id] =
                                                    !widget.testItemWithSelected[
                                                        filter_testItemList[
                                                                index]
                                                            .id]!;
                                              });

                                              // deleteFromStore(snapshot.key);
                                            },
                                            shape: const StadiumBorder(),
                                            color: appTheme,
                                            child: Text(
                                              "Add",
                                              style: TextStyle(
                                                  color: fullWhiteColor,
                                                  fontSize: DM.p10,
                                                  fontWeight: FontWeight.bold),
                                            ))
                                        : MaterialButton(
                                            onPressed: () {
                                              setState(() {
                                                widget.testItemWithSelected[
                                                        filter_testItemList[
                                                                index]
                                                            .id] =
                                                    !widget.testItemWithSelected[
                                                        filter_testItemList[
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
                                                  fontSize: DM.p8,
                                                  fontWeight: FontWeight.bold),
                                            ))),
                              ],
                            ),
                          );
                        },
                      ),
                    )),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: DM.p10),
                      child: MaterialButton(
                        onPressed: () {
                          Get.back();
                          // calculationProcess();

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
                    // widget.testItemWithSelected
                    //     .updateAll((key, value) => value = false);
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
