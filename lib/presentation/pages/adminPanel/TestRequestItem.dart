import 'dart:convert';
import 'dart:ffi';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:healthcare_homelab/presentation/pages/adminPanel/TestData.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:get/get.dart';
import 'package:healthcare_homelab/animations/Custom_Dialog.dart';

import 'package:healthcare_homelab/presentation/widgets/projectsWidget/ConfirmationList.dart';
import 'package:healthcare_homelab/presentation/widgets/projectsWidget/Confirmation_TestItem.dart';
import 'package:healthcare_homelab/presentation/widgets/projectsWidget/TestListDialogueBox.dart';
import 'package:healthcare_homelab/presentation/widgets/projectsWidget/TextBoxDialogBox.dart';
import 'package:healthcare_homelab/presentation/widgets/minorWidgets/smallDialogBox.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:uuid/uuid.dart';

import '../../../constants/colors.dart';
import '../../../db/databse_model.dart';
import '../../../responsives/dimensions.dart';
import '../../../state_programming/Create_Request_Controller.dart';
import '../../../state_programming/getController.dart';
import '../../widgets/minorWidgets/PhotoViewImage.dart';
import '../Login_info.dart';

class TestRequestCreate extends StatefulWidget {
  TestDataRequest? testEachRequest;
  TestRequestCreate({Key? key, this.testEachRequest}) : super(key: key);

  @override
  _TestRequestCreateState createState() => _TestRequestCreateState();
}

class _TestRequestCreateState extends State<TestRequestCreate> {
  var updatedRequestItemData;

  bool isTestlistOpen = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  dynamic latitude;
  dynamic longitude;

  var updateTestRequestItem;
  var name = new TextEditingController();
  String gender = "Male";
  var phone = new TextEditingController();
  var age = new TextEditingController();
  List<TestData> testlist = [];
  var totalprice = new TextEditingController();
  var servicecharge = new TextEditingController();
  var address = new TextEditingController();
  var referrer = new TextEditingController();
  var lastupdate = new TextEditingController();
  var dateofcreated = new TextEditingController();
  var softdelete = new TextEditingController();

  var teststatus = new TextEditingController();
  var invoice_call = new TextEditingController();
  var type = new TextEditingController();
  var image_one = new TextEditingController();
  var image_two = new TextEditingController();

  Future<void> openMap(double latitude, double longitude) async {
    if (await MapLauncher.isMapAvailable(MapType.google) != null) {
      await MapLauncher.showMarker(
        zoom: 1000,
        mapType: MapType.google,
        coords: Coords(latitude, longitude),
        title: "title",
        description: "description",
      );
    }
  }

  Future<void> retreiveEachDataRequest() async {
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    type.text = widget.testEachRequest!.type.toString();
    invoice_call.text = widget.testEachRequest!.invoice_call.toString();
    name.text = widget.testEachRequest!.name.toString();
    age.text = widget.testEachRequest!.age.toString();
    phone.text = widget.testEachRequest!.mobile.toString();
    address.text = widget.testEachRequest!.address.toString();
    referrer.text = widget.testEachRequest!.referrer.toString();
    servicecharge.text = widget.testEachRequest!.servicecharge.toString();
    totalprice.text = widget.testEachRequest!.totalprice.toString();

    setState(
      () {
        if (widget.testEachRequest!.testlist != null)
          testlist.addAll(widget.testEachRequest!.testlist as List<TestData>);

        print(testlist.toList());
      },
    );

    if (widget.testEachRequest!.image_one == null)
      image_one.text = "empty";
    else
      image_one.text = widget.testEachRequest!.image_one.toString();

    if (widget.testEachRequest!.image_two == null)
      image_two.text = "empty";
    else
      image_two.text = widget.testEachRequest!.image_two.toString();

    print("Image Link" + image_one.text.toString());

    setState(() {
      gender = widget.testEachRequest!.gender;
    });
    softdelete.text = widget.testEachRequest!.softdelete.toString();

    lastupdate.text = widget.testEachRequest!.lastupdate.toString();
    dateofcreated.text = (DateFormat('dd-MMM-yyy').format(
            DateTime.fromMillisecondsSinceEpoch(
                widget.testEachRequest!.dateofcreated)))
        .toString();

    setState(() {
      latitude = widget.testEachRequest!.latitude.toString();
      longitude = widget.testEachRequest!.longitude.toString();
    });
  }

  Future<void> _updateRequest() async {
    late DatabaseReference _dbref_testReqModel;
    _dbref_testReqModel = FirebaseDatabase.instance.ref("meditest/");

    updateTestRequestItem = TestDataRequest(
        id: ((Random().nextInt(900000) + 100000).toString()),
        name: name.text,
        gender: gender,
        mobile: phone.text,
        age: double.parse(age.text),
        testlist: createReqController.testData,
        totalprice: createReqController.totalCost.value,
        servicecharge: createReqController.serviceCost.value,
        address: address.text,
        referrer: referrer.text,
        lastupdate: lastupdate.text,
        dateofcreated: widget.testEachRequest!.dateofcreated,
        softdelete: 0,
        latitude: latitude,
        longitude: longitude,
        teststatus: 1,
        invoice_call: invoice_call.text,
        type: 1,
        image_one: null,
        image_two: null);

    if (updateTestRequestItem != null) {
      await _dbref_testReqModel
          .child("testRequest")
          .child(updateTestRequestItem.mobile)
          .child(updateTestRequestItem.id)
          .update(updateTestRequestItem.toJson());
    }
  }

  var testCost = 0;
  var totalCost = 0;
  var serviceCost = 0;
  var tubeCost = 0;
  var totalDiscount = 0;
  var newRequestData;
  void removeCalulationProcess(id) {
    createReqController.testData.removeWhere((element) => element.id == id);
    setState(() {
      createReqController.testData.map((testItem) {
        testCost = testCost + int.parse(testItem.testprice.toString());
        serviceCost =
            max(serviceCost, int.parse(testItem.servicecharge.toString()));

        tubeCost = tubeCost + int.parse(testItem.testkitprice.toString());
        totalDiscount = totalDiscount + int.parse(testItem.discount.toString());
      }).toList();

      totalCost = testCost + serviceCost + tubeCost - totalDiscount;

      createReqController.testItemListWithSelected[id] =
          !createReqController.testItemListWithSelected[id]!;

      createReqController.totalCost.value = totalCost;
      createReqController.totalTestCost.value = testCost;
      createReqController.serviceCost.value = serviceCost;
      createReqController.totalDiscount.value = totalDiscount;
      createReqController.tubeCost.value = tubeCost;

      testCost = 0;
      totalCost = 0;
      serviceCost = 0;
      tubeCost = 0;

      totalDiscount = 0;
    });
  }

  @override
  void initState() {
    if (widget.testEachRequest != null) {
      print("From Update Class");
      this.retreiveEachDataRequest();
    } else {
      print("From New Item Class");
    }

    // TODO: implement initState
    super.initState();
  }

  var newTestListData;

  CreateRequest_controller createReqController =
      Get.put(CreateRequest_controller());

  @override
  Widget build(BuildContext context) {
    chechkingInternet();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(backgroundColor: orangeColor, actions: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: DM.p50, vertical: DM.p10),
          width: DM.screenWidth,
          child: Text(
            "Test Request Form",
            textAlign: TextAlign.left,
            style: TextStyle(color: creamColor, fontSize: DM.p30),
          ),
        ),
      ]),
      backgroundColor: creamColor,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Container(
            width: DM.screenWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: DM.p15, vertical: DM.p10),
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
                          controller: type,
                          title: "Type",
                          value: "0",
                          activate: false,
                        ),
                        FormUserInfo(
                          formKey: _formKey,
                          validatorField: validateString,
                          textInputType: TextInputType.name,
                          controller: invoice_call,
                          title: "Invoice Number",
                          value: "#12345-100",
                          activate: true,
                        ),
                        FormUserInfo(
                          formKey: _formKey,
                          validatorField: validateString,
                          textInputType: TextInputType.name,
                          controller: name,
                          title: "Name",
                          value: "Write yout name",
                          activate: false,
                        ),
                        FormUserInfo(
                          formKey: _formKey,
                          validatorField: validateMobile,
                          textInputType: TextInputType.phone,
                          controller: phone,
                          title: "Contact Number",
                          value: "#0000",
                          activate: false,
                        ),
                        Padding(
                          padding: EdgeInsets.all(DM.p5),
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
                                    gender = newValue!;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        FormUserInfo(
                          formKey: _formKey,
                          validatorField: validateString,
                          textInputType: TextInputType.number,
                          controller: age,
                          title: "Age",
                          value: "2",
                          activate: false,
                        ),
                        Padding(
                          padding: EdgeInsets.all(DM.p5),
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
                                  height: DM.p42,
                                  child: TextFormField(
                                    controller: address,
                                    onTap: (() {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return MyDialogView(
                                                myChild: TextDialogueBox(
                                                    keyTitle: "Address",
                                                    addressText: address));
                                          });
                                    }),
                                    decoration: InputDecoration(
                                        errorStyle: TextStyle(fontSize: DM.p9),
                                        // focusedErrorBorder:
                                        //     OutlineInputBorder(
                                        //         borderSide: BorderSide(
                                        //             width: DM.p1,
                                        //             color:
                                        //                 orangeColor)),
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
                                        contentPadding: EdgeInsets.symmetric(
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
                          padding: EdgeInsets.all(DM.p5),
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
                                  height: DM.p42,
                                  child: TextFormField(
                                    controller: referrer,
                                    onTap: (() {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return MyDialogView(
                                                myChild: TextDialogueBox(
                                                    keyTitle: "Referrer Info",
                                                    addressText: referrer));
                                          });
                                    }),
                                    decoration: InputDecoration(
                                        errorStyle: TextStyle(fontSize: DM.p9),
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
                                        contentPadding: EdgeInsets.symmetric(
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
                          formKey: _formKey,
                          validatorField: validateString,
                          textInputType: TextInputType.name,
                          controller: dateofcreated,
                          title: "Date of created",
                          value: "15 Dec 2014",
                          activate: true,
                        ),
                        Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(DM.p5),
                              child: Row(
                                children: [
                                  Text(
                                    "Test Item  ",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: DM.p14,
                                        color: Color.fromARGB(255, 26, 1, 1)),
                                  ),
                                  SizedBox(
                                    width: DM.p40,
                                  ),
                                  Text(":"),
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: DM.p20, vertical: DM.p1),
                                    child: MaterialButton(
                                      height: DM.p40,
                                      minWidth: DM.p100,
                                      shape: const StadiumBorder(),
                                      color: orangeColor,
                                      onPressed: () async {
                                        if (await chechkingInternet()) {
                                          createReqController.testData
                                              .map((element) {
                                            createReqController
                                                    .testItemListWithSelected[
                                                element.id] = true;
                                          }).toList();

                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return MyDialogView(
                                                  myChild: TestItemDialogueBox(
                                                    keyTitle:
                                                        "Referred Address",
                                                  ),
                                                );
                                              });
                                        }
                                      },
                                      child: Text(
                                        "Add",
                                        style: TextStyle(
                                            color: fullWhiteColor,
                                            fontSize: DM.p15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: DM.p10, vertical: DM.p3),
                              height: DM.screenHeight * 0.35,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: whiteColor,
                                borderRadius: BorderRadius.circular(DM.p10),
                              ),
                              child: testlist.length != 0
                                  ? ListView.builder(
                                      itemCount: testlist.length,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: DM.p15),
                                      itemBuilder: (context, index) {
                                        return Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: DM.p1,
                                          ),
                                          margin: EdgeInsets.only(top: DM.p10),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(DM.p10),
                                          ),
                                          child: Container(
                                            margin: EdgeInsets.only(left: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                SizedBox(
                                                  width: DM.p170,
                                                  child: Text(
                                                    testlist[index].name,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        fontSize: DM.p15,
                                                        color: Color.fromARGB(
                                                            255, 26, 1, 1)),
                                                  ),
                                                ),
                                                Text(
                                                  "Price: ${testlist[index].testprice}",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      fontSize: DM.p15,
                                                      color: Color.fromARGB(
                                                          255, 26, 1, 1)),
                                                ),
                                                Container(
                                                  child: IconButton(
                                                    color: orangeColor,
                                                    icon: Icon(
                                                      CupertinoIcons
                                                          .xmark_circle_fill,
                                                      size: DM.p30,
                                                    ),
                                                    onPressed: () {
                                                      // createReqController.removeTestData(
                                                      //     createReqController
                                                      //         .testData[index].id,
                                                      //     index);
                                                      removeCalulationProcess(
                                                          testlist[index].id);
                                                      // createReqController
                                                      //     .calulationTestdata();
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  : Container(
                                      margin: EdgeInsets.all(DM.p10),
                                      height: DM.screenHeight * 0.33,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: whiteColor,
                                        borderRadius:
                                            BorderRadius.circular(DM.p10),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "${createReqController.emptyString}",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: DM.p15,
                                              color: Color.fromARGB(
                                                  255, 26, 1, 1)),
                                        ),
                                      ),
                                    ),
                            ),
                            Obx(
                              () => Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: DM.p20, vertical: DM.p2),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "(Test + Tube + Collection) = (${createReqController.totalTestCost.value}+${createReqController.tubeCost.value}+${createReqController.serviceCost.value} ) =  ${createReqController.totalTestCost.value + createReqController.tubeCost.value + createReqController.serviceCost.value} /-",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: DM.p12,
                                          color: Color.fromARGB(255, 26, 1, 1)),
                                    ),
                                    Text(
                                      "Discount : ${createReqController.totalDiscount.value} /-",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: DM.p12,
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
                                          "Total Cost: ${createReqController.totalCost.value} /-",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: DM.p15,
                                              color: Color.fromARGB(
                                                  255, 26, 1, 1)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.all(DM.p5),
                          child: Row(
                            children: [
                              Text(
                                "Location  ",
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: DM.p14,
                                    color: Color.fromARGB(255, 26, 1, 1)),
                              ),
                              SizedBox(
                                width: DM.p40,
                              ),
                              Text(":"),
                              SizedBox(
                                width: DM.p10,
                              ),
                              InkWell(
                                onTap: () {
                                  openMap(22.4977292, 91.8024407);
                                },
                                child: Text(
                                  "Click to see details",
                                  style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      decorationThickness: 2,
                                      fontWeight: FontWeight.w900,
                                      fontSize: DM.p14,
                                      color: Color.fromARGB(255, 12, 81, 177)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        FormUserInfo(
                          formKey: _formKey,
                          validatorField: validateString,
                          textInputType: TextInputType.number,
                          controller: servicecharge,
                          title: "Collection charge",
                          value: "20",
                          activate: false,
                        ),
                        FormUserInfo(
                          formKey: _formKey,
                          validatorField: validateString,
                          textInputType: TextInputType.name,
                          controller: lastupdate,
                          title: "Last update",
                          value: "50",
                          activate: false,
                        ),
                        FormUserInfo(
                          formKey: _formKey,
                          validatorField: validateString,
                          textInputType: TextInputType.number,
                          controller: softdelete,
                          title: "Soft delete",
                          value: "0",
                          activate: false,
                        ),
                        FormUserInfo(
                          formKey: _formKey,
                          validatorField: validateString,
                          textInputType: TextInputType.number,
                          controller: totalprice,
                          title: "Total price",
                          value: "70",
                          activate: false,
                        ),
                        FormUserInfo(
                          formKey: _formKey,
                          validatorField: validateString,
                          textInputType: TextInputType.name,
                          controller: teststatus,
                          title: "Test status",
                          value: "PENDING",
                          activate: true,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Images",
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: DM.p14,
                                    color: Color.fromARGB(255, 26, 1, 1)),
                              ),
                              SizedBox(
                                height: DM.p5,
                              ),
                              widget.testEachRequest!.type == 1
                                  ? Container(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: DM.p60,
                                            width: DM.p160,
                                            margin: EdgeInsets.symmetric(
                                              vertical: DM.p25,
                                            ),
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: DM.p20),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              DM.p10)),
                                                  primary: orangeColor),
                                              onPressed: () {},
                                              child: Text(
                                                "Image 1",
                                                style: TextStyle(
                                                    color: fullWhiteColor,
                                                    fontSize: DM.p15,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: DM.p10,
                                          ),
                                          Container(
                                            height: DM.p60,
                                            width: DM.p160,
                                            margin: EdgeInsets.symmetric(
                                              vertical: DM.p25,
                                            ),
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: DM.p20),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              DM.p10)),
                                                  primary: orangeColor),
                                              onPressed: () {},
                                              child: Text(
                                                "Image 2",
                                                style: TextStyle(
                                                    color: fullWhiteColor,
                                                    fontSize: DM.p15,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        image_one.text != "empty"
                                            ?   Column(
                                              children: [
                                                InkWell(
                                                    onTap: () => showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return MyDialogView(
                                                              myChild: MyPhotoView(
                                                                  image:
                                                                      image_one.text));
                                                        }),
                                                    child: Container(
                                                      height: DM.p200,
                                                      width: DM.p160,
                                                      child: Image.network(
                                                        image_one.text,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                  IconButton(
                                        color: orangeColor,
                                        icon: Icon(
                                          CupertinoIcons.xmark_circle_fill,
                                          size: DM.p30,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            image_one.text = "empty";
                                          });
                                        },
                                      ),
                                              ],
                                            )
                                            : Container(
                                                height: DM.p60,
                                                width: DM.p160,
                                                margin: EdgeInsets.symmetric(
                                                  vertical: DM.p25,
                                                ),
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: DM.p20),
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      DM.p10)),
                                                      primary: orangeColor),
                                                  onPressed: () {},
                                                  child: Text(
                                                    "Image 1",
                                                    style: TextStyle(
                                                        color: fullWhiteColor,
                                                        fontSize: DM.p15,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                        SizedBox(
                                          width: DM.p10,
                                        ),
                                        image_two.text != "empty"
                                            ? Column(
                                              children: [
                                                InkWell(
                                                    onTap: () => showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return MyDialogView(
                                                              myChild: MyPhotoView(
                                                                  image:
                                                                      image_two.text));
                                                        }),
                                                    child: Container(
                                                      height: DM.p200,
                                                      width: DM.p160,
                                                      child: Image.network(
                                                        image_two.text,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                  IconButton(
                                        color: orangeColor,
                                        icon: Icon(
                                          CupertinoIcons.xmark_circle_fill,
                                          size: DM.p30,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            image_two.text = "empty";
                                          });
                                        },
                                      ),
                                              ],
                                            )
                                            : Container(
                                                height: DM.p60,
                                                width: DM.p160,
                                                margin: EdgeInsets.symmetric(
                                                  vertical: DM.p25,
                                                ),
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: DM.p20),
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      DM.p10)),
                                                      primary: orangeColor),
                                                  onPressed: () {},
                                                  child: Text(
                                                    "Image 2",
                                                    style: TextStyle(
                                                        color: fullWhiteColor,
                                                        fontSize: DM.p15,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                      ],
                                    ),
                            ],
                          ),
                        )
                      ],
                    )),

                // #text_field

                // #signup_button

                Container(
                  margin:
                      EdgeInsets.symmetric(horizontal: DM.p20, vertical: DM.p1),
                  child: MaterialButton(
                    onPressed: () async {
                      if (_formKey.currentState?.validate() == true) {
                        if (await chechkingInternet()) {
                          //update
                        }
                      } else {
                        Get.snackbar(
                            duration: Duration(milliseconds: 2000),
                            icon: Icon(Icons.error),
                            margin: EdgeInsets.symmetric(
                                horizontal: DM.p70, vertical: DM.p60),
                            backgroundColor: Color.fromARGB(255, 202, 0, 0),
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
                      "Update",
                      style: TextStyle(
                          color: fullWhiteColor,
                          fontSize: DM.p15,
                          fontWeight: FontWeight.bold),
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
      padding: EdgeInsets.all(DM.p5),
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
                maxLines: null,
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
                      color: activate ? blackFontColor : Colors.grey,
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
