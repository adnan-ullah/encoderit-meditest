import 'dart:convert';
import 'dart:ffi';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:healthcare_homelab/animations/Custom_Dialog.dart';
import 'package:healthcare_homelab/db/databse_model.dart';
import 'package:healthcare_homelab/presentation/pages/Create_Request.dart';
import 'package:healthcare_homelab/presentation/widgets/projectsWidget/TestListDialogueBox.dart';
import 'package:healthcare_homelab/presentation/widgets/projectsWidget/TextBoxDialogBox.dart';
import 'package:healthcare_homelab/presentation/widgets/minorWidgets/smallDialogBox.dart';
import 'package:uuid/uuid.dart';
import '../../constants/colors.dart';
import '../../responsives/dimensions.dart';
import '../../state_programming/Create_Request_Controller.dart';
import '../../state_programming/getController.dart';

class HomeScreen extends StatefulWidget {
  // static const String id = "sign_up_page";

  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CreateRequest_controller createReqController =
      Get.put(CreateRequest_controller());

  late DatabaseReference _dbref_testModel, _dbref_testReqModel;
  var latitude;
  var longitude;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _dbref_testModel = FirebaseDatabase.instance.ref("meditest/");
    _dbref_testReqModel = FirebaseDatabase.instance.ref("meditest/testRequest");
  }

  @override
  Widget build(BuildContext context) {
    Future<void> addData(String data) async {
      var testData = TestData(
          id: Uuid().v4(),
          name: "Abdullah",
          testprice: 412,
          discount: 0,
          diagnostic_center: "Qatar",
          testkitprice: 21,
          lastupdate: "19 August",
          softdelete: "0",
          organization_transport: "XYZ",
          niddle_cost: null,
          transport_cost: null);

               await _dbref_testModel
                .child("testModel")
                .child(testData.id.toString())
                .set(testData.toJson());

                

     
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(backgroundColor: orangeColor, actions: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: DM.p20, vertical: DM.p2),
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

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: DM.p50,
                        )
                      ],
                    ),
                    // #text_field
                    Container(
                        margin: EdgeInsets.symmetric(horizontal: DM.p5),
                        height: MediaQuery.of(context).size.height * 0.6,
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
                        child: Center(
                          child: Container(
                            child: Text(
                              "Empty data",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 20,
                                  color: Color.fromARGB(255, 26, 1, 1)),
                            ),
                          ),
                        )),
                    // child: FirebaseAnimatedList(
                    //   query: _dbref_testModel,
                    //   itemBuilder: ((context, snapshot, animation, index) {
                    //     return Center(
                    //       child: Container(
                    //         child: Text("No data yet"),
                    //       ),
                    //     );
                    //   }),
                    // )),

                    // #signup_button
                    SizedBox(
                      height: 40,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: DM.p20, vertical: DM.p12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MaterialButton(
                            onPressed: () {
                              addData("adnan");
                              Get.to(CreateRequest());
                            },
                            height: DM.p40,
                            minWidth: DM.p120,
                            shape: const StadiumBorder(),
                            color: orangeColor,
                            child: Text(
                              "Create Request",
                              style: TextStyle(
                                  color: fullWhiteColor,
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

