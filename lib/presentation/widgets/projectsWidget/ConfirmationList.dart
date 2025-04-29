import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthcare_homelab/constants/colors.dart';
import 'package:healthcare_homelab/presentation/pages/Create_Request.dart';
import 'package:healthcare_homelab/state_programming/Create_Request_Controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../db/models/TestDataRequest.dart';
import '../../../responsives/dimensions.dart';
import '../../pages/Login_info.dart';

class ConfirmationList extends StatefulWidget {

  VoidCallback uploadImage;
  TestDataRequest newRequestData;
  ConfirmationList(
      {super.key,  required this.newRequestData , required this.uploadImage});

  @override
  State<ConfirmationList> createState() => _ConfirmationListState();
}

class _ConfirmationListState extends State<ConfirmationList> {
  CreateRequest_controller cr_controller = Get.put(CreateRequest_controller());
  var totalCost = 0;
  var testCost = 0;
  var serviceCost = 0;
  var tubeCost = 0;
  var totalDiscount = 0;
  void calculationProcess() {
    setState(() {
      cr_controller.testData.map((testItem) {
        testCost = testCost + int.parse(testItem.testprice.toString());

        serviceCost =
            max(serviceCost, int.parse(testItem.testprice.toString()));
        tubeCost = tubeCost + int.parse(testItem.testkitprice.toString());
        totalDiscount = totalDiscount + int.parse(testItem.discount.toString());
      }).toList();

      totalCost = testCost + serviceCost + tubeCost - totalDiscount;
    });

    cr_controller.totalCost.value = totalCost;
    cr_controller.totalTestCost.value = testCost;
    cr_controller.serviceCost.value = serviceCost;
    cr_controller.tubeCost.value = tubeCost;
    cr_controller.totalDiscount.value = totalDiscount;
  }


  void _onLoading(isClosed) {
    if (isClosed) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              height: DM.p80,
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
                    "Submitting, please wait...",
                    style: TextStyle(color: appTheme),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    if (!isClosed) Navigator.pop(context);
    //pop dialog
  }

  @override
  Widget build(BuildContext context) {
    chechkingInternet();
    return Padding(
      padding: EdgeInsets.all(DM.p8),
      child: Stack(
        children: [
          Container(
              color: secondaryColor,
              height: DM.screenHeight * 0.9,
              width: DM.screenWidth * 0.9,
              padding: EdgeInsets.all(DM.p15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Confirmation",
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: DM.p25,
                        color: Color.fromARGB(255, 26, 1, 1)),
                  ),
                  Text(
                    "Name: ${widget.newRequestData.name}",
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: DM.p15,
                        color: Color.fromARGB(255, 26, 1, 1)),
                  ),
                  Text(
                    "Phone: ${widget.newRequestData.mobile}",
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: DM.p15,
                        color: Color.fromARGB(255, 26, 1, 1)),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Test List",
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: DM.p20,
                            color: Color.fromARGB(255, 26, 1, 1)),
                      ),
                      Divider(
                        thickness: DM.p1,
                        color: blackFontColor,
                        indent: DM.screenWidth * 0.2,
                        endIndent: DM.screenWidth * 0.2,
                      ),
                      Card(
                          child: Container(
                        height: DM.screenHeight * 0.40,
                        child: ListView.builder(
                          itemCount: cr_controller.testData.length,
                          itemBuilder: (context, index) {
                            return Container(
                              color: whiteColor,
                              padding: EdgeInsets.symmetric(
                                  horizontal: DM.p10, vertical: DM.p5),
                              margin: EdgeInsets.symmetric(vertical: DM.p10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      width: DM.p130,
                                      child: Text(
                                        cr_controller.testData[index].name +
                                            " (${cr_controller.testData[index].diagnostic_center})",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: DM.p12,
                                            color:
                                                Color.fromARGB(255, 26, 1, 1)),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "Price: " +
                                        (cr_controller
                                                .testData[index].testprice)
                                            .toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: DM.p12,
                                        color: Color.fromARGB(255, 26, 1, 1)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      )),
                    ],
                  ),
                  Text(
                    "(Test + Tube + Collection) = (${cr_controller.totalTestCost.value}+${cr_controller.tubeCost.value}+${cr_controller.serviceCost.value} ) =  ${cr_controller.totalTestCost.value + cr_controller.tubeCost.value + cr_controller.serviceCost.value} /-",
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: DM.p12,
                        color: Color.fromARGB(255, 26, 1, 1)),
                  ),
                  Text(
                    "Discount : ${cr_controller.totalDiscount.value} /-",
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: DM.p13,
                        color: Color.fromARGB(255, 26, 1, 1)),
                  ),
                  Divider(
                    thickness: DM.p1,
                    color: blackFontColor,
                    endIndent: DM.p100,
                  ),
                  Text(
                    "Total Cost: ${widget.newRequestData.totalprice} /-",
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: DM.p18,
                        color: Color.fromARGB(255, 26, 1, 1)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      MaterialButton(
                        onPressed: () {
                          Get.back();
                        },
                        height: DM.p45,
                        minWidth: DM.p120,
                        shape: const StadiumBorder(),
                        color: redColor,
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                              color: fullWhiteColor,
                              fontSize: DM.p15,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      MaterialButton(
                        onPressed: () async {
                          _onLoading(true);
                          if (await chechkingInternet()) {

                            widget.uploadImage();





                              final SharedPreferences prefs = await SharedPreferences.getInstance();
                            var type = prefs.getString("type");
                            getAdminNotification(
                                widget.newRequestData.mobile.toString(),type,
                                context);



                          }
                        },
                        height: DM.p45,
                        minWidth: DM.p120,
                        shape: const StadiumBorder(),
                        color: appTheme,
                        child: Text(
                          "কনফার্ম",
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
          Positioned(
              right: DM.p10,
              top: DM.p10,
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