import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'package:sizer/sizer.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:healthcare_homelab/animations/Custom_Dialog.dart';
import 'package:healthcare_homelab/db/databse_model.dart';
import 'package:healthcare_homelab/presentation/pages/HomeScreen.dart';
import 'package:healthcare_homelab/presentation/pages/Template.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../constants/colors.dart';
import '../../responsives/dimensions.dart';
import '../../state_programming/Create_Request_Controller.dart';
import '../../state_programming/getController.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  CreateRequest_controller createReqController =
      Get.put(CreateRequest_controller());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var phone = TextEditingController();

  Future<void> getPhoneNumber() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    phone.text = prefs.getString("phoneNumber")!;
  }

  @override
  void initState() {
    getPhoneNumber();

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(20.sp);
    print(DM.screenHeight / DM.p200);
    chechkingInternet();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(backgroundColor: orangeColor, actions: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: DM.p20, vertical: DM.p2),
          width: DM.screenWidth,
          child: Text(
            "Login",
            textAlign: TextAlign.left,
            style: TextStyle(color: creamColor, fontSize: DM.p30),
          ),
        ),
      ]),
      backgroundColor: creamColor,
      body: Form(
        key: _formKey,
        child: Container(
          height: DM.screenHeight,
          width: DM.screenWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: DM.screenWidth,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          margin: EdgeInsets.all(DM.p30),
                          child: Column(
                            children: [
                              Text(
                                "Enter your phone",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: DM.p40,
                                    color: orangeColor),
                              ),
                              Text(
                                "number",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: DM.p40,
                                    color: orangeColor),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.all(DM.p40),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: DM.p70,
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
                                  keyboardType: TextInputType.phone,
                                  controller: phone,
                                  validator: validateMobile,
                                  onChanged: ((value) {
                                    _formKey.currentState?.validate();
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
                                            color: orangeColor), //<-- SEE HERE
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: InputBorder.none,
                                      hintText: "Ex: 01888888888",
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
                      Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: DM.p20, vertical: DM.p30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: DM.p130,
                              child: MaterialButton(
                                onPressed: () async {
                                  if (_formKey.currentState?.validate() ==
                                          true &&
                                      await chechkingInternet()) {
                                    savePhone(phone.text);
                                    Get.to(HomeScreen());
                                  }
                                },
                                height: DM.p50,
                                shape: const StadiumBorder(),
                                color: orangeColor,
                                child: Text(
                                  "Login",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: fullWhiteColor,
                                      fontSize: DM.p15,
                                      fontWeight: FontWeight.bold),
                                ),
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

  Future<void> savePhone(phoneNumber) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('phoneNumber', phoneNumber);
  }
}

String? validateMobile(String? value) {
  if (value?.length != 11 && value?.length != 12)
    return 'Mobile Number must be of 11 to 12 digits';
  else
    return null;
}

String? validateString(String? value) {
  if (value?.length == 0)
    return 'Please fill this form';
  else
    return null;
}

Future<bool> chechkingInternet() async {
  try {
    final result = await InternetAddress.lookup('example.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return true;
    }
  } on SocketException catch (_) {
    Get.snackbar("Network Error!", "Check your internet connection",
        margin: EdgeInsets.symmetric(horizontal: DM.p70, vertical: DM.p60),
        backgroundColor: redColor,
        colorText: whiteColor);
    return false;
  }

  return false;
}
