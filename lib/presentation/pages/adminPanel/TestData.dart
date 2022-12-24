import 'dart:convert';
import 'dart:ffi';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:healthcare_homelab/animations/Custom_Dialog.dart';

import 'package:healthcare_homelab/presentation/widgets/projectsWidget/ConfirmationList.dart';
import 'package:healthcare_homelab/presentation/widgets/projectsWidget/TestListDialogueBox.dart';
import 'package:healthcare_homelab/presentation/widgets/projectsWidget/TextBoxDialogBox.dart';
import 'package:healthcare_homelab/presentation/widgets/minorWidgets/smallDialogBox.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../constants/colors.dart';
import '../../../db/databse_model.dart';
import '../../../responsives/dimensions.dart';
import '../../../state_programming/Create_Request_Controller.dart';
import '../../../state_programming/getController.dart';
import '../Login_info.dart';

class TestDataCreate extends StatefulWidget {
  // static const String id = "sign_up_page";

  const TestDataCreate({Key? key}) : super(key: key);

  @override
  _TestDataCreateState createState() => _TestDataCreateState();
}

class _TestDataCreateState extends State<TestDataCreate> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  /**
   *  name: parsedJson['name'],
        testprice: parsedJson['testprice'],
        discount: parsedJson['discount'],
        diagnostic_center: parsedJson['diagnostic_center'],
        testkitprice: parsedJson['testkitprice'],
        lastupdate: parsedJson['lastupdate'],
        softdelete: parsedJson['softdelete'],
        transport_cost: parsedJson['transport_cost'],
        niddle_cost: parsedJson['niddle_cost'],
        servicecharge: parsedJson['servicecharge']
   */
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? latitude;
  String? longitude;

  final addressText = TextEditingController();
  final referredAddressText = TextEditingController();

  var name = new TextEditingController();
  var diagnostic_center = new TextEditingController();
  var testkitprice = TextEditingController();
  var softdelete = TextEditingController();
  var transport_cost = TextEditingController();
  var niddle_cost = new TextEditingController();
  var servicecharge = TextEditingController();
  var discount = TextEditingController();
  var testprice = TextEditingController();
  //form variables:

  var newRequestData;

  CreateRequest_controller createReqController =
      Get.put(CreateRequest_controller());

  // Future<void> getSharedData() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   phone.text = prefs.getString("phoneNumber").toString();
  // }

  @override
  Widget build(BuildContext context) {
    chechkingInternet();

    Future<void> addTestRequest() async {
      int currentTime = DateTime.now().millisecondsSinceEpoch;
      // DateTime currentTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      // String currentTime = DateFormat('dd-MMM-yyy').format(tsdate);

      late DatabaseReference _dbref_testReqModel;
      _dbref_testReqModel = FirebaseDatabase.instance.ref("meditest/");

      newRequestData = TestData(
        id: ((Random().nextInt(900000) + 100000).toString()),
        name: name.text,
        servicecharge: servicecharge.text,
        lastupdate: currentTime,
        softdelete: softdelete.text,
        diagnostic_center: diagnostic_center.text,
        discount: discount.text,
        niddle_cost: niddle_cost.text,
        testkitprice: testkitprice.text,
        testprice: testprice.text,
        transport_cost: transport_cost.text,
      );

      // DatabaseEvent ds = await _dbref_testReqModel
      //     .child("testRequest/${newRequestData.mobile.toString()}")
      //     .once();
      //checking duplicate child && add data
      if (newRequestData != null) {
        await _dbref_testReqModel
            .child("testRequest")
            .child(newRequestData.mobile.toString())
            .child(newRequestData.id)
            .set(newRequestData.toJson());

        Get.snackbar(
            margin: EdgeInsets.symmetric(horizontal: DM.p70, vertical: DM.p60),
            duration: Duration(milliseconds: 2000),
            backgroundColor: limeBGColor,
            colorText: whiteColor,
            "Added",
            "Data added , successfully!");
      } else {
        Get.snackbar(
            margin: EdgeInsets.symmetric(horizontal: DM.p70, vertical: DM.p60),
            duration: Duration(milliseconds: 2000),
            backgroundColor: redColor,
            colorText: whiteColor,
            "Request already exist",
            "Failed to added!");
      }
    }

    return Scaffold(
      appBar: AppBar(backgroundColor: orangeColor, actions: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: DM.p50, vertical: DM.p10),
          width: DM.screenWidth,
          child: Text(
            "Test Item form",
            textAlign: TextAlign.left,
            style: TextStyle(color: creamColor, fontSize: DM.p30),
          ),
        ),
      ]),
      backgroundColor: creamColor,
      body: Form(
        key: _formKey,
        child: Container(
          height: DM.screenHeight,
          width: DM.screenWidth,
          child: Container(
            width: DM.screenWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    padding: EdgeInsets.all(DM.p5),
                    margin: EdgeInsets.symmetric(
                        horizontal: DM.p15, vertical: DM.p30),
                    decoration: BoxDecoration(
                        color: whiteColor,
                        borderRadius: BorderRadius.circular(DM.p10),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.shade300,
                              blurRadius: DM.p20,
                              spreadRadius: DM.p1,
                              offset: Offset(0, DM.p1))
                        ]),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FormUserInfo(
                          formKey: _formKey,
                          validatorField: validateString,
                          textInputType: TextInputType.name,
                          controller: name,
                          title: "Name",
                          value: "Write Your Name",
                          activate: false,
                        ),
                        FormUserInfo(
                          formKey: _formKey,
                          validatorField: validateString,
                          textInputType: TextInputType.name,
                          controller: name,
                          title: "Diagnostic center",
                          value: "Write Diagnostic Name",
                          activate: false,
                        ),
                        FormUserInfo(
                          formKey: _formKey,
                          validatorField: validateString,
                          textInputType: TextInputType.name,
                          controller: name,
                          title: "Service charge",
                          value: "20.0",
                          activate: false,
                        ),
                        FormUserInfo(
                          formKey: _formKey,
                          validatorField: validateString,
                          textInputType: TextInputType.name,
                          controller: name,
                          title: "Discount",
                          value: "15.0",
                          activate: false,
                        ),
                        FormUserInfo(
                          formKey: _formKey,
                          validatorField: validateString,
                          textInputType: TextInputType.name,
                          controller: name,
                          title: "Niddle Cost",
                          value: "10.0",
                          activate: false,
                        ),
                        FormUserInfo(
                          formKey: _formKey,
                          validatorField: validateString,
                          textInputType: TextInputType.name,
                          controller: name,
                          title: "Transport cost",
                          value: "50.0",
                          activate: false,
                        ),
                        FormUserInfo(
                          formKey: _formKey,
                          validatorField: validateString,
                          textInputType: TextInputType.name,
                          controller: name,
                          title: "Testkitprice",
                          value: "70.0",
                          activate: false,
                        ),
                      ],
                    )),

                // #text_field

                // #signup_button

                Obx(
                  () => Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: DM.p20, vertical: DM.p2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Test Cost: ${createReqController.totalTestCost.value}",
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: DM.p10,
                              color: Color.fromARGB(255, 26, 1, 1)),
                        ),
                        Text(
                          "Collection Charge: ${createReqController.serviceCost.value}",
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: DM.p10,
                              color: Color.fromARGB(255, 26, 1, 1)),
                        ),
                        Divider(
                          thickness: DM.p1,
                          color: blackFontColor,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total Cost: ${createReqController.totalCost.value}",
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: DM.p15,
                                  color: Color.fromARGB(255, 26, 1, 1)),
                            ),
                            MaterialButton(
                              onPressed: () async {
                                if (_formKey.currentState?.validate() == true) {
                                  if (await chechkingInternet()) {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return MyDialogView(
                                            myChild: ConfirmationList(
                                                newRequestData: newRequestData,
                                                addTestRequest: addTestRequest),
                                          );
                                        });
                                  }
                                } else {
                                  Get.snackbar(
                                      duration: Duration(milliseconds: 2000),
                                      icon: Icon(Icons.error),
                                      margin: EdgeInsets.symmetric(
                                          horizontal: DM.p70, vertical: DM.p60),
                                      backgroundColor:
                                          Color.fromARGB(255, 202, 0, 0),
                                      colorText: whiteColor,
                                      "Error!",
                                      "Please add info properly!");
                                }
                              },
                              height: DM.p40,
                              minWidth: DM.p120,
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
                        ),
                      ],
                    ),
                  ),
                )

                // #buttons(facebook & github)
              ],
            ),
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
  dynamic formKey;
  dynamic validatorField;
  var controller = new TextEditingController();
  var textInputType;
  FormUserInfo(
      {Key? key,
      required this.formKey,
      required this.title,
      required this.value,
      required this.activate,
      required this.controller,
      required this.textInputType,
      required this.validatorField})
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
              height: DM.p42,
              child: TextFormField(
                validator: validatorField,
                onEditingComplete: (() {}),
                keyboardType: textInputType,
                controller: controller,
                readOnly: activate,
                decoration: InputDecoration(
                    errorStyle: TextStyle(fontSize: DM.p9),
                    disabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(width: DM.p1, color: orangeColor)),
                    // focusedErrorBorder: OutlineInputBorder(
                    //     borderSide:
                    //         BorderSide(width: DM.p1, color: orangeColor)),
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
//invoice //timestamp millisecond
//only title mobile number
//invoie last 5 digit+ randomnumber
//teststatus enum
//softdelete 0

String? validateMobile(String? value) {
  if (value?.length != 11)
    return 'Mobile Number must be of 11 digits';
  else
    return null;
}

String? validateString(String? value) {
  if (value?.length == 0)
    return 'Please fill this form';
  else
    return null;
}
