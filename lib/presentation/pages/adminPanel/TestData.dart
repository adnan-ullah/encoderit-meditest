import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthcare_homelab/constants/app_info.dart';
import 'package:healthcare_homelab/presentation/pages/Create_Request.dart';
import 'package:uuid/uuid.dart';

import '../../../constants/colors.dart';
import '../../../db/databse_model.dart';
import '../../../db/models/TestData.dart';
import '../../../responsives/dimensions.dart';
import '../../../state_programming/Create_Request_Controller.dart';
import '../Login_info.dart';

class TestDataCreate extends StatefulWidget {
  // static const String id = "sign_up_page";
  TestData? testItem;
  TestDataCreate({Key? key, this.testItem}) : super(key: key);

  @override
  _TestDataCreateState createState() => _TestDataCreateState();
}

class _TestDataCreateState extends State<TestDataCreate> {
  var updatedTestItemData;
  var inserNewTestItem;
  var category = "PATHOLOGY";

  Future<void> updateTestItem() async {
    name.text = widget.testItem!.name;
    servicecharge.text = widget.testItem!.servicecharge.toString();
    softdelete.text = widget.testItem!.softdelete.toString();
    diagnostic_center.text = widget.testItem!.diagnostic_center.toString();
    discount.text = widget.testItem!.discount.toString();
    niddle_cost.text = widget.testItem!.niddle_cost.toString();
    testkitprice.text = widget.testItem!.testkitprice.toString();
    testprice.text = widget.testItem!.testprice.toString();
    transport_cost.text = widget.testItem!.transport_cost.toString();
    b2b_cost.text = widget.testItem!.b2b_cost.toString();

    is_payable = widget.testItem!.is_payable;

    if (is_payable == null) {
      is_payable = true;
    }

    category = createReqController.categoryName[widget.testItem!.category]!;
  }

  Future<void> updateToFirebase() async {
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    late DatabaseReference dbrefTestReqModel;
    dbrefTestReqModel = FirebaseDatabase.instance.ref("$database_name");

    updatedTestItemData = TestData(
        id: widget.testItem!.id.toString(),
        name: name.text.toString(),
        servicecharge: servicecharge.text.toString(),
        lastupdate: currentTime.toString(),
        softdelete: softdelete.text.toString(),
        diagnostic_center: diagnostic_center.text.toString(),
        discount: discount.text.toString(),
        niddle_cost: niddle_cost.text.toString(),
        testkitprice: testkitprice.text.toString(),
        testprice: testprice.text.toString(),
        transport_cost: transport_cost.text.toString(),
        b2b_cost: b2b_cost.text,
        is_payable: is_payable,
        category: createReqController.toCategory[category]!);

    if (updatedTestItemData != null) {
      await dbrefTestReqModel
          .child("testModel")
          .child(updatedTestItemData.id)
          .update(jsonDecode(jsonEncode(updatedTestItemData)));
    }
  }

  Future<void> insertNewTestItemMethod() async {
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    DatabaseReference _dbref_testReqModel;
    _dbref_testReqModel = FirebaseDatabase.instance.ref("$database_name");

    inserNewTestItem = TestData(
        id: Uuid().v4(),
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
        b2b_cost: b2b_cost.text,
        is_payable: is_payable,
        category: createReqController.toCategory[category]);
    if (inserNewTestItem != null) {
      await _dbref_testReqModel
          .child("testModel")
          .child(inserNewTestItem.id)
          .set(inserNewTestItem.toJson());
    }
  }

  @override
  void initState() {
    if (widget.testItem != null) {
      print("From Update Class");
      updateTestItem();
    } else {
      print("From New Item Class");
    }

    // TODO: implement initState
    super.initState();
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? latitude;
  String? longitude;

  var name = new TextEditingController();
  var diagnostic_center = new TextEditingController();
  var testkitprice = TextEditingController(text: "0");
  var softdelete = TextEditingController(text: "0");
  var transport_cost = TextEditingController(text: "0");
  var niddle_cost = new TextEditingController(text: "0");
  var servicecharge = TextEditingController(text: "0");
  var discount = TextEditingController(text: "0");
  var testprice = TextEditingController(text: "0");
  var b2b_cost = TextEditingController(text: "0");

  var is_payable = true;
  //form variables:

  var newTestListData;

  CreateRequest_controller createReqController =
      Get.put(CreateRequest_controller());

  @override
  Widget build(BuildContext context) {
    chechkingInternet();
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(backgroundColor: appTheme, actions: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: DM.p50, vertical: DM.p10),
          width: DM.screenWidth,
          child: Text(
            "Test Item form",
            textAlign: TextAlign.left,
            style: TextStyle(color: secondaryColor, fontSize: DM.p30),
          ),
        ),
      ]),
      backgroundColor: secondaryColor,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Container(
            width: DM.screenWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    padding: EdgeInsets.all(DM.p15),
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
                          validatorField: validateName,
                          textInputType: TextInputType.name,
                          controller: name,
                          title: "Name",
                          value: "Write your name",
                          activate: false,
                        ),
                        FormUserInfo(
                          formKey: _formKey,
                          validatorField: validateName,
                          textInputType: TextInputType.name,
                          controller: diagnostic_center,
                          title: "Diagnostic Center",
                          value: "Write Diagnostic Name",
                          activate: false,
                        ),
                        Padding(
                          padding: EdgeInsets.all(DM.p1),
                          child: Row(
                            children: [
                              SizedBox(
                                width: DM.p100,
                                child: Text(
                                  "Is payable",
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
                              Checkbox(
                                  value: is_payable,
                                  onChanged: (value) {
                                    setState(() {
                                      is_payable = value!;
                                    });
                                  }),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(DM.p1),
                          child: Row(
                            children: [
                              SizedBox(
                                width: DM.p100,
                                child: Text(
                                  "Category",
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
                                  category,
                                  style: TextStyle(color: blackFontColor),
                                ),
                                items: <String>[
                                  'PATHOLOGY',
                                  'RADIO/IMAGE',
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
                                    category = newValue!;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        FormUserInfo(
                          formKey: _formKey,
                          validatorField: validateNumber,
                          textInputType: TextInputType.number,
                          controller: servicecharge,
                          title: "Collection Charge",
                          value: "0",
                          activate: false,
                        ),
                        FormUserInfo(
                          formKey: _formKey,
                          validatorField: validateNumber,
                          textInputType: TextInputType.number,
                          controller: discount,
                          title: "Discount",
                          value: "0",
                          activate: false,
                        ),
                        FormUserInfo(
                          formKey: _formKey,
                          validatorField: validateNumber,
                          textInputType: TextInputType.number,
                          controller: niddle_cost,
                          title: "Niddle Cost",
                          value: "0",
                          activate: false,
                        ),
                        FormUserInfo(
                          formKey: _formKey,
                          validatorField: validateNumber,
                          textInputType: TextInputType.number,
                          controller: transport_cost,
                          title: "Transport cost",
                          value: "0",
                          activate: false,
                        ),
                        FormUserInfo(
                          formKey: _formKey,
                          validatorField: validateNumber,
                          textInputType: TextInputType.number,
                          controller: testkitprice,
                          title: "Tube Cost",
                          value: "0",
                          activate: false,
                        ),
                        FormUserInfo(
                          formKey: _formKey,
                          validatorField: validateNumber,
                          textInputType: TextInputType.number,
                          controller: testprice,
                          title: "Test Price",
                          value: "0",
                          activate: false,
                        ),
                        FormUserInfo(
                          formKey: _formKey,
                          validatorField: validateName,
                          textInputType: TextInputType.number,
                          controller: b2b_cost,
                          title: "B2B Cost",
                          value: "0",
                          activate: false,
                        ),
                        FormUserInfo(
                          formKey: _formKey,
                          validatorField: validateNumber,
                          textInputType: TextInputType.number,
                          controller: softdelete,
                          title: "Softdelete",
                          value: "0",
                          activate: false,
                        ),
                      ],
                    )),

                // #text_field

                // #signup_button

                Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: DM.p20, vertical: DM.p35),
                  child: MaterialButton(
                    onPressed: () async {
                      if (_formKey.currentState?.validate() == true) {
                        if (await chechkingInternet()) {
                          if (widget.testItem == null) {
                            insertNewTestItemMethod();
                          } else {
                            updateToFirebase();
                          }

                          Get.back();
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
                    color: appTheme,
                    child: Text(
                      widget.testItem == null ? "Submit" : "Update",
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
              child: TextFormField(
                autofocus: true,
                keyboardType: textInputType,
                maxLines: null,
                validator: validatorField,
                onEditingComplete: (() {
                  if (!formKey.currentState?.validate())
                    formKey.currentState?.validate();
                }),
                controller: controller,
                readOnly: activate,
                decoration: InputDecoration(
                    errorStyle: TextStyle(fontSize: DM.p9),
                    disabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(width: DM.p1, color: appTheme)),
                    // focusedErrorBorder: OutlineInputBorder(
                    //     borderSide:
                    //         BorderSide(width: DM.p1, color: orangeColor)),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(width: DM.p1, color: appTheme)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: DM.p1, color: appTheme), //<-- SEE HERE
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

class FormInitialUserInfo extends StatelessWidget {
  dynamic title;
  dynamic value;
  dynamic activate;
  dynamic formKey;
  dynamic validatorField;
  var controller = new TextEditingController();
  var textInputType;
  FormInitialUserInfo(
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
              child: TextFormField(
                autofocus: true,
                keyboardType: textInputType,
                maxLines: null,
                validator: validatorField,
                onEditingComplete: (() {}),
                controller: controller,
                readOnly: activate,
                decoration: InputDecoration(
                    errorStyle: TextStyle(fontSize: DM.p9),
                    disabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(width: DM.p1, color: appTheme)),
                    // focusedErrorBorder: OutlineInputBorder(
                    //     borderSide:
                    //         BorderSide(width: DM.p1, color: orangeColor)),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(width: DM.p1, color: appTheme)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: DM.p1, color: appTheme), //<-- SEE HERE
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

// String? validateNumber(String? value) {
//   if (value?.length == 0 && (double.parse(value!) != null))
//     return 'Please fill this form';
//   else
//     return null;
// }

String? validateNumber(String? value) {
  if (value?.length == 0 || (double.tryParse(value!) == null)) {
    return 'Please fill numbers only';
  }
  return null;
}
