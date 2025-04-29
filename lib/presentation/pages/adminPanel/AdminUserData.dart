import 'dart:convert';
import 'dart:ffi';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:healthcare_homelab/presentation/widgets/majorWidgets/Custom_Dialog.dart';
import 'package:healthcare_homelab/presentation/pages/Create_Request.dart';

import 'package:healthcare_homelab/presentation/widgets/projectsWidget/ConfirmationList.dart';
import 'package:healthcare_homelab/presentation/widgets/projectsWidget/Confirmation_TestItem.dart';
import 'package:healthcare_homelab/presentation/widgets/projectsWidget/TestListDialogueBox.dart';
import 'package:healthcare_homelab/presentation/widgets/projectsWidget/TextBoxDialogBox.dart';
import 'package:healthcare_homelab/presentation/widgets/minorWidgets/smallDialogBox.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../constants/app_info.dart';
import '../../../constants/colors.dart';
import '../../../db/databse_model.dart';
import '../../../responsives/dimensions.dart';
import '../../../state_programming/Create_Request_Controller.dart';
import '../../../state_programming/getController.dart';
import '../../widgets/projectsWidget/Notifications/NotificationServices.dart';
import '../Login_info.dart';

class AdminUserData extends StatefulWidget {
  // static const String id = "sign_up_page";
  AdminUserModel? testItem;
  AdminUserData({Key? key, this.testItem}) : super(key: key);

  @override
  _AdminUserDataState createState() => _AdminUserDataState();
}

class _AdminUserDataState extends State<AdminUserData> {
  var updatedTestItemData;
  var inserNewTestItem;

  Future<void> updateTestItem() async {
    name.text = widget.testItem!.name;
    active.text = widget.testItem!.active.toString();
    password.text = widget.testItem!.password.toString();
    phone.text = widget.testItem!.phone.toString();
    type.text = widget.testItem!.type.toString();

    pathology_commission.text =
        widget.testItem!.pathology_commission.toString();
    imagine_commission.text = widget.testItem!.imagine_commission.toString();
    referrer_code.text = widget.testItem!.referrer_code.toString();
    address.text = widget.testItem!.address.toString();
    surname.text = widget.testItem!.surname.toString();
    short_address.text = widget.testItem!.short_address.toString();
  }

  Future<void> updateToFirebase() async {
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    late DatabaseReference dbrefTestReqModel;
    dbrefTestReqModel = FirebaseDatabase.instance.ref("$database_name/");

    updatedTestItemData = AdminUserModel(
        name: name.text.toString(),
        active: active.text.toString(),
        password: password.text.toString(),
        phone: phone.text.toString(),
        type: type.text.toString(),
        pathology_commission: pathology_commission.text.toString(),
        referrer_code: referrer_code.text.toString(),
        address: address.text.toString(),
        surname: surname.text.toString(),
        short_address: short_address.text.toString(),
        imagine_commission: imagine_commission.text.toString()
        );

    if (updatedTestItemData != null) {
      await dbrefTestReqModel
          .child("admin_user")
          .child(updatedTestItemData.phone)
          .update(jsonDecode(jsonEncode(updatedTestItemData)));
    }
  }

  Future<void> insertNewTestItemMethod() async {
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    DatabaseReference _dbref_testReqModel;
    _dbref_testReqModel = FirebaseDatabase.instance.ref("$database_name/");

    inserNewTestItem = AdminUserModel(
        name: name.text.toString(),
        active: active.text.toString(),
        password: password.text.toString(),
        phone: phone.text.toString(),
        type: type.text.toString(),
        pathology_commission: pathology_commission.text.toString(),
        referrer_code: referrer_code.text.toString(),
        address: address.text.toString(),
        surname: surname.text.toString(),
        short_address: short_address.text.toString(),
         imagine_commission: imagine_commission.text.toString());
    if (inserNewTestItem != null) {
      await _dbref_testReqModel
          .child("admin_user")
          .child(inserNewTestItem.phone)
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

  var name = new TextEditingController();
  var active = new TextEditingController();
  var password = TextEditingController();
  var phone = TextEditingController();
  var type = TextEditingController();
  var referrer_code = TextEditingController();
  var pathology_commission = TextEditingController();
  var imagine_commission = TextEditingController();
  var address = TextEditingController();
  var surname = TextEditingController();
  var short_address = TextEditingController();

  //form variables:

  var newTestListData;

  CreateRequest_controller createReqController =
      Get.put(CreateRequest_controller());

  @override
  Widget build(BuildContext context) {
    chechkingInternet();
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(backgroundColor: orangeColor, actions: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: DM.p50, vertical: DM.p10),
          width: DM.screenWidth,
          child: Text(
            "Admin User form",
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
                          value: "Write user name",
                          activate: false,
                        ),
                        FormUserInfo(
                          formKey: _formKey,
                          validatorField: validateName,
                          textInputType: TextInputType.name,
                          controller: surname,
                          title: "Surname",
                          value: "Write surname",
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
                                  child: TextFormField(
                                    controller: phone,
                                    keyboardType: TextInputType.phone,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    maxLines: null,
                                    validator: validateMobile,
                                    onChanged: (value) {
                                      if (phone.text.length > 10 &&
                                          phone.text.length < 13) {
                                        if (phone.text.length == 11) {
                                          referrer_code.text =
                                              phone.text.substring(5);
                                        } else if (phone.text.length == 12) {
                                          referrer_code.text =
                                              phone.text.substring(6);
                                        }
                                      }
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
                                        fillColor: fullWhiteColor,
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: DM.p10),
                                        border: InputBorder.none,
                                        hintText: "Write user phone",
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
                          validatorField: validateNumber,
                          textInputType: TextInputType.number,
                          controller: active,
                          title: "Active",
                          value: "1",
                          activate: false,
                        ),
                        FormUserInfo(
                          formKey: _formKey,
                          validatorField: validateString,
                          textInputType: TextInputType.name,
                          controller: password,
                          title: "Password",
                          value: "Password",
                          activate: false,
                        ),
                        FormUserInfo(
                          formKey: _formKey,
                          validatorField: validateNumber,
                          textInputType: TextInputType.number,
                          controller: type,
                          title: "Type",
                          value: "1",
                          activate: false,
                        ),
                        FormUserInfo(
                          formKey: _formKey,
                          validatorField: validateName,
                          textInputType: TextInputType.name,
                          controller: referrer_code,
                          title: "Referrer Code",
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
                                  "Pathology Commission",
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
                                    controller: pathology_commission,
                                    keyboardType: TextInputType.phone,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    maxLines: null,
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
                                  "Imagine Commission",
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
                                    controller: imagine_commission,
                                    keyboardType: TextInputType.phone,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    maxLines: null,
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
                                  "Short Address",
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
                                    controller: short_address,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null,
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
                                        hintText: "Short Address",
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
                    color: orangeColor,
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
