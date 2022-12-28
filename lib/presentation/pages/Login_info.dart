import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:healthcare_homelab/presentation/pages/adminPanel/AdminHom.dart';
import 'package:healthcare_homelab/presentation/pages/adminPanel/TestItemList.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
import 'package:url_launcher/url_launcher.dart';
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
    if (prefs.getString("phoneNumber") != null)
      phone.text = prefs.getString("phoneNumber")!;
  }

  void updateCheck() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    int? update_version = sharedPreferences.getInt("update_version");
    String? update_details = sharedPreferences.getString("update_details");

    // sharedPreferences.remove("update_version");
    // sharedPreferences.remove("update_details");

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String build_Number = packageInfo.buildNumber;
    if (update_version != null && update_details != null) if (update_version! >
        int.parse(build_Number)) {
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          margin: EdgeInsets.all(16),
                          child: Text(
                            "${update_details}",
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: Color.fromARGB(255, 26, 1, 1)),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: DM.p20, vertical: DM.p10),
                              child: MaterialButton(
                                onPressed: () {
                                  Get.back();
                                },
                                height: DM.p40,
                                minWidth: DM.p120,
                                shape: const StadiumBorder(),
                                color: orangeColor,
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(
                                      color: fullWhiteColor,
                                      fontSize: DM.p15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: DM.p20, vertical: DM.p10),
                              child: MaterialButton(
                                onPressed: () async {
                                  final Uri _url = Uri.parse(
                                      "https://play.google.com/store/apps/details?id=com.innova.meditest");
                                  if (!await launchUrl(_url)) {
                                    throw 'Could not launch $_url';
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
                          ],
                        ),
                      ],
                    )),
              ),
            );
          });
    }
  }

  @override
  void initState() {
    updateCheck();
    getPhoneNumber();

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    chechkingInternet();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(backgroundColor: orangeColor, actions: [
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: DM.p20),
          width: DM.screenWidth,
          child: Text(
            "Login",
            textAlign: TextAlign.left,
            style: TextStyle(
                color: creamColor,
                fontWeight: FontWeight.bold,
                fontSize: DM.p25),
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
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
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
                                   //admin-app

                                     savePhone(phone.text);
                                    if (phone.text == "111000222999") {
                                      savePhone(phone.text);
                                      Get.to(AdminHome());
                                    } else {
                                       Get.to(HomeScreen());
                                    }

                               
                              
                                   
                                  //client-app please add this
                                  //// inputFormatters: <TextInputFormatter>[
                                  //   FilteringTextInputFormatter.digitsOnly
                                  // ],
                                
                                  
                                  //   if (!phone.text.contains("*") &&
                                  //       !phone.text.contains("#")) {
                                  //     savePhone(phone.text);

                                  //      Get.to(HomeScreen());

                                  //   } else {
                                  //     Get.snackbar("Number error!",
                                  //         "Please put a valid number",
                                  //         margin: EdgeInsets.symmetric(
                                  //             horizontal: DM.p70,
                                  //             vertical: DM.p60),
                                  //         backgroundColor: orangeColor,
                                  //         colorText: whiteColor);
                                  //   }
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
