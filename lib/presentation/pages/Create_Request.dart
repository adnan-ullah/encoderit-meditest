import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthcare_homelab/animations/Custom_Dialog.dart';
import 'package:healthcare_homelab/presentation/pages/Create_Request.dart';
import 'package:healthcare_homelab/presentation/widgets/projectsWidget/TestListDialogueBox.dart';
import 'package:healthcare_homelab/presentation/widgets/projectsWidget/TextBoxDialogBox.dart';
import 'package:healthcare_homelab/presentation/widgets/minorWidgets/smallDialogBox.dart';

import '../../constants/colors.dart';
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
  String? gender = "Male";

  final addressText = TextEditingController();
  final referredAddressText = TextEditingController();

  CreateRequest_controller createReqController =
      Get.put(CreateRequest_controller());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(backgroundColor: orangeColor, actions: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: DM.p20, vertical: DM.p2),
          width: MediaQuery.of(context).size.width,
          child: Text(
            "Create a form",
            textAlign: TextAlign.left,
            style: TextStyle(color: creamColor, fontSize: DM.p30),
          ),
        ),
      ]),
      backgroundColor: Colors.transparent,
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
                              title: "Name",
                              value: "Write Your Name",
                              activate: false,
                            ),
                            FormUserInfo(
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
                                color: Color.fromARGB(218, 224, 224, 224),
                                blurRadius: DM.p10,
                                spreadRadius: DM.p1,
                                offset: Offset(0, DM.p5))
                          ]),
                      child: ListView.builder(
                        itemCount: 10,
                        padding: EdgeInsets.symmetric(horizontal: DM.p15),
                        itemBuilder: (context, index) {
                          return Container(
                            color: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: DM.p5, vertical: DM.p10),
                            margin: EdgeInsets.symmetric(vertical: DM.p5),
                            height: DM.p50,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: DM.p170,
                                  child: Text(
                                    "Test 1",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: DM.p15,
                                        color: Color.fromARGB(255, 26, 1, 1)),
                                  ),
                                ),
                                Text(
                                  "Price: 200",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: DM.p15,
                                      color: Color.fromARGB(255, 26, 1, 1)),
                                ),
                                Icon(
                                  CupertinoIcons.xmark_circle,
                                  color: orangeColor,
                                )
                              ],
                            ),
                          );
                        },
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
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return MyDialogView(
                                            myChild: TestItemDialogueBox(
                                          keyTitle: "Referred Address",
                                        ));
                                      });
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