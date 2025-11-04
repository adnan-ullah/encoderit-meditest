import 'dart:convert';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:healthcare_homelab/constants/api.dart';
import 'package:healthcare_homelab/presentation/pages/HomeScreen.dart';
import 'package:healthcare_homelab/presentation/pages/adminPanel/AdminHome.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/app_info.dart';
import '../../constants/colors.dart';
import '../../db/models/AdminUserModel.dart';
import '../../constants/commission_types.dart';
import '../../responsives/dimensions.dart';
import '../../state_programming/CreateRequestController.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  List<AdminUserModel> adminUserList = [];
  var type = "1";
  var commission = "0";
  var referrer_code = "0";
  var admin_password;
  bool _isLoading = false;

  Future<void> getAdminUserList() async {
    final dbRef = FirebaseDatabase.instance;

    final adminUserRef = dbRef.ref("$database_name/admin_user");
     FirebaseDatabase.instance.setPersistenceEnabled(true);
    adminUserRef.keepSynced(true);
    final adminUserEvent = await adminUserRef.once();
    if (!adminUserEvent.snapshot.exists) {
      await adminUserRef.set({});
    }
    adminUserRef.onValue.listen((event) {
      adminUserList.clear(); // Optional
      for (DataSnapshot ds in event.snapshot.children) {
        AdminUserModel testData =
        AdminUserModel.fromJson(json.decode(jsonEncode(ds.value)));
        adminUserList.add(testData);
      }
    });

    final superUserRef = dbRef.ref("$database_name/samrat");
    final superUserEvent = await superUserRef.once();
    if (!superUserEvent.snapshot.exists) {
      await superUserRef.set({
        "superUser": "111000222999"
      });
    }
    superUserRef.onValue.listen((event) {
      for (DataSnapshot ds in event.snapshot.children) {
        superUser = ds.value.toString();
      }
    });
  }

  bool checkUser(phone) {
    bool returnType = false;
    adminUserList.map((e) {
      if (e.phone.toString() == phone.toString() &&
          e.active.toString() == "1") {
        type = e.type;
        // Use pathology group commissions - pick the first non-zero value
        String resolvedCommission = '0';
        for (final pathologyType in CommissionTypes.pathologyGroup) {
          final value = e.getCommission(pathologyType)?.toString();
          if (value != null && value.isNotEmpty && value != '0') {
            resolvedCommission = value;
            break;
          }
        }
        commission = resolvedCommission;
        if (e.referrer_code != null) {
          referrer_code = e.referrer_code;
        }
        if (e.password != null) {
          admin_password = e.password;
        }
        returnType = true;
      }
    }).toList();
    return returnType;
  }

  CreateRequestController createReqController =
      Get.put(CreateRequestController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var phone = TextEditingController();
  var password = TextEditingController();

  Future<void> getPhoneNumber() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("phoneNumber") != null)
      phone.text = prefs.getString("phoneNumber")!;
  }

  void updateCheck() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int? update_version = sharedPreferences.getInt("update_version");
    String? update_details = sharedPreferences.getString("update_details");

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String build_Number = packageInfo.buildNumber;

    if (update_version != null &&
        update_details != null &&
        update_version > int.parse(build_Number)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: secondaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DM.p20),
          ),
          title: Text(
            'Update Available',
            style: TextStyle(
              color: appTheme,
              fontWeight: FontWeight.bold,
              fontSize: DM.p20,
            ),
          ),
          content: Text(
            update_details,
            style: TextStyle(
              color: blackFontColor,
              fontSize: DM.p16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: appTheme,
                  fontSize: DM.p16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final Uri _url = Uri.parse(
                    "https://play.google.com/store/apps/details?id=com.innova.meditest");
                if (!await launchUrl(_url)) {
                  Get.snackbar('Error', 'Could not launch URL',
                      backgroundColor: redColor, colorText: whiteColor);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: appTheme,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DM.p10),
                ),
              ),
              child: Text(
                'Update',
                style: TextStyle(
                  color: fullWhiteColor,
                  fontSize: DM.p16,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  void initState() {
    getAdminUserList();
    updateCheck();
    getPhoneNumber();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    chechkingInternet();
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              appTheme.withOpacity(0.1),
              secondaryColor,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              height: DM.screenHeight,
              padding:
                  EdgeInsets.symmetric(horizontal: DM.p32, vertical: DM.p24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Name and Header
                  Column(
                    children: [
                      Text(
                        'Healthcare HomeLab',
                        style: TextStyle(
                          fontSize: DM.p40,
                          fontWeight: FontWeight.w900,
                          color: appTheme,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: DM.p16),
                      Icon(
                        Icons.medical_services,
                        size: DM.p64,
                        color: appTheme,
                      ),
                      SizedBox(height: DM.p16),
                      Text(
                        'Welcome',
                        style: TextStyle(
                          fontSize: DM.p28,
                          fontWeight: FontWeight.w600,
                          color: blackFontColor,
                        ),
                      ),
                      SizedBox(height: DM.p8),
                      Text(
                        'Sign in to continue',
                        style: TextStyle(
                          fontSize: DM.p16,
                          color: blackFontColor.withOpacity(0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  SizedBox(height: DM.p48),

                  // Form Card
                  Container(
                    padding: EdgeInsets.all(DM.p24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(DM.p16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: DM.p16,
                          offset: Offset(0, DM.p8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Phone Number Field
                          TextFormField(
                            controller: phone,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            validator: validateMobile,
                            style: TextStyle(fontSize: DM.p16),
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                              labelStyle:
                                  TextStyle(color: appTheme.withOpacity(0.6)),
                              prefixIcon: Icon(Icons.phone, color: appTheme),
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(DM.p12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(DM.p12),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(DM.p12),
                                borderSide:
                                    BorderSide(color: appTheme, width: DM.p2),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(DM.p12),
                                borderSide: BorderSide(color: redColor),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(DM.p12),
                                borderSide:
                                    BorderSide(color: redColor, width: DM.p2),
                              ),
                            ),
                          ),
                          SizedBox(height: DM.p20),

                          // Password Field
                          TextFormField(
                            controller: password,
                            obscureText: true,
                            style: TextStyle(fontSize: DM.p16),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle:
                                  TextStyle(color: appTheme.withOpacity(0.6)),
                              prefixIcon: Icon(Icons.lock, color: appTheme),
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(DM.p12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(DM.p12),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(DM.p12),
                                borderSide:
                                    BorderSide(color: appTheme, width: DM.p2),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(DM.p12),
                                borderSide: BorderSide(color: redColor),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(DM.p12),
                                borderSide:
                                    BorderSide(color: redColor, width: DM.p2),
                              ),
                            ),
                          ),
                          SizedBox(height: DM.p32),

                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            height: DM.p56,
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              child: ElevatedButton(
                                onPressed: _isLoading
                                    ? null
                                    : () async {
                                        setState(() => _isLoading = true);
                                        if (_formKey.currentState?.validate() ==
                                                true &&
                                            await chechkingInternet()) {
                                          if (phone.text == "$superUser" ||
                                              (checkUser(phone.text) == true &&
                                                  password.text ==
                                                      admin_password)) {
                                            if (phone.text == "$superUser") {
                                              savePhone(phone.text);
                                              Get.to(AdminHome(
                                                check_type: phone.text,
                                                check_number: phone.text,
                                              ));
                                            } else if (checkUser(phone.text) ==
                                                    true &&
                                                type == '2') {
                                              savePhone(phone.text);
                                              Get.to(AdminHome(
                                                check_type: "2",
                                                check_number: phone.text,
                                              ));
                                            } else if (checkUser(phone.text) ==
                                                    true &&
                                                type == '1') {
                                              savePhone(phone.text);
                                              Get.to(AdminHome(
                                                  check_type: "1",
                                                  check_number: phone.text));
                                            } else if (checkUser(phone.text) ==
                                                    true &&
                                                type == '7') {
                                              savePhone(phone.text);
                                              Get.to(AdminHome(
                                                  check_type: "7",
                                                  check_number: phone.text));
                                            } else if (checkUser(phone.text) ==
                                                    true &&
                                                type == '3') {
                                              savePhone(phone.text);
                                              Get.to(AdminHome(
                                                  check_type: "3",
                                                  check_number: phone.text));
                                            } else if (checkUser(phone.text) ==
                                                    true &&
                                                type == '4') {
                                              savePhone(phone.text);
                                              Get.to(AdminHome(
                                                  check_type: "4",
                                                  check_number: phone.text));
                                            }
                                            else if (checkUser(phone.text) ==
                                                true &&
                                                type == '8') {
                                              savePhone(phone.text);
                                              Get.to(AdminHome(
                                                  check_type: "8",
                                                  check_number: phone.text));
                                            }
                                            else {
                                              savePhone(phone.text);
                                              Get.to(HomeScreen());
                                            }
                                          } else {
                                            savePhone(phone.text);
                                            Get.to(HomeScreen());
                                          }
                                        }
                                        setState(() => _isLoading = false);
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(DM.p12),
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        appTheme,
                                        appTheme.withOpacity(0.8)
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(DM.p12),
                                  ),
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: _isLoading
                                        ? CircularProgressIndicator(
                                            color: fullWhiteColor,
                                            strokeWidth: DM.p3,
                                          )
                                        : Text(
                                            'Sign In',
                                            style: TextStyle(
                                              color: fullWhiteColor,
                                              fontSize: DM.p18,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> savePhone(phoneNumber) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("type", type.toString());
    prefs.setString('phoneNumber', phoneNumber);
    prefs.setString('commission', commission.toString());
    prefs.setString('referrer_code', referrer_code.toString());
  }
}

String? validateMobile(String? value) {
  if (value?.length != 11 && value?.length != 12)
    return 'Mobile Number must be of 11 to 12 digits';
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
    Get.snackbar(
      "Network Error!",
      "Check your internet connection",
      margin: EdgeInsets.symmetric(horizontal: DM.p70, vertical: DM.p60),
      backgroundColor: redColor,
      colorText: whiteColor,
    );
    return false;
  }
  return false;
}
