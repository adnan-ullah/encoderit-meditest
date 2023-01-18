import 'dart:convert';
import 'dart:ffi';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:healthcare_homelab/presentation/pages/Create_Request.dart';
import 'package:healthcare_homelab/presentation/pages/adminPanel/TestData.dart';
import 'package:healthcare_homelab/presentation/pages/adminPanel/TestListDialogueAdmin.dart';
import 'package:healthcare_homelab/presentation/widgets/projectsWidget/Notifications/GenerateNotification.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:get/get.dart';
import 'package:healthcare_homelab/animations/Custom_Dialog.dart';

import 'package:healthcare_homelab/presentation/widgets/projectsWidget/ConfirmationList.dart';
import 'package:healthcare_homelab/presentation/widgets/projectsWidget/Confirmation_TestItem.dart';
import 'package:healthcare_homelab/presentation/widgets/projectsWidget/TestListDialogueBox.dart';
import 'package:healthcare_homelab/presentation/widgets/projectsWidget/TextBoxDialogBox.dart';
import 'package:healthcare_homelab/presentation/widgets/minorWidgets/smallDialogBox.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:uuid/uuid.dart';

import '../../../constants/app_info.dart';
import '../../../constants/colors.dart';
import '../../../db/databse_model.dart';
import '../../../responsives/dimensions.dart';
import '../../../state_programming/Create_Request_Controller.dart';
import '../../../state_programming/getController.dart';
import '../../widgets/minorWidgets/PhotoViewImage.dart';
import '../../widgets/projectsWidget/Notifications/NotificationServices.dart';
import '../Invoice_pdf/api/pdf_api.dart';
import '../Invoice_pdf/api/pdf_invoice_api.dart';
import '../Invoice_pdf/api/pdf_invoice_no_customer.dart';
import '../Invoice_pdf/model/customer.dart';
import '../Invoice_pdf/model/invoice.dart';
import '../Login_info.dart';

class TestRequestCreate extends StatefulWidget {
  TestDataRequest? testEachRequest;
  TestRequestCreate({Key? key, this.testEachRequest}) : super(key: key);

  @override
  _TestRequestCreateState createState() => _TestRequestCreateState();
}

class _TestRequestCreateState extends State<TestRequestCreate> {
  bool isTestlistOpen = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  dynamic latitude;
  dynamic longitude;
  var dateTime_delivery;
  var updateTestRequestItem;
  var name = new TextEditingController();
  String gender = "Male";
  var phone = new TextEditingController();
  var age = new TextEditingController();
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

  var comments = new TextEditingController();
  var delivery_date = new TextEditingController();

  var advanced = new TextEditingController();
  var due_amount = new TextEditingController();
  var admin_discount = new TextEditingController();

  var agent_discount = new TextEditingController();
  var total_discount = new TextEditingController();
  var commission = new TextEditingController();

  List<TestData> testItemList = [];
  List<AdminUserModel> adminUserList = [];
  List<TestData> testData_updated = [];

  final Map<String, bool> testItemListWithSelected = {};

  var totalTestCost = 0;

  var totalCost = 0;
  var serviceCost = 0;
  var tubeCost = 0;
  var totalDiscount = 0;
  var test_item_cost = 0;
  var test_item_discount = 0;

  var newRequestData;

  bool init = false;
  Future<void> _getTestItemList() async {
    late DatabaseReference DbrefTestModel;
    DbrefTestModel = FirebaseDatabase.instance.ref("$database_name/testModel/");

    DbrefTestModel.onValue.listen((event) {
      testItemList.clear();
      // testItemListWithSelected.clear();

      for (DataSnapshot ds in event.snapshot.children) {
        TestData testData =
            TestData.fromJson(json.decode(jsonEncode(ds.value)));

        testItemList.add(testData);
        if (testItemListWithSelected[testData.id] != true)
          testItemListWithSelected[testData.id] = false;

        print("HEREEEE");

        //false -> add button
        //true -> remove button

      }
    });
  }

  Future<void> getAdminUserList() async {
    late DatabaseReference DbrefTestModel;
    DbrefTestModel = FirebaseDatabase.instance.ref("$database_name/admin_user/");
    FirebaseDatabase.instance.setPersistenceEnabled(true);
    DbrefTestModel.keepSynced(true);

    DbrefTestModel.onValue.listen((event) {
      for (DataSnapshot ds in event.snapshot.children) {
        AdminUserModel testData =
            AdminUserModel.fromJson(json.decode(jsonEncode(ds.value)));

        adminUserList.add(testData);
      }
    });
  }

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
    type.text =
        createReqController.typeName[widget.testEachRequest!.type].toString();
    invoice_call.text = widget.testEachRequest!.invoice_call.toString();
    name.text = widget.testEachRequest!.name.toString();
    age.text = widget.testEachRequest!.age.toString();
    phone.text = widget.testEachRequest!.mobile.toString();
    address.text = widget.testEachRequest!.address.toString();
    referrer.text = widget.testEachRequest!.referrer.toString();
    servicecharge.text = widget.testEachRequest!.servicecharge.toString();
    totalprice.text = widget.testEachRequest!.totalprice.toString();
    teststatus.text = widget.testEachRequest!.teststatus.toString();

    if (widget.testEachRequest!.delivery_date != null) {
      dateTime_delivery = widget.testEachRequest!.delivery_date;
      delivery_date.text = (DateFormat.yMMMd().format(
          DateTime.fromMillisecondsSinceEpoch(
              widget.testEachRequest!.delivery_date)));
    } else {
      dateTime_delivery = currentTime + 86400000;

      delivery_date.text = (DateFormat.yMMMd()
          .format(DateTime.fromMillisecondsSinceEpoch(currentTime + 86400000)));
    }

   
    if (teststatus.text.contains("2")) {
      dateTime_delivery = DateTime(DateTime.now().year, DateTime.now().month,
              DateTime.now().day + 1, 20, 0, 0)
          .millisecondsSinceEpoch;

      delivery_date.text = (DateFormat.yMMMd()
          .format(DateTime.fromMillisecondsSinceEpoch(dateTime_delivery)));
    }

    

    if (widget.testEachRequest!.comments != null)
      comments.text = widget.testEachRequest!.comments;
    else
      comments.text = "";

    if (widget.testEachRequest!.advanced != null)
      advanced.text = widget.testEachRequest!.advanced;
    else
      advanced.text = "0";

    if (widget.testEachRequest!.admin_discount != null)
      admin_discount.text = widget.testEachRequest!.admin_discount.toString();
    else
      admin_discount.text = "0";

    if (widget.testEachRequest!.agent_discount != null)
      agent_discount.text = widget.testEachRequest!.agent_discount.toString();
    else
      agent_discount.text = "0";

    if (widget.testEachRequest!.total_discount != null)
      total_discount.text = widget.testEachRequest!.total_discount.toString();
    else
      total_discount.text = "0";

    if (widget.testEachRequest!.due_amount != null)
      due_amount.text = widget.testEachRequest!.due_amount.toString();
    else
      due_amount.text = totalprice.text.toString();

    if (widget.testEachRequest!.testlist != null) {
      widget.testEachRequest!.testlist!.map((e) {
        testData_updated.add(e);
        testItemListWithSelected[e.id] = true;
      }).toList();
    }

    if (widget.testEachRequest!.image_one == null)
      image_one.text = "empty";
    else
      image_one.text = widget.testEachRequest!.image_one.toString();

    if (widget.testEachRequest!.image_two == null)
      image_two.text = "empty";
    else
      image_two.text = widget.testEachRequest!.image_two.toString();

    setState(() {
      gender = widget.testEachRequest!.gender;
    });
    softdelete.text = widget.testEachRequest!.softdelete.toString();

    lastupdate.text = currentTime.toString();
    dateofcreated.text = (DateFormat('EEE, dd MMM, yyy').format(
            DateTime.fromMillisecondsSinceEpoch(
                widget.testEachRequest!.dateofcreated)))
        .toString();

    setState(() {
      latitude = widget.testEachRequest!.latitude.toString();
      longitude = widget.testEachRequest!.longitude.toString();
    });

    if (widget.testEachRequest!.test_item_cost != null)
      test_item_cost = widget.testEachRequest!.test_item_cost;
    else
      test_item_cost = 0;

    if (widget.testEachRequest!.test_item_discount != null)
      test_item_discount = widget.testEachRequest!.test_item_discount;
    else
      test_item_discount = 0;

    commission.text = "0";

//for agent commission
    late DatabaseReference _DbrefTestModel;
    _DbrefTestModel = FirebaseDatabase.instance.ref("$database_name/admin_user/");
    FirebaseDatabase.instance.setPersistenceEnabled(true);
    _DbrefTestModel.keepSynced(true);
    _DbrefTestModel.onValue.listen((event) async {
      for (DataSnapshot ds in event.snapshot.children) {
        AdminUserModel testData =
            AdminUserModel.fromJson(json.decode(jsonEncode(ds.value)));

        if (testData.referrer_code.contains(referrer.text.toString())) {
          commission.text = (((widget.testEachRequest!.test_item_cost -
                          widget.testEachRequest!.test_item_discount) *
                      int.parse(testData.commission)) /
                  100)
              .toInt()
              .toString();
        }
      }
    });
  }

  Future<void> _updateRequest() async {
    int currentTime = DateTime.now().millisecondsSinceEpoch;

    late DatabaseReference DbrefTestReqModel;
    DbrefTestReqModel = FirebaseDatabase.instance.ref("$database_name/");

    if (admin_discount.text == null || admin_discount.text.isEmpty) {
      admin_discount.text = "0";
    }
    if (agent_discount.text == null || agent_discount.text.isEmpty) {
      agent_discount.text = "0";
    }

    updateTestRequestItem = TestDataRequest(
        id: widget.testEachRequest!.id.toString(),
        name: name.text.toString(),
        gender: gender.toString(),
        mobile: phone.text.toString(),
        age: int.parse(age.text),
        testlist: testData_updated,
        totalprice: totalCost,
        servicecharge: serviceCost,
        address: address.text.toString(),
        referrer: referrer.text.toString(),
        lastupdate: currentTime,
        dateofcreated: widget.testEachRequest!.dateofcreated,
        softdelete: 0,
        latitude: widget.testEachRequest!.latitude,
        longitude: widget.testEachRequest!.longitude,
        teststatus: int.parse(teststatus.text),
        invoice_call: invoice_call.text.toString(),
        type: createReqController.toType[type.text.toString()],
        image_one: image_one.text.toString() == "empty"
            ? null
            : image_one.text.toString(),
        image_two: image_two.text.toString() == "empty"
            ? null
            : image_two.text.toString(),
        delivery_date: dateTime_delivery,
        comments: comments.text.toString(),
        advanced: advanced.text.toString(),
        due_amount: due_amount.text.toString(),
        admin_discount: int.parse(admin_discount.text.toString()),
        agent_discount: int.parse(agent_discount.text.toString()),
        test_item_cost: test_item_cost,
        test_item_discount: test_item_discount,
        total_discount: totalDiscount);

    if (updateTestRequestItem != null) {
      await DbrefTestReqModel.child("testRequest")
          .child(updateTestRequestItem.mobile)
          .child(updateTestRequestItem.id)
          .update(jsonDecode(jsonEncode(updateTestRequestItem.toJson())));
    }

    Get.back();
  }

  void calculationProcess() {
    totalTestCost = 0;
    totalCost = 0;
    serviceCost = 0;
    tubeCost = 0;
    totalDiscount = 0;
    test_item_discount = 0;

    if (admin_discount.text == null || admin_discount.text.isEmpty) {
      admin_discount.text = "0";
    }
    totalDiscount = totalDiscount + int.parse(admin_discount.text.toString());

    if (agent_discount.text == null || agent_discount.text.isEmpty) {
      agent_discount.text = "0";
    }

    totalDiscount = totalDiscount + int.parse(agent_discount.text.toString());

    testData_updated.map((testItem) {
      totalTestCost = totalTestCost + int.parse(testItem.testprice.toString());

      serviceCost =
          max(serviceCost, int.parse(testItem.servicecharge.toString()));

      test_item_discount =
          test_item_discount + int.parse(testItem.discount.toString());
      tubeCost = tubeCost + int.parse(testItem.testkitprice.toString());
      totalDiscount = totalDiscount + int.parse(testItem.discount.toString());
    }).toList();

    totalCost = totalTestCost + serviceCost + tubeCost - totalDiscount;
    //totalCost = totalTestCost  + serviceCost - totalDiscount;

    totalprice.text = totalCost.toString();
    servicecharge.text = serviceCost.toString();
    test_item_cost = totalTestCost;

    if (advanced.text != null && advanced.text.isNotEmpty) {
      due_amount.text =
          (totalCost - int.parse(advanced.text.toString())).toString();
    }
    if (testData_updated.length == 0) {
      totalDiscount = 0;
      agent_discount.text = "0";
      admin_discount.text = "0";
    }

    total_discount.text = totalDiscount.toString();

    adminUserList.map((e) {
      if (e.referrer_code.contains(referrer.text.toString())) {
        commission.text =
            (((test_item_cost - test_item_discount) * int.parse(e.commission)) /
                    100)
                .toInt()
                .toString();

        return;
      }
    }).toList();
  }

  Future<void> removeCalulationProcess(id) async {
    setState(() {
      testData_updated.removeWhere((element) => element.id == id);
      testItemListWithSelected[id] = false;

      totalTestCost = 0;
      totalCost = 0;
      serviceCost = 0;
      tubeCost = 0;
      totalDiscount = 0;
      test_item_discount = 0;

      testData_updated.map((testItem) {
        totalTestCost =
            totalTestCost + int.parse(testItem.testprice.toString());

        serviceCost =
            max(serviceCost, int.parse(testItem.servicecharge.toString()));

        tubeCost = tubeCost + int.parse(testItem.testkitprice.toString());
        totalDiscount = totalDiscount + int.parse(testItem.discount.toString());
        test_item_discount =
            test_item_discount + int.parse(testItem.discount.toString());
      }).toList();

      totalCost = totalTestCost + serviceCost + tubeCost - totalDiscount;
      // totalCost = totalTestCost  + tubeCost ;
      //totalCost = totalTestCost  + serviceCost - totalDiscount;

      totalprice.text = totalCost.toString();
      //totaltestprice.text = totalTestCost.toString();
      servicecharge.text = serviceCost.toString();
      test_item_cost = totalTestCost;
      due_amount.text =
          (totalCost - int.parse(advanced.text.toString())).toString();

      if (testData_updated.length == 0) {
        totalDiscount = 0;
        agent_discount.text = "0";
        admin_discount.text = "0";
      }

      total_discount.text = totalDiscount.toString();

      adminUserList.map((e) {
        if (e.referrer_code.contains(referrer.text.toString())) {
          commission.text = (((test_item_cost - test_item_discount) *
                      int.parse(e.commission)) /
                  100)
              .toInt()
              .toString();

          return;
        }
      }).toList();
    });
  }

  Future<void> permissionNeed() async {
    // final status = await Permission.request();

    // var state = await Permission.manageExternalStorage.request();
    //var state2 = await Permission.storage.status;

    if (await Permission.storage.request() == true) {}
  }

  @override
  void initState() {
    permissionNeed();
    getAdminUserList();
    if (widget.testEachRequest != null) {
      this.retreiveEachDataRequest();

      _getTestItemList();
    }
    init = true;
    // TODO: implement initState
    super.initState();
  }

  CreateRequest_controller createReqController =
      Get.put(CreateRequest_controller());

  @override
  Widget build(BuildContext context) {
    chechkingInternet();

    if (init == false) {
      testData_updated.clear();

      testItemList.map((e) {
        if (testItemListWithSelected[e.id] == true) {
          testData_updated.add(e);
          testItemListWithSelected[e.id] = true;
        }
      }).toList();
    }
    init = false;
    calculationProcess();

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                        horizontal: DM.p10, vertical: DM.p10),
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
                          value: "Write your name",
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
                                hint: Text("$gender",
                                    style: TextStyle(color: blackFontColor)),
                                items: <String>[
                                  'Male',
                                  'Female',
                                ].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      "$value",
                                      style: TextStyle(color: Colors.black),
                                    ),
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
                          value: "0",
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
                                  child: TextFormField(
                                    controller: address,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null,
                                    // onTap: (() {
                                    //   showDialog(
                                    //       context: context,
                                    //       builder: (context) {
                                    //         return MyDialogView(
                                    //             myChild: TextDialogueBox(
                                    //                 keyTitle: "Address",
                                    //                 addressText: address));
                                    //       });
                                    // }),
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
                                        hintText: "Your Address",
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
                                  child: TextFormField(
                                    controller: referrer,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null,
                                    onEditingComplete: () {
                                      calculationProcess();
                                    },
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
                                        hintText: "0",
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
                          textInputType: TextInputType.name,
                          controller: dateofcreated,
                          title: "Date of created",
                          value: "15 Dec 2014",
                          activate: true,
                        ),

                        Padding(
                          padding: EdgeInsets.all(DM.p5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: DM.p100,
                                    child: Text(
                                      "Images",
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
                                ],
                              ),
                              SizedBox(
                                height: DM.p10,
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
                                            ? Column(
                                                children: [
                                                  InkWell(
                                                    onTap: () => showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return MyDialogView(
                                                              myChild: MyPhotoView(
                                                                  image: image_one
                                                                      .text));
                                                        }),
                                                    child: Container(
                                                      height: DM.p170,
                                                      width: DM.p130,
                                                      child: Image.network(
                                                        image_one.text,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
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
                                                                  image: image_two
                                                                      .text));
                                                        }),
                                                    child: Container(
                                                      height: DM.p170,
                                                      width: DM.p130,
                                                      child: Image.network(
                                                        image_two.text,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
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
                                          showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return MyDialogView(
                                                        myChild:
                                                            TestListDialogueAdmin(
                                                      testItemList:
                                                          testItemList,
                                                      testItemWithSelected:
                                                          testItemListWithSelected,
                                                    ));
                                                  })
                                              .then((value) => setState(() {}));
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
                                  horizontal: DM.p5, vertical: DM.p3),
                              height: DM.screenHeight * 0.35,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: whiteColor,
                                borderRadius: BorderRadius.circular(DM.p10),
                              ),
                              child: testData_updated.length != 0
                                  ? ListView.builder(
                                      itemCount: testData_updated.length,
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
                                                    testData_updated[index]
                                                            .name +
                                                        " (" +
                                                        testData_updated[index]
                                                            .diagnostic_center
                                                            .toString() +
                                                        ")",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        fontSize: DM.p15,
                                                        color: Color.fromARGB(
                                                            255, 26, 1, 1)),
                                                  ),
                                                ),
                                                Text(
                                                  "Price: ${testData_updated[index].testprice}",
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
                                                      setState(() {
                                                        removeCalulationProcess(
                                                            testData_updated[
                                                                    index]
                                                                .id);
                                                      });

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
                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: DM.p20, vertical: DM.p2),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "(Test + Tube + Collection) = (${totalTestCost}+${tubeCost}+${serviceCost} ) =  ${totalTestCost + tubeCost + serviceCost} /-",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: DM.p12,
                                        color: Color.fromARGB(255, 26, 1, 1)),
                                  ),
                                  Text(
                                    "Discount : ${totalDiscount} /-",
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
                                        "Total Cost: ${totalCost} /-",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: DM.p15,
                                            color:
                                                Color.fromARGB(255, 26, 1, 1)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
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
                                  openMap(double.parse(latitude),
                                      double.parse(longitude));
                                },
                                child: Text(
                                  "Click to see details",
                                  style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      decorationThickness: DM.p2,
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
                        // FormUserInfo(
                        //   formKey: _formKey,
                        //   validatorField: validateString,
                        //   textInputType: TextInputType.name,
                        //   controller: lastupdate,
                        //   title: "Last update",
                        //   value: "50",
                        //   activate: false,
                        // ),

                        FormUserInfo(
                          formKey: _formKey,
                          validatorField: validateString,
                          textInputType: TextInputType.number,
                          controller: totalprice,
                          title: "Total price",
                          value: "0",
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
                                  "Admin Discount",
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
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      if (value.length != 0) {
                                        setState(() {
                                          calculationProcess();
                                        });
                                      }
                                    },
                                    controller: admin_discount,
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
                                        fillColor: fullWhiteColor,
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: DM.p10),
                                        border: InputBorder.none,
                                        hintText: "0",
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
                                  "Agent Discount",
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
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      if (value.length != 0) {
                                        setState(() {
                                          calculationProcess();
                                        });
                                      }
                                    },
                                    controller: agent_discount,
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
                                        fillColor: fullWhiteColor,
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: DM.p10),
                                        border: InputBorder.none,
                                        hintText: "0",
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
                          textInputType: TextInputType.number,
                          controller: commission,
                          title: "Agent Commission",
                          value: "0",
                          activate: true,
                        ),
                        Padding(
                          padding: EdgeInsets.all(DM.p5),
                          child: Row(
                            children: [
                              SizedBox(
                                width: DM.p100,
                                child: Text(
                                  "Next Status",
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
                                hint: Text(
                                    "${createReqController.status[int.parse(teststatus.text)]}",
                                    style: TextStyle(color: blackFontColor)),
                                items: <String>[
                                  "PENDING",
                                  "RECIEVED",
                                  "COLLECTED",
                                  "READY",
                                  "DELIVERED",
                                  "CANCEL"
                                ].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      "$value",
                                      style: TextStyle(color: blackFontColor),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    teststatus.text = createReqController
                                        .toStatus[newValue]
                                        .toString();
                                  });
                                },
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
                                  "Delivery Date",
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
                                  child: InkWell(
                                    onTap: () async {
                                      print("ADNANN");
                                      final DateTime? picked =
                                          await showDatePicker(
                                              context: context,
                                              initialDate: DateTime
                                                  .fromMillisecondsSinceEpoch(
                                                      dateTime_delivery),
                                              initialDatePickerMode:
                                                  DatePickerMode.day,
                                              firstDate:
                                                  DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                          1669831200000),
                                              lastDate: DateTime
                                                  .fromMillisecondsSinceEpoch(
                                                      1922292000000));
                                      if (picked != null)
                                        setState(() {
                                          delivery_date.text =
                                              DateFormat.yMMMd().format(picked);
                                          print(picked.millisecondsSinceEpoch);

                                          dateTime_delivery =
                                              picked.millisecondsSinceEpoch;
                                        });
                                    },
                                    child: IgnorePointer(
                                      child: TextFormField(
                                        controller: delivery_date,
                                        decoration: InputDecoration(
                                            errorStyle:
                                                TextStyle(fontSize: DM.p9),
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
                                ),
                              ),
                            ],
                          ),
                        ),

                        FormUserInfo(
                          formKey: _formKey,
                          textInputType: TextInputType.name,
                          controller: comments,
                          title: "Comments",
                          value: "Write your comments",
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
                                  "Advanced",
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
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      if (advanced.text != null &&
                                          advanced.text.isNotEmpty) {
                                        due_amount.text = (totalCost -
                                                int.parse(
                                                    advanced.text.toString()))
                                            .toString();
                                      }
                                    },
                                    controller: advanced,
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
                                        fillColor: fullWhiteColor,
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: DM.p10),
                                        border: InputBorder.none,
                                        hintText: "0",
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
                          textInputType: TextInputType.name,
                          controller: due_amount,
                          title: "Due Amount",
                          value: "${totalCost - int.parse(advanced.text)}",
                          activate: false,
                        ),

                        FormUserInfo(
                          formKey: _formKey,
                          textInputType: TextInputType.number,
                          controller: total_discount,
                          title: "Total Discount",
                          value: "0",
                          activate: false,
                        ),

                        FormUserInfo(
                          formKey: _formKey,
                          textInputType: TextInputType.number,
                          controller: softdelete,
                          title: "Soft delete",
                          value: "0",
                          activate: false,
                        ),
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
                          if (widget.testEachRequest!.teststatus == 2) {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return MyDialogView(
                                    myChild: Padding(
                                      padding: EdgeInsets.all(DM.p8),
                                      child: Stack(
                                        children: [
                                          Container(
                                              color: creamColor,
                                              height: DM.screenHeight * 0.8,
                                              width: DM.screenWidth * 0.9,
                                              padding: EdgeInsets.all(DM.p15),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Confirmation",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        fontSize: DM.p25,
                                                        color: Color.fromARGB(
                                                            255, 26, 1, 1)),
                                                  ),
                                                  Text(
                                                    "Name: ${name.text}",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: DM.p15,
                                                        color: Color.fromARGB(
                                                            255, 26, 1, 1)),
                                                  ),
                                                  Text(
                                                    "Phone: ${phone.text}",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: DM.p15,
                                                        color: Color.fromARGB(
                                                            255, 26, 1, 1)),
                                                  ),
                                                  Text(
                                                    "Address: ${address.text}",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: DM.p15,
                                                        color: Color.fromARGB(
                                                            255, 26, 1, 1)),
                                                  ),
                                                  Text(
                                                    "Referrer: ${referrer.text}",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: DM.p15,
                                                        color: Color.fromARGB(
                                                            255, 26, 1, 1)),
                                                  ),
                                                  Text(
                                                    "Delivery Date: ${delivery_date.text} 8:00 PM",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: DM.p15,
                                                        color: Color.fromARGB(
                                                            255, 26, 1, 1)),
                                                  ),
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        "Test List",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: DM.p20,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    26,
                                                                    1,
                                                                    1)),
                                                      ),
                                                      Divider(
                                                        thickness: DM.p1,
                                                        color: blackFontColor,
                                                        indent: DM.screenWidth *
                                                            0.2,
                                                        endIndent:
                                                            DM.screenWidth *
                                                                0.2,
                                                      ),
                                                      Card(
                                                          child: Container(
                                                        height:
                                                            DM.screenHeight *
                                                                0.30,
                                                        child: ListView.builder(
                                                          itemCount:
                                                              testData_updated
                                                                  .length,
                                                          itemBuilder:
                                                              (context, index) {
                                                            return Container(
                                                              color: whiteColor,
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal: DM
                                                                          .p10,
                                                                      vertical:
                                                                          DM.p5),
                                                              margin: EdgeInsets
                                                                  .symmetric(
                                                                      vertical:
                                                                          DM.p10),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Expanded(
                                                                    child:
                                                                        SizedBox(
                                                                      width: DM
                                                                          .p130,
                                                                      child:
                                                                          Text(
                                                                        testData_updated[index].name +
                                                                            " (${testData_updated[index].diagnostic_center})",
                                                                        style: TextStyle(
                                                                            fontWeight: FontWeight
                                                                                .w900,
                                                                            fontSize: DM
                                                                                .p12,
                                                                            color: Color.fromARGB(
                                                                                255,
                                                                                26,
                                                                                1,
                                                                                1)),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    "Price: " +
                                                                        (testData_updated[index].testprice)
                                                                            .toString(),
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w900,
                                                                        fontSize: DM
                                                                            .p12,
                                                                        color: Color.fromARGB(
                                                                            255,
                                                                            26,
                                                                            1,
                                                                            1)),
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
                                                    "(Test + Tube + Collection) = (${totalTestCost}+${tubeCost}+${serviceCost} ) =  ${totalTestCost + tubeCost + serviceCost} /-",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        fontSize: DM.p12,
                                                        color: Color.fromARGB(
                                                            255, 26, 1, 1)),
                                                  ),
                                                  Text(
                                                    "Discount : ${totalDiscount} /-",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        fontSize: DM.p13,
                                                        color: Color.fromARGB(
                                                            255, 26, 1, 1)),
                                                  ),
                                                  Divider(
                                                    thickness: DM.p1,
                                                    color: blackFontColor,
                                                    endIndent: DM.p100,
                                                  ),
                                                  Text(
                                                    "Total Cost: ${totalCost} /-",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        fontSize: DM.p18,
                                                        color: Color.fromARGB(
                                                            255, 26, 1, 1)),
                                                  ),
                                                  Text(
                                                    "Advanced: ${advanced.text} /-",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: DM.p14,
                                                        color: Color.fromARGB(
                                                            255, 26, 1, 1)),
                                                  ),
                                                  Text(
                                                    "Due Amount: ${due_amount.text} /-",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: DM.p14,
                                                        color: Color.fromARGB(
                                                            255, 26, 1, 1)),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      MaterialButton(
                                                        onPressed: () {
                                                          Get.back();
                                                        },
                                                        height: DM.p45,
                                                        minWidth: DM.p120,
                                                        shape:
                                                            const StadiumBorder(),
                                                        color: redColor,
                                                        child: Text(
                                                          "Cancel",
                                                          style: TextStyle(
                                                              color:
                                                                  fullWhiteColor,
                                                              fontSize: DM.p15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                      MaterialButton(
                                                        onPressed: () async {
                                                          if (await chechkingInternet()) {
                                                            _updateRequest();

                                                            InvoicePrint(
                                                                updateTestRequestItem,
                                                                totalDiscount,
                                                                due_amount,
                                                                advanced,
                                                                tubeCost);

                                                            Get.back();
                                                          }
                                                        },
                                                        height: DM.p45,
                                                        minWidth: DM.p120,
                                                        shape:
                                                            const StadiumBorder(),
                                                        color: orangeColor,
                                                        child: Text(
                                                          "Confirm",
                                                          style: TextStyle(
                                                              color:
                                                                  fullWhiteColor,
                                                              fontSize: DM.p15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
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
                                                icon:
                                                    Icon(CupertinoIcons.xmark),
                                                onPressed: () {
                                                  Get.back();
                                                },
                                              ))
                                        ],
                                      ),
                                    ),
                                  );
                                });
                          } else {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return Scaffold(
                                    backgroundColor: Colors.transparent,
                                    body: Center(
                                      child: Container(
                                          margin: EdgeInsets.all(DM.p10),
                                          height: DM.p200,
                                          color: creamColor,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(16),
                                                margin: EdgeInsets.all(16),
                                                child: Text(
                                                  "Are you want to submit to ${createReqController.status[int.parse(teststatus.text)]}?",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: DM.p20,
                                                      color: Color.fromARGB(
                                                          255, 26, 1, 1)),
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            horizontal: DM.p20,
                                                            vertical: DM.p10),
                                                    child: MaterialButton(
                                                      onPressed: () {
                                                        Get.back();
                                                      },
                                                      height: DM.p40,
                                                      minWidth: DM.p120,
                                                      shape:
                                                          const StadiumBorder(),
                                                      color: orangeColor,
                                                      child: Text(
                                                        "Cancel",
                                                        style: TextStyle(
                                                            color:
                                                                fullWhiteColor,
                                                            fontSize: DM.p15,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            horizontal: DM.p20,
                                                            vertical: DM.p10),
                                                    child: MaterialButton(
                                                      onPressed: () async {
                                                        if (_formKey
                                                                .currentState
                                                                ?.validate() ==
                                                            true) {
                                                          if (await chechkingInternet()) {
                                                            print("ADNANAAAA");
                                                            _updateRequest();

                                                            //cr_controller.filter_testItemList.removeAt(index);
                                                            Get.back();
                                                          }
                                                        }
                                                      },
                                                      height: DM.p40,
                                                      minWidth: DM.p120,
                                                      shape:
                                                          const StadiumBorder(),
                                                      color: orangeColor,
                                                      child: Text(
                                                        "Yes",
                                                        style: TextStyle(
                                                            color:
                                                                fullWhiteColor,
                                                            fontSize: DM.p15,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ],
                                          )),
                                    ),
                                  );
                                });
                          }
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
                      "Confirm",
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
  FormUserInfo({
    Key? key,
    required this.formKey,
    required this.title,
    required this.value,
    required this.activate,
    required this.controller,
    required this.textInputType,
    this.validatorField,
  }) : super(
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
              child: TextFormField(
                validator: validatorField,
                onChanged: ((value) {
                  if (!formKey.currentState?.validate())
                    formKey.currentState?.validate();
                }),
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
  if (value?.length != 11 && value?.length != 12)
    return 'Mobile Number must be of 11 and 12 digits';
  else
    return null;
}

String? validateString(String? value) {
  if (value?.length == 0)
    return 'Please fill this form';
  else
    return null;
}

Future<void> InvoicePrint(TestDataRequest testDataRequest, totalDiscount,
    due_amount, advanced, tubeCost) async {
  final date = DateTime.now().millisecondsSinceEpoch;

  final invoice = Invoice(
    // supplier: Supplier(
    //   name: 'Sarah Field',
    //   address: 'Sarah Street 9, Beijing, China',
    //   paymentInfo: 'https://paypal.me/sarahfieldzz',
    // ),
    customer: Customer(
        id: testDataRequest.id,
        invoice_id: testDataRequest.invoice_call,
        name: testDataRequest.name,
        address: testDataRequest.address,
        gender: testDataRequest.gender,
        referrer: testDataRequest.referrer,
        age: testDataRequest.age,
        date: date,
        totalAmount: testDataRequest.totalprice,
        advance: advanced.text.toString(),
        dueAmount: due_amount.text.toString(),
        totalDiscount: totalDiscount,
        testItems: testDataRequest.testlist,
        collection_charge: testDataRequest.servicecharge,
        tube_cost: tubeCost,
        deliveryDate: testDataRequest.delivery_date),

    info: InvoiceInfo(
      date: DateTime.now(),
      description: 'My description...',
      number: '${DateTime.now().year}-9999',
    ),

    items: List.generate(
        testDataRequest.testlist!.length,
        (index) => InvoiceItem(
            testName: testDataRequest.testlist![index].name +
                " (${testDataRequest.testlist![index].diagnostic_center})",
            testPrice: testDataRequest.testlist![index].testprice,
            serialNumber: index + 1))

    // InvoiceItem(
    //   testName: 'Coffee',
    //   quantity: 3,
    //   testPrice: 5.999999,
    // ),
    // InvoiceItem(
    //   testName: 'Water',
    //   quantity: 8,
    //   testPrice: 0.99,
    // ),
    // InvoiceItem(
    //   testName: 'Orange',
    //   quantity: 3,
    //   testPrice: 2.99,
    // ),
    // InvoiceItem(
    //   testName: 'Apple',
    //   quantity: 8,
    //   testPrice: 3.99,
    // ),
    // InvoiceItem(
    //   testName: 'Mango',
    //   quantity: 1,
    //   testPrice: 1.59,
    // ),
    ,
  );

  final pdfFile = await PdfInvoiceApi.generate(invoice);
  final pdfFile2 = await PdfInvoiceApiNoCustomer.generate(invoice);

  PdfApi.openFile(pdfFile);
  PdfApi.openFile(pdfFile2);
}
