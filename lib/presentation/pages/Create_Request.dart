import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthcare_homelab/animations/Custom_Dialog.dart';
import 'package:healthcare_homelab/presentation/pages/Create_Request.dart';
import 'package:healthcare_homelab/presentation/widgets/minorWidgets/TextBoxDialogBox.dart';
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
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 55,
                padding:
                    EdgeInsets.symmetric(horizontal: DM.p20, vertical: DM.p2),
                width: MediaQuery.of(context).size.width,
                color: orangeColor,
                child: Text(
                  "Create a form",
                  textAlign: TextAlign.left,
                  style: TextStyle(color: creamColor, fontSize: DM.p30),
                ),
              ),
              Expanded(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      SizedBox(
                        height: DM.p15,
                      ),
                      Container(
                          padding: EdgeInsets.all(14),
                          margin: EdgeInsets.symmetric(horizontal: DM.p15),
                          decoration: BoxDecoration(
                              color: Color.fromARGB(255, 255, 255, 255),
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
                              Row(
                                children: [
                                  Text(
                                    "Gender",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 18,
                                        color: Color.fromARGB(255, 26, 1, 1)),
                                  ),
                                  SizedBox(
                                    width: 80,
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
                              Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 100,
                                      child: Text(
                                        "Address",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 18,
                                            color:
                                                Color.fromARGB(255, 26, 1, 1)),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(":"),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Flexible(
                                      child: TextField(
                                        controller: addressText,
                                        onTap: (() {
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return MyDialogView(
                                                    myChild: TextDialogueBox(
                                                  keyTitle: "Address",addressText:addressText
                                                ));
                                              });
                                        }),
                                        decoration: InputDecoration(
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    width: 1,
                                                    color: orangeColor)),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  width: 1,
                                                  color:
                                                      orangeColor), //<-- SEE HERE
                                            ),
                                            filled: true,
                                            fillColor: Colors.white,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: DM.p10),
                                            border: InputBorder.none,
                                            hintText: "Ex:Chittagong",
                                            
                                            hintStyle:
                                                TextStyle(color: Colors.grey)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 100,
                                      child: Text(
                                        "Referred Address",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 18,
                                            color:
                                                Color.fromARGB(255, 26, 1, 1)),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(":"),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Flexible(
                                      child: TextField(
                                        controller: referredAddressText,
                                        onTap: (() {
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return MyDialogView(
                                                    myChild: TextDialogueBox(
                                                        keyTitle:
                                                            "Referred Address",addressText:referredAddressText));
                                              });
                                        }),
                                        decoration: InputDecoration(
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    width: 1,
                                                    color: orangeColor)),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  width: 1,
                                                  color:
                                                      orangeColor), //<-- SEE HERE
                                            ),
                                            filled: true,
                                            fillColor: Colors.white,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: DM.p10),
                                            border: InputBorder.none,
                                            hintText: "Ex:Dhaka",
                                           
                                            hintStyle:
                                                TextStyle(color: Colors.grey)),
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
                            
                            },
                            height: DM.p45,
                            minWidth: DM.p30,
                            shape: const StadiumBorder(),
                            color: orangeColor,
                            child: Text(
                              "Add test",
                              style: TextStyle(
                                  color: font_bgOrange,
                                  fontSize: DM.p15,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          )
                        ],
                      ),
                      // #text_field
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: DM.p5),
                        height: MediaQuery.of(context).size.height * 0.30,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(DM.p10),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.shade300,
                                  blurRadius: DM.p20,
                                  spreadRadius: DM.p10,
                                  offset: Offset(0, DM.p10))
                            ]),
                        child: ListView.builder(
                          itemCount: 10,
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          itemBuilder: (context, index) {
                            return Container(
                              color: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: DM.p5, vertical: 10),
                              margin: EdgeInsets.symmetric(vertical: DM.p5),
                              height: 50,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: 170,
                                    child: Text(
                                      "Test 1",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 15,
                                          color: Color.fromARGB(255, 26, 1, 1)),
                                    ),
                                  ),
                                  Text(
                                    "Price: 200",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 15,
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
                        margin:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Text(
                                  "Test Cost: 400",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: Color.fromARGB(255, 26, 1, 1)),
                                ),
                                Text(
                                  "Total Cost: 400",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: Color.fromARGB(255, 26, 1, 1)),
                                ),
                                Text(
                                  "Total Cost: 800",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: Color.fromARGB(255, 26, 1, 1)),
                                ),
                              ],
                            ),
                            MaterialButton(
                              onPressed: () => {},
                              height: DM.p45,
                              minWidth: DM.p130,
                              shape: const StadiumBorder(),
                              color: orangeColor,
                              child: Text(
                                "Submit",
                                style: TextStyle(
                                    color: font_bgOrange,
                                    fontSize: DM.p15,
                                    fontWeight: FontWeight.bold),
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
      padding: const EdgeInsets.all(3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              title,
              style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                  color: Color.fromARGB(255, 26, 1, 1)),
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Text(":"),
          SizedBox(
            width: 10,
          ),
          Flexible(
            child: TextField(
              readOnly: activate,
              decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 1, color: orangeColor)),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(width: 1, color: orangeColor), //<-- SEE HERE
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: DM.p10),
                  border: InputBorder.none,
                  hintText: value,
                  hintStyle: TextStyle(color: Colors.grey)),
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