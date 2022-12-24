import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:healthcare_homelab/animations/Custom_Dialog.dart';
import 'package:healthcare_homelab/db/databse_model.dart';
import 'package:healthcare_homelab/presentation/pages/Create_Prescription.dart';
import 'package:healthcare_homelab/presentation/pages/Create_Request.dart';
import 'package:healthcare_homelab/presentation/widgets/projectsWidget/RequestList.dart';
import 'package:healthcare_homelab/presentation/widgets/projectsWidget/TestListDialogueBox.dart';
import 'package:healthcare_homelab/presentation/widgets/projectsWidget/TextBoxDialogBox.dart';
import 'package:healthcare_homelab/presentation/widgets/minorWidgets/smallDialogBox.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../constants/colors.dart';
import '../../responsives/dimensions.dart';
import '../../state_programming/Create_Request_Controller.dart';
import '../../state_programming/getController.dart';
import '../widgets/minorWidgets/frostedContainer.dart';
import 'Login_info.dart';

class HomeScreen extends StatefulWidget {
  // static const String id = "sign_up_page";

  HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CreateRequest_controller createReqController =
      Get.put(CreateRequest_controller());

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(backgroundColor: orangeColor, actions: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: DM.p50, vertical: DM.p10),
          width: MediaQuery.of(context).size.width,
          child: Text(
            "HomePage",
            textAlign: TextAlign.left,
            style: TextStyle(color: creamColor, fontSize: DM.p30),
          ),
        ),
      ]),
      backgroundColor: creamColor,
      body: Container(
        height: DM.screenHeight,
        width: DM.screenWidth,
        child: Container(
          width: DM.screenWidth,
          child: Column(
            children: [
              // #text_field
              Container(
                  margin: EdgeInsets.symmetric(horizontal: DM.p15),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(DM.p10),
                  ),
                  child: RequestList()),

              Container(
                margin:
                    EdgeInsets.symmetric(horizontal: DM.p20, vertical: DM.p5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: SizedBox(
                        child: MaterialButton(
                          onPressed: () async {
                            if (await chechkingInternet())
                              Get.to(Prescription());
                          },
                          height: DM.p50,
                          shape: const StadiumBorder(),
                          color: orangeColor,
                          child: Text(
                            "Prescription \nRequest",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: fullWhiteColor,
                                fontSize: DM.p15,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: DM.p10,
                    ),
                    Expanded(
                      child: SizedBox(
                        child: MaterialButton(
                          onPressed: () async {
                            if (await chechkingInternet()) {
                              createReqController.testData.clear();
                              Get.to(CreateRequest());
                            }
                          },
                          height: DM.p50,
                          shape: const StadiumBorder(),
                          color: orangeColor,
                          child: Text(
                            "Request \nForm",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: fullWhiteColor,
                                fontSize: DM.p15,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )

              // #buttons(facebook & github)
            ],
          ),
        ),
      ),
    );
  }
}

class FormUserInfo extends StatelessWidget {
  dynamic title;
  dynamic value;
  dynamic activate;
  FormUserInfo(
      {Key? key,
      required this.title,
      required this.value,
      required this.activate})
      : super(
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(DM.p1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: DM.p100,
            child: Text(
              title,
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: DM.p14,
                  color: Color.fromARGB(255, 26, 1, 1)),
            ),
          ),
          SizedBox(
            width: DM.p5,
          ),
          Text(":"),
          SizedBox(
            width: DM.p10,
          ),
          Flexible(
            child: Container(
              height: DM.p35,
              child: TextField(
                readOnly: activate,
                decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(width: DM.p1, color: orangeColor)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: DM.p1, color: orangeColor), //<-- SEE HERE
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(horizontal: DM.p10),
                    border: InputBorder.none,
                    hintText: value,
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: DM.p14,
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//top : flat

//: edit text
//gender
//:add test button brdr rdius
// cross sign in list
//golden rose light..
//address
//add test popup
//write your name
//test , transport, total cost
//light green arektu ligh
//outline_border listiitem and info
//freshers...bdjobs

//test , service charge , total cost
//softdelete
// //teststatus (1,2,3,4)
//id__change uuid
//phone 11 Digit
//lastupdate //dateofcreated : time

//invoice number 8 digit with random
//title phone numberit

//id 8 digit


/// Get from gallery
  