import 'dart:convert';
import 'dart:ffi';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthcare_homelab/animations/Custom_Dialog.dart';
import 'package:healthcare_homelab/presentation/pages/Create_Request.dart';
import 'package:healthcare_homelab/presentation/widgets/projectsWidget/TestListDialogueBox.dart';
import 'package:healthcare_homelab/presentation/widgets/projectsWidget/TextBoxDialogBox.dart';
import 'package:healthcare_homelab/presentation/widgets/minorWidgets/smallDialogBox.dart';
import 'package:uuid/uuid.dart';

import '../../constants/colors.dart';
import '../../db/databse_model.dart';
import '../../responsives/dimensions.dart';
import '../../state_programming/Create_Request_Controller.dart';
import '../../state_programming/getController.dart';

class CreateRequest extends StatefulWidget {
  // static const String id = "sign_up_page";

  const CreateRequest({Key? key}) : super(key: key);

  @override
  _CreateRequestState createState() => _CreateRequestState();
}

class _CreateRequestState extends State<CreateRequest> {
  final addressText = TextEditingController();
  final referredAddressText = TextEditingController();

  var name = new TextEditingController();
  var age = TextEditingController();

  var phone = TextEditingController();

  List<TestData> testDataList = [
    TestData(
        id: Uuid().v4(),
        name: "Abdullah",
        testprice: 412,
        discount: 14,
        diagnostic_center: "Qatar",
        testkitprice: 21,
        lastupdate: "19 August",
        softdelete: "1",
        organization_transport: "XYZ"),
    TestData(
        id: Uuid().v4(),
        name: "Abdullah",
        testprice: 412,
        discount: 14,
        diagnostic_center: "Qatar",
        testkitprice: 21,
        lastupdate: "19 August",
        softdelete: "1",
        organization_transport: "XYZ")
  ];

  //form variables:

  String? gender = "Male";

  CreateRequest_controller createReqController =
      Get.put(CreateRequest_controller());

  @override
  Widget build(BuildContext context) {
    Future<void> addTestRequest() async {
      late DatabaseReference _dbref_testReqModel;
      _dbref_testReqModel = FirebaseDatabase.instance.ref("meditest/");

      var newRequestData = TestDataRequest(
          id: Uuid().v1(),
          name: name.text,
          gender: gender,
          mobile: phone.text,
          age: double.parse(age.text),
          testlist: testDataList,
          totalprice: double.parse("100"),
          transportfee: double.parse("100"),
          address: addressText.text,
          referrer: referredAddressText.text,
          lastupdate: "lastupdate",
          dateofcreated: "dateofcreated",
          softdelete: "softdelete",
          latitude: "latitude",
          longitude: "longitude",
          teststatus: "true");
      if (newRequestData != null) {
        await _dbref_testReqModel
            .child("testRequest")
            .child(newRequestData.id.toString())
            .set(newRequestData.toJson());

        Get.snackbar(
            backgroundColor: Color.fromARGB(255, 64, 131, 245),
            colorText: whiteColor,
            "Added",
            "Data added , successfully!");
      } else {
        Get.snackbar(
            "Warning", "Something error here, please put info properly");
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(backgroundColor: orangeColor, actions: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: DM.p50, vertical: DM.p10),
          width: MediaQuery.of(context).size.width,
          child: Text(
            "Create a form",
            textAlign: TextAlign.left,
            style: TextStyle(color: creamColor, fontSize: DM.p30),
          ),
        ),
      ]),
      backgroundColor: creamColor,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    SizedBox(
                      height: DM.p15,
                    ),
                    Container(
                        padding: EdgeInsets.all(DM.p14),
                        margin: EdgeInsets.symmetric(horizontal: DM.p15),
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FormUserInfo(
                              textInputType: TextInputType.name,
                              controller: name,
                              title: "Name",
                              value: "Write Your Name",
                              activate: false,
                            ),
                            FormUserInfo(
                              textInputType: TextInputType.number,
                              controller: age,
                              title: "Age",
                              value: "Write Your Age",
                              activate: false,
                            ),
                            Padding(
                              padding: EdgeInsets.all(DM.p1),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: DM.p100,
                                    child: Text(
                                      "Gender",
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
                                  DropdownButton<String>(
                                    hint: Text("$gender"),
                                    items: <String>['Male', 'Female', 'Others']
                                        .map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text("$value"),
                                      );
                                    }).toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        gender = newValue;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(DM.p1),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: DM.p100,
                                    child: Text(
                                      "Address",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: DM.p14,
                                          color: blackFontColor),
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
                                        controller: addressText,
                                        onTap: (() {
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return MyDialogView(
                                                    myChild: TextDialogueBox(
                                                        keyTitle: "Address",
                                                        addressText:
                                                            addressText));
                                              });
                                        }),
                                        decoration: InputDecoration(
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    width: DM.p1,
                                                    color: orangeColor)),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  width: DM.p1,
                                                  color:
                                                      orangeColor), //<-- SEE HERE
                                            ),
                                            filled: true,
                                            fillColor: fullWhiteColor,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: DM.p10),
                                            border: InputBorder.none,
                                            hintText: "Ex:Chittagong",
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
                            Padding(
                              padding: EdgeInsets.all(DM.p1),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: DM.p100,
                                    child: Text(
                                      "Referrer",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: DM.p14,
                                          color: blackFontColor),
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
                                        controller: referredAddressText,
                                        onTap: (() {
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return MyDialogView(
                                                    myChild: TextDialogueBox(
                                                        keyTitle:
                                                            "Referrer Info",
                                                        addressText:
                                                            referredAddressText));
                                              });
                                        }),
                                        decoration: InputDecoration(
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    width: DM.p1,
                                                    color: orangeColor)),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  width: DM.p1,
                                                  color:
                                                      orangeColor), //<-- SEE HERE
                                            ),
                                            filled: true,
                                            fillColor: Colors.white,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: DM.p10),
                                            border: InputBorder.none,
                                            hintText: "Name of Doctor",
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
                            FormUserInfo(
                              textInputType: TextInputType.phone,
                              controller: phone,
                              title: "Phone",
                              value: "Ex: 888888888888",
                              activate: false,
                            ),
                          ],
                        )),
                    SizedBox(
                      height: 7,
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MaterialButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return MyDialogView(
                                      myChild: TestItemDialogueBox(
                                    keyTitle: "Referred Address",
                                  ));
                                });
                          },
                          height: DM.p45,
                          minWidth: DM.p30,
                          shape: const StadiumBorder(),
                          color: orangeColor,
                          child: Text(
                            "Add test",
                            style: TextStyle(
                                color: fullWhiteColor,
                                fontSize: DM.p15,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          height: DM.p5,
                        )
                      ],
                    ),
                    // #text_field
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: DM.p5),
                      height: MediaQuery.of(context).size.height * 0.36,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(DM.p10),
                          boxShadow: [
                            BoxShadow(
                                color: green_bg,
                                blurRadius: DM.p10,
                                spreadRadius: DM.p1,
                                offset: Offset(0, DM.p1))
                          ]),
                      child: Obx(
                        () => ListView.builder(
                          itemCount: createReqController.testData.length,
                          padding: EdgeInsets.symmetric(horizontal: DM.p15),
                          itemBuilder: (context, index) {
                            return Container(
                              color: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: DM.p5, vertical: DM.p10),
                              margin: EdgeInsets.symmetric(vertical: DM.p5),
                              height: DM.p50,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: DM.p170,
                                    child: Text(
                                      createReqController.testData[index].name,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: DM.p15,
                                          color: Color.fromARGB(255, 26, 1, 1)),
                                    ),
                                  ),
                                  Text(
                                    "Price: ${createReqController.testData[index].testprice}",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: DM.p15,
                                        color: Color.fromARGB(255, 26, 1, 1)),
                                  ),
                                  IconButton(
                                    color: orangeColor,
                                    icon: Icon(CupertinoIcons.xmark_circle),
                                    onPressed: () {
                                      createReqController.testData
                                          .removeAt(index);
                                    },
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // #signup_button

                    Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: DM.p20, vertical: DM.p12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Test Cost: 400",
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: DM.p10,
                                color: Color.fromARGB(255, 26, 1, 1)),
                          ),
                          Text(
                            "Service Charge: 400",
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: DM.p10,
                                color: Color.fromARGB(255, 26, 1, 1)),
                          ),
                          Divider(
                            thickness: 1,
                            color: blackFontColor,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Total Cost: 800",
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: DM.p15,
                                    color: Color.fromARGB(255, 26, 1, 1)),
                              ),
                              MaterialButton(
                                onPressed: () {
                                  addTestRequest();
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
                    )

                    // #buttons(facebook & github)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FormUserInfo extends StatelessWidget {
  dynamic title;
  dynamic value;
  dynamic activate;
  var controller = new TextEditingController();
  var textInputType;
  FormUserInfo(
      {Key? key,
      required this.title,
      required this.value,
      required this.activate,
      required this.controller,
      required this.textInputType})
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
                keyboardType: textInputType,
                controller: controller,
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