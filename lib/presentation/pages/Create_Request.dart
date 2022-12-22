import 'dart:convert';
import 'dart:ffi';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:healthcare_homelab/animations/Custom_Dialog.dart';
import 'package:healthcare_homelab/presentation/pages/Create_Request.dart';
import 'package:healthcare_homelab/presentation/widgets/projectsWidget/ConfirmationList.dart';
import 'package:healthcare_homelab/presentation/widgets/projectsWidget/TestListDialogueBox.dart';
import 'package:healthcare_homelab/presentation/widgets/projectsWidget/TextBoxDialogBox.dart';
import 'package:healthcare_homelab/presentation/widgets/minorWidgets/smallDialogBox.dart';
import 'package:intl/intl.dart';
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? latitude;
  String? longitude;
  void getGPS() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied');
      } else if (permission == LocationPermission.deniedForever) {
        print("'Location permissions are permanently denied");
      } else {
        bool servicestatus = await Geolocator.isLocationServiceEnabled();
        if (servicestatus) {
          Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high);
          setState(() {
            longitude = position.longitude.toString();
            latitude = position.latitude.toString();
          });

          print("YEAHHHHH!!!");
        } else {
          print("WRONG");
        }
      }
    } else {
      bool servicestatus = await Geolocator.isLocationServiceEnabled();
      if (servicestatus) {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        setState(() {
          longitude = position.longitude.toString();
          latitude = position.latitude.toString();
        });
        print("YEAHHHHH!!!");
      } else {
        print("GPS Location reallllly granted.");
      }
      print("GPS Location permission granted.");
    }
  }

  @override
  void initState() {
    CreateRequest_controller createRequest_controller =
        Get.put(CreateRequest_controller());
    //populate testlist
    late DatabaseReference _dbref_testModel;
    _dbref_testModel = FirebaseDatabase.instance.ref("meditest/testModel/");

    _dbref_testModel.onValue.listen((event) {
      for (DataSnapshot ds in event.snapshot.children) {
        TestData testData =
            TestData.fromJson(json.decode(jsonEncode(ds.value)));
        createRequest_controller.testItemList.add(testData);
        createRequest_controller.testItemListWithSelected[testData.id] = true;

        print(createRequest_controller.testItemListWithSelected[testData.id]);
      }
    });

    setState(() {
      getGPS();
    });
    // TODO: implement initState
    super.initState();
  }

  final addressText = TextEditingController();
  final referredAddressText = TextEditingController();

  var name = new TextEditingController();
  var age = TextEditingController();
  var phone = TextEditingController();

  //form variables:
  var testCost = 0.0;
  var totalCost = 0.0;
  var serviceCost = 0.0;

  String? gender = "Male";

  CreateRequest_controller createReqController =
      Get.put(CreateRequest_controller());

  @override
  Widget build(BuildContext context) {
    void removeCalulationProcess(id) {
      createReqController.testData.removeWhere((element) => element.id == id);
      setState(() {
        createReqController.testData.map((testItem) {
          testCost = testCost +
              testItem.testprice +
              testItem.testkitprice -
              testItem.discount;
          serviceCost = max(serviceCost, testItem.servicecharge.toDouble());
        }).toList();

        totalCost = testCost + serviceCost;
        createReqController.testItemListWithSelected[id] =
            !createReqController.testItemListWithSelected[id]!;
        createReqController.totalCost.value = totalCost;
        createReqController.totalTestCost.value = testCost;
        createReqController.serviceCost.value = serviceCost;

        testCost = 0;
        totalCost = 0;
        serviceCost = 0;
      });
    }

    String? validateMobile(String? value) {
      if (value?.length != 11)
        return 'Mobile Number must be of 11 digits';
      else
        return null;
    }

    Future<void> addTestRequest() async {
      int currentTime = DateTime.now().millisecondsSinceEpoch;
      // DateTime currentTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      // String currentTime = DateFormat('dd-MMM-yyy').format(tsdate);

      late DatabaseReference _dbref_testReqModel;
      _dbref_testReqModel = FirebaseDatabase.instance.ref("meditest/");

      var newRequestData = TestDataRequest(
          id: ((Random().nextInt(900000) + 100000).toString()),
          name: name.text,
          gender: gender,
          mobile: phone.text,
          age: double.parse(age.text),
          testlist: createReqController.testData,
          totalprice: createReqController.totalCost.value,
          servicecharge: createReqController.serviceCost.value,
          address: addressText.text,
          referrer: referredAddressText.text,
          lastupdate: currentTime,
          dateofcreated: currentTime,
          softdelete: 0,
          latitude: latitude,
          longitude: longitude,
          teststatus: 1,
          invoice_call: phone.text.substring(7) +
              "-" +
              (Random().nextInt(900000) + 100000).toString());

      if (newRequestData != null) {
        await _dbref_testReqModel
            .child("testRequest")
            .child(newRequestData.mobile.toString())
            .child(newRequestData.id)
            .set(newRequestData.toJson());

        Get.snackbar(
            duration: Duration(milliseconds: 2000),
            backgroundColor: whiteColor,
            colorText: orangeColor,
            "Added",
            "Data added , successfully!");
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(backgroundColor: orangeColor, actions: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: DM.p50, vertical: DM.p10),
          width: MediaQuery.of(context).size.width,
          child: Text(
            "Requisition form",
            textAlign: TextAlign.left,
            style: TextStyle(color: creamColor, fontSize: DM.p30),
          ),
        ),
      ]),
      backgroundColor: creamColor,
      body: Form(
        key: _formKey,
        child: Container(
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
                        height: DM.p2,
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
                                            color:
                                                Color.fromARGB(255, 26, 1, 1)),
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
                                      items: <String>[
                                        'Male',
                                        'Female',
                                      ].map((String value) {
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
                              Padding(
                                padding: EdgeInsets.all(DM.p1),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: DM.p100,
                                      child: Text(
                                        "Phone",
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
                                        height: DM.p50,
                                        child: TextFormField(
                                          validator: validateMobile,
                                          keyboardType: TextInputType.phone,
                                          controller: phone,
                                          onChanged: ((value) {
                                            _formKey.currentState?.validate();
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
                                              hintText: "Ex: 888888888888",
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
                            ],
                          )),
                      SizedBox(
                        height: DM.p7,
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: DM.p120,
                            child: MaterialButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return MyDialogView(
                                        myChild: TestItemDialogueBox(
                                          keyTitle: "Referred Address",
                                        ),
                                      );
                                    });
                              },
                              height: DM.p45,
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
                          ),
                          SizedBox(
                            height: DM.p5,
                          )
                        ],
                      ),
                      // #text_field
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: DM.p5),
                        height: DM.screenHeight * 0.36,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(DM.p10),
                        ),
                        child: Obx(
                          () => ListView.builder(
                            itemCount: createReqController.testData.length,
                            padding: EdgeInsets.symmetric(horizontal: DM.p15),
                            itemBuilder: (context, index) {
                              return Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: DM.p10,
                                ),
                                margin: EdgeInsets.symmetric(vertical: DM.p5),
                                height: DM.p50,
                                decoration: BoxDecoration(
                                  color: whiteColor,
                                  borderRadius: BorderRadius.circular(DM.p10),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: DM.p170,
                                      child: Text(
                                        createReqController
                                            .testData[index].name,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: DM.p15,
                                            color:
                                                Color.fromARGB(255, 26, 1, 1)),
                                      ),
                                    ),
                                    Text(
                                      "Price: ${(createReqController.testData[index].testprice + createReqController.testData[index].testkitprice - createReqController.testData[index].discount)}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: DM.p15,
                                          color: Color.fromARGB(255, 26, 1, 1)),
                                    ),
                                    Container(
                                      child: IconButton(
                                        color: orangeColor,
                                        icon: Icon(
                                          CupertinoIcons.xmark_circle_fill,
                                          size: 30,
                                        ),
                                        onPressed: () {
                                          // createReqController.removeTestData(
                                          //     createReqController
                                          //         .testData[index].id,
                                          //     index);
                                          removeCalulationProcess(
                                              createReqController
                                                  .testData[index].id);
                                          // createReqController
                                          //     .calulationTestdata();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // #signup_button

                      Obx(
                        () => Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: DM.p20, vertical: DM.p12),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Total Cost: ${createReqController.totalCost.value}",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: DM.p15,
                                        color: Color.fromARGB(255, 26, 1, 1)),
                                  ),
                                  MaterialButton(
                                    onPressed: () {
                                      if (_formKey.currentState?.validate() ==
                                          true)
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return MyDialogView(
                                                myChild: ConfirmationList(
                                                    addTestRequest:
                                                        addTestRequest),
                                              );
                                            });
                                      else {
                                        Get.snackbar(
                                            duration:
                                                Duration(milliseconds: 2000),
                                            icon: Icon(Icons.error),
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
//invoice //timestamp millisecond
//only title mobile number
//invoie last 5 digit+ randomnumber
//teststatus enum
//softdelete 0
