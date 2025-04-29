import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';
import 'package:healthcare_homelab/presentation/pages/Create_Prescription.dart';
import 'package:healthcare_homelab/presentation/pages/Create_Request.dart';
import 'package:healthcare_homelab/presentation/widgets/projectsWidget/RequestList.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/app_info.dart';
import '../../constants/colors.dart';
import '../../responsives/dimensions.dart';
import '../../state_programming/Create_Request_Controller.dart';
import 'Login_info.dart';

class HomeScreen extends StatefulWidget {
  // static const String id = "sign_up_page";

  HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CreateRequest_controller createReqController =
      Get.put(CreateRequest_controller());

  Future<void> resetSharedData() async {
    SharedPreferences refs = await SharedPreferences.getInstance();
    refs.setString("type", "0");
  }

  @override
  void initState() {
    resetSharedData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(backgroundColor: appTheme, actions: [
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: DM.p50),
          width: DM.screenWidth,
          child: Text(
            "$app_name",
            style: TextStyle(
                color: secondaryColor,
                fontWeight: FontWeight.bold,
                fontSize: DM.p25),
          ),
        ),
      ]),
      backgroundColor: secondaryColor,
      body: Container(
        width: DM.screenWidth,
        child: Column(
          children: [
            // #text_field
            Container(
                margin: EdgeInsets.symmetric(horizontal: DM.p15),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(DM.p10),
                ),
                child: RequestList()),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Hotline",
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: DM.p15,
                      color: redColor),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Call_Number("01785890750" , _callNumber1),
                    Call_Number("01862739539", _callNumber2),
                  
                  ],
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: DM.p20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      child: MaterialButton(
                        onPressed: () async {
                          if (await chechkingInternet()) Get.to(Prescription());
                        },
                        height: DM.p50,
                        shape: const StadiumBorder(),
                        color: appTheme,
                        child: Text(
                          // "Prescription \nRequest",
                          "প্রেসক্রিপশনের \nছবি তুলুন",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: fullWhiteColor,
                              fontSize: DM.p13,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: DM.p10),
                    width: DM.p40,
                    child: Text(
                      "অথবা",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: DM.p13,
                          color: Color.fromARGB(255, 26, 1, 1)),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      child: MaterialButton(
                        onPressed: () async {
                          if (await chechkingInternet()) {
                            createReqController.testData.clear();
                            Get.to(CreateRequest());
                          }
                        },
                        height: DM.p50,
                        shape: const StadiumBorder(),
                        color: appTheme,
                        child: Text(
                          //"Request \nForm",
                          "ফরম পূরণ \nকরুন",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: fullWhiteColor,
                              fontSize: DM.p13,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Flexible(child: Container(height: DM.p24, child: TextField()))
          ],
        ),
      ),
    );
  }

  InkWell Call_Number(number , callNumber) {
    return InkWell(
                    onTap: callNumber,
                    child: Container(
                      padding: EdgeInsets.all(DM.p12),
                      child: Text(
                        number,
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: DM.p15,
                            color: redColor),
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

_callNumber1() async {
  const number = '01785890750'; //set the number here
  bool? res = await FlutterPhoneDirectCaller.callNumber(number);
}

_callNumber2() async {
  const number = '01862739539'; //set the number here
  bool? res = await FlutterPhoneDirectCaller.callNumber(number);
}
