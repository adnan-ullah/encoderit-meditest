import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:healthcare_homelab/constants/api.dart';

import '../../../constants/colors.dart';
import '../../../db/models/AdminUserModel.dart';
import '../../../responsives/dimensions.dart';
import '../../../state_programming/CreateRequestController.dart';
import '../LoginScreen.dart';

class AdminUserData extends StatefulWidget {
  AdminUserModel? adminUser;

  AdminUserData({Key? key, this.adminUser}) : super(key: key);

  @override
  _AdminUserDataState createState() => _AdminUserDataState();
}

class _AdminUserDataState extends State<AdminUserData> {
  var updatedAdminUser;
  var insertNewAdminUser;

  Future<void> updateAdminUser() async {
    name.text = widget.adminUser!.name;
    active.text = widget.adminUser!.active.toString();
    password.text = widget.adminUser!.password.toString();
    phone.text = widget.adminUser!.phone.toString();
    type.text = widget.adminUser!.type.toString();
    pathology_commission.text =
        widget.adminUser!.pathology_commission?.toString() ?? "";
    imagine_commission.text =
        widget.adminUser!.imagine_commission?.toString() ?? "";
    referrer_code.text = widget.adminUser!.referrer_code?.toString() ?? "";
    address.text = widget.adminUser!.address.toString();
    surname.text = widget.adminUser!.surname.toString();
    short_address.text = widget.adminUser!.short_address.toString();
    percentage.text = widget.adminUser!.percentage?.toString() ?? "";
  }

  Future<void> updateToFirebase() async {
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    late DatabaseReference dbrefAdminUser;
    dbrefAdminUser = FirebaseDatabase.instance.ref("$adminUserApi/");

    updatedAdminUser = AdminUserModel(
      name: name.text.toString(),
      active: active.text.toString(),
      password: password.text.toString(),
      phone: phone.text.toString(),
      type: type.text.toString(),
      pathology_commission:
          type.text == "8" ? null : pathology_commission.text.toString(),
      referrer_code: type.text == "8" ? null : referrer_code.text.toString(),
      address: address.text.toString(),
      surname: surname.text.toString(),
      short_address: short_address.text.toString(),
      imagine_commission:
          type.text == "8" ? null : imagine_commission.text.toString(),
      percentage: type.text == "8" ? percentage.text.toString() : null,
    );

    if (updatedAdminUser != null) {
      await dbrefAdminUser
          .child(updatedAdminUser.phone)
          .update(jsonDecode(jsonEncode(updatedAdminUser)));
    }
  }

  Future<void> addNewUser() async {
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    DatabaseReference _dbref_testReqModel;
    _dbref_testReqModel = FirebaseDatabase.instance.ref("$adminUserApi/");

    insertNewAdminUser = AdminUserModel(
      name: name.text.toString(),
      active: active.text.toString(),
      password: password.text.toString(),
      phone: phone.text.toString(),
      type: type.text.toString(),
      pathology_commission:
          type.text == "8" ? null : pathology_commission.text.toString(),
      referrer_code: type.text == "8" ? null : referrer_code.text.toString(),
      address: address.text.toString(),
      surname: surname.text.toString(),
      short_address: short_address.text.toString(),
      imagine_commission:
          type.text == "8" ? null : imagine_commission.text.toString(),
      percentage: type.text == "8" ? percentage.text.toString() : null,
    );
    if (insertNewAdminUser != null) {
      await _dbref_testReqModel
          .child(insertNewAdminUser.phone)
          .set(insertNewAdminUser.toJson());
    }
  }

  @override
  void initState() {
    if (widget.adminUser != null) {
      updateAdminUser();
    }
    // Initialize TypeController with the type text value
    typeController.type.value = type.text.isEmpty ? "1" : type.text;
    // Listen to type changes to update UI
    type.addListener(() {
      typeController.type.value = type.text;
    });
    super.initState();
  }

  @override
  void dispose() {
    type.removeListener(() {});
    super.dispose();
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var name = TextEditingController();
  var active = TextEditingController();
  var password = TextEditingController();
  var phone = TextEditingController();
  var type = TextEditingController();
  var referrer_code = TextEditingController();
  var pathology_commission = TextEditingController();
  var imagine_commission = TextEditingController();
  var address = TextEditingController();
  var surname = TextEditingController();
  var short_address = TextEditingController();
  var percentage = TextEditingController();

  // GetX controller for reactive type field
  final typeController = Get.put(TypeController());

  var newTestListData;

  CreateRequestController createReqController =
      Get.put(CreateRequestController());

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
            "Admin User form",
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
                                          phone.text.length < 13 &&
                                          type.text != "8") {
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
                                                width: DM.p1, color: appTheme)),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: DM.p1, color: appTheme),
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
                        Obx(() => typeController.type.value != "8"
                            ? FormUserInfo(
                                formKey: _formKey,
                                validatorField: validateName,
                                textInputType: TextInputType.name,
                                controller: referrer_code,
                                title: "Referrer Code",
                                value: "0",
                                activate: false,
                              )
                            : SizedBox.shrink()),
                        Obx(() => typeController.type.value != "8"
                            ? Padding(
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
                                            FilteringTextInputFormatter
                                                .digitsOnly
                                          ],
                                          maxLines: null,
                                          validator: validateNumberOptional,
                                          decoration: InputDecoration(
                                              errorStyle:
                                                  TextStyle(fontSize: DM.p9),
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      width: DM.p1,
                                                      color: appTheme)),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    width: DM.p1,
                                                    color: appTheme),
                                              ),
                                              filled: true,
                                              fillColor: fullWhiteColor,
                                              contentPadding:
                                                  EdgeInsets.symmetric(
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
                              )
                            : SizedBox.shrink()),
                        Obx(() => typeController.type.value != "8"
                            ? Padding(
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
                                            FilteringTextInputFormatter
                                                .digitsOnly
                                          ],
                                          maxLines: null,
                                          validator: validateNumberOptional,
                                          decoration: InputDecoration(
                                              errorStyle:
                                                  TextStyle(fontSize: DM.p9),
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      width: DM.p1,
                                                      color: appTheme)),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    width: DM.p1,
                                                    color: appTheme),
                                              ),
                                              filled: true,
                                              fillColor: fullWhiteColor,
                                              contentPadding:
                                                  EdgeInsets.symmetric(
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
                              )
                            : SizedBox.shrink()),
                        Obx(() => typeController.type.value == "8"
                            ? Padding(
                                padding: EdgeInsets.all(DM.p5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: DM.p100,
                                      child: Text(
                                        "Percentage",
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
                                          controller: percentage,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'^\d*\.?\d{0,2}')),
                                          ],
                                          maxLines: null,
                                          validator: validatePercentage,
                                          decoration: InputDecoration(
                                              errorStyle:
                                                  TextStyle(fontSize: DM.p9),
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      width: DM.p1,
                                                      color: appTheme)),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    width: DM.p1,
                                                    color: appTheme),
                                              ),
                                              filled: true,
                                              fillColor: fullWhiteColor,
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: DM.p10),
                                              border: InputBorder.none,
                                              hintText: "Enter percentage",
                                              hintStyle: TextStyle(
                                                color: Colors.grey,
                                                fontSize: DM.p14,
                                              )),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : SizedBox.shrink()),
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
                                                width: DM.p1, color: appTheme)),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: DM.p1, color: appTheme),
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
                                                width: DM.p1, color: appTheme)),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: DM.p1, color: appTheme),
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
                Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: DM.p20, vertical: DM.p35),
                  child: MaterialButton(
                    onPressed: () async {
                      if (_formKey.currentState?.validate() == true) {
                        if (await chechkingInternet()) {
                          if (widget.adminUser == null) {
                            addNewUser();
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
                      widget.adminUser == null ? "Submit" : "Update",
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
        ),
      ),
    );
  }
}

// Controller for reactive type field
class TypeController extends GetxController {
  var type = "1".obs;

  @override
  void onInit() {
    super.onInit();
  }
}

class FormUserInfo extends StatelessWidget {
  dynamic title;
  dynamic value;
  dynamic activate;
  dynamic formKey;
  dynamic validatorField;
  var controller = TextEditingController();
  var textInputType;

  FormUserInfo({
    Key? key,
    required this.formKey,
    required this.title,
    required this.value,
    required this.activate,
    required this.controller,
    required this.textInputType,
    required this.validatorField,
  }) : super(key: key);

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
                onChanged: (value) {
                  if (title == "Type") {
                    Get.find<TypeController>().type.value = value;
                  }
                },
                decoration: InputDecoration(
                    errorStyle: TextStyle(fontSize: DM.p9),
                    disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: DM.p1, color: appTheme)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: DM.p1, color: appTheme)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: DM.p1, color: appTheme),
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

String? validateNumber(String? value) {
  if (value?.length == 0 || (double.tryParse(value!) == null)) {
    return 'Please fill numbers only';
  }
  return null;
}

String? validateNumberOptional(String? value) {
  if (value == null || value.isEmpty) {
    return null; // Allow empty values
  }
  if (double.tryParse(value) == null) {
    return 'Please enter a valid number';
  }
  return null;
}

String? validatePercentage(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter a percentage';
  }
  final percentage = double.tryParse(value);
  if (percentage == null || percentage < 0 || percentage > 100) {
    return 'Enter a valid percentage (0-100)';
  }
  return null;
}

String? validateName(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please fill this form';
  }
  return null;
}
