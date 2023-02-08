import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthcare_homelab/constants/colors.dart';
import 'package:healthcare_homelab/db/databse_model.dart';
import 'package:healthcare_homelab/presentation/pages/Create_Request.dart';
import 'package:healthcare_homelab/presentation/pages/adminPanel/TestData.dart';
import 'package:healthcare_homelab/presentation/pages/adminPanel/TestItemList.dart';
import 'package:healthcare_homelab/presentation/pages/adminPanel/TestRequestItem.dart';
import 'package:healthcare_homelab/presentation/widgets/projectsWidget/Notifications/GenerateNotification.dart';
import 'package:healthcare_homelab/presentation/widgets/projectsWidget/Notifications/NotificationServices.dart';
import 'package:healthcare_homelab/state_programming/Create_Request_Controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/app_info.dart';
import '../../../responsives/dimensions.dart';
import '../../widgets/projectsWidget/RequestListTabView.dart';

class StatusRequestListTypeFour extends StatefulWidget {
  StatusRequestListTypeFour({super.key});

  @override
  State<StatusRequestListTypeFour> createState() =>
      _StatusRequestListTypeFourState();
}

FirebaseMessaging messaging = FirebaseMessaging.instance;

class _StatusRequestListTypeFourState extends State<StatusRequestListTypeFour>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(length: 4, vsync: this, initialIndex: 0);

    setState(() {
      _selectedIndex = tabController.index;
    });
    // TODO: implement initState
    super.initState();
  }

  CreateRequest_controller cr_controller = Get.put(CreateRequest_controller());

  var isLoading = true;

  void _onLoading(isClosed) {
    if (isClosed) {
      setState(() {
        isLoading = true;
      });
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              height: DM.p120,
              padding: EdgeInsets.all(DM.p16),
              child: new Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  new CircularProgressIndicator(
                    color: orangeColor,
                  ),
                  SizedBox(
                    width: DM.p10,
                  ),
                  new Text(
                    "Loading, please wait...",
                    style: TextStyle(color: orangeColor),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else if (!isClosed && isLoading) {
      setState(() {
        isLoading = false;
      });
      Navigator.pop(context);
    }
  }

  dynamic status1, status2, status3;
  late DatabaseReference _dbref_testReqModel;
  Future<void> _getNotification(context) async {
    _dbref_testReqModel =
        await FirebaseDatabase.instance.ref("$database_name/testRequest/");

    // status1 = _dbref_testReqModel.onValue.listen((event) async {
    //   SharedPreferences refs = await SharedPreferences.getInstance();
    //   var phoneNumber = refs.getString("phoneNumber");
    //   var type_admin = refs.getString("type");
    //   getAdminNotification(phoneNumber, type_admin, context);
    // });

    status2 = _dbref_testReqModel.onChildAdded.listen((event) async {
      SharedPreferences refs = await SharedPreferences.getInstance();
      var phoneNumber = refs.getString("phoneNumber");
      var type_admin = refs.getString("type");
      getAdminNotification(phoneNumber, type_admin, context);
    });

    // status3 = _dbref_testReqModel.onChildRemoved.listen((event) async {
    //   SharedPreferences refs = await SharedPreferences.getInstance();
    //   var phoneNumber = refs.getString("phoneNumber");
    //   var type_admin = refs.getString("type");
    //   getAdminNotification(phoneNumber, type_admin, context);
    // });
  }

  @override
  void dispose() {
    // status1?.cancel();
    status2?.cancel();
    // status3?.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      _getNotification(context);
    });

    return Scaffold(
      backgroundColor: creamColor,
      appBar: AppBar(backgroundColor: orangeColor, actions: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: DM.p50, vertical: DM.p10),
          width: DM.screenWidth,
          child: Text(
            "Report Status",
            textAlign: TextAlign.left,
            style: TextStyle(color: creamColor, fontSize: DM.p30),
          ),
        ),
      ]),
      body: Padding(
        padding: EdgeInsets.all(DM.p5),
        child: Container(
          child: Column(
            children: [
              Container(
                height: DM.p40,
                child: TabBar(
                  isScrollable: true,
                  controller: tabController,
                  onTap: ((value) {}),
                  tabs: [
                    Tab(
                      child: Text(
                        "${cr_controller.status[1]}",
                        style: TextStyle(
                            color: blackFontColor,
                            fontSize: DM.p11,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Tab(
                      child: Text(
                        "${cr_controller.status[2]}",
                        style: TextStyle(
                            color: blackFontColor,
                            fontSize: DM.p11,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Tab(
                      child: Text(
                        "PRE COLLECTED",
                        style: TextStyle(
                            color: blackFontColor,
                            fontSize: DM.p11,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Tab(
                      child: Text(
                        "${cr_controller.status[3]}",
                        style: TextStyle(
                            color: blackFontColor,
                            fontSize: DM.p11,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: tabController,
                  children: [
                    RequestListTabView(
                        statusKey: cr_controller.status[1], isButton: false),
                    RequestListTabView(
                        statusKey: cr_controller.status[2], isButton: false),
                    RequestListTabView(
                        statusKey: "PCollected", isButton: false),
                    RequestListTabView(
                        statusKey: cr_controller.status[3], isButton: false),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> populateAllRequest() async {
  CreateRequest_controller createRequestController =
      Get.put(CreateRequest_controller());
  late DatabaseReference dbrefTestRequest;
  dbrefTestRequest =
      FirebaseDatabase.instance.ref("$database_name/testRequest/");
  FirebaseDatabase.instance.setPersistenceEnabled(true);
  dbrefTestRequest.keepSynced(true);

  createRequestController.testItemList.clear();
  createRequestController.testItemListWithSelected.clear();

  dbrefTestRequest.onValue.listen((event) {
    // for (DataSnapshot ds in event.snapshot.children.forEach((element) {element. })) {
    // print(ds.value);
    print("\n\n\n\n");
    // for (var element in event.snapshot.children) {
    //   print(element.children.forEach((element) {
    //     print("object");
    //   }));
    // }

    // TestDataRequest testDataRequest =
    //     TestDataRequest.fromJson(json.decode(jsonEncode(ds.value)));
    // print(testDataRequest.id);

    //   TestData testData = TestData.fromJson(json.decode(jsonEncode(ds.value)));

    // createRequestController.testItemList.add(testData);
    // createRequestController.testItemListWithSelected[testData.id] = false;
    //false -> add button
    //true -> remove button

    // print(testData.name);
    // }
  });
}

Future<void> getAdminNotification(phone, type, context) async {
  if (type == "1" || type == "7" || phone == "$superUser") {
    createPlantFoodNotification();
    showNotification(context);
  }
}
