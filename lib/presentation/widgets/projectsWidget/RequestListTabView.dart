import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthcare_homelab/constants/colors.dart';
import 'package:healthcare_homelab/presentation/pages/adminPanel/TestRequestItem.dart';
import 'package:healthcare_homelab/presentation/pages/adminPanel/TestRequestItemTypeThree.dart';
import 'package:healthcare_homelab/presentation/widgets/projectsWidget/Notifications/GenerateNotification.dart';
import 'package:healthcare_homelab/presentation/widgets/projectsWidget/Notifications/NotificationServices.dart';
import 'package:healthcare_homelab/state_programming/CreateRequestController.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/app_info.dart';
import '../../../db/models/AdminUserModel.dart';
import '../../../db/models/TestDataRequest.dart';
import '../../../responsives/dimensions.dart';

class RequestListTabView extends StatefulWidget {
  final String statusKey;
  final bool isButton;
  final String searchQuery;

  RequestListTabView({
    super.key,
    required this.statusKey,
    required this.isButton,
    required this.searchQuery,
  });

  @override
  State<RequestListTabView> createState() => _RequestListTabViewState();
}

class _RequestListTabViewState extends State<RequestListTabView> {
  CreateRequestController createRequest_controller =
      Get.put(CreateRequestController());
  var testStatusRequestList = <TestDataRequest>[];
  var isLoading = false;
  var type;
  var phone;

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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: appTheme),
                  SizedBox(width: DM.p10),
                  Text("Loading, please wait...",
                      style: TextStyle(color: appTheme)),
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

  Future<void> _updateStatus(TestDataRequest requestItem) async {
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    DateTime createdDate = DateTime.fromMillisecondsSinceEpoch(
        requestItem.dateofcreated ?? currentTime);
    String year = createdDate.year.toString();
    String month = getMonthName(createdDate.month);
    String path = "$database_name/testRequest/$year/$month";
    DatabaseReference dbRefTestReqModel = FirebaseDatabase.instance.ref(path);

    TestDataRequest updateTestRequestItem = TestDataRequest(
      id: requestItem.id,
      name: requestItem.name,
      gender: requestItem.gender,
      mobile: requestItem.mobile,
      age: requestItem.age,
      testlist: requestItem.testlist,
      totalprice: requestItem.totalprice,
      servicecharge: requestItem.servicecharge,
      address: requestItem.address,
      referrer: requestItem.referrer,
      lastupdate: currentTime,
      dateofcreated: requestItem.dateofcreated,
      softdelete: requestItem.softdelete,
      latitude: requestItem.latitude,
      longitude: requestItem.longitude,
      teststatus: requestItem.teststatus + 1,
      invoice_call: requestItem.invoice_call,
      type: requestItem.type,
      image_one: requestItem.image_one,
      image_two: requestItem.image_two,
      comments: requestItem.comments,
      total_payable_imagine_cost: requestItem.total_payable_imagine_cost,
      total_payable_pathology_cost: requestItem.total_payable_pathology_cost,
      total_payable: requestItem.total_payable,
      total_unpayable: requestItem.total_unpayable,
      admin_pathology_discount: requestItem.admin_pathology_discount,
      admin_radiology_discount: requestItem.admin_radiology_discount,
      agent_commission: requestItem.agent_commission,
      agent_pathology_discount: requestItem.agent_pathology_discount,
      agent_radiology_discount: requestItem.agent_radiology_discount,
      area: requestItem.area,
      advanced: requestItem.advanced,
      delivery_date: requestItem.delivery_date,
      due_amount: requestItem.due_amount,
      test_item_cost: requestItem.test_item_cost,
      test_item_discount: requestItem.test_item_discount,
      total_admin_discount: requestItem.total_admin_discount,
      total_agent_discount: requestItem.total_agent_discount,
      total_discount: requestItem.total_discount,
      is_paid: requestItem.is_paid,
      total_unpayable_pathology: requestItem.total_unpayable_pathology,
      total_unpayable_imagine: requestItem.total_unpayable_imagine,
      payment_date: requestItem.payment_date,
      advance_payment_date: requestItem.advance_payment_date,
      pathology_done: requestItem.pathology_done,
      radiology_done: requestItem.radiology_done,
      assigning: requestItem.assigning,
      radiology_assigning: requestItem.radiology_assigning,
      assigning_commission: requestItem.assigning_commission,
      radiology_assigning_commission:
          requestItem.radiology_assigning_commission,
      imageDiscountFile: requestItem.imageDiscountFile,
      prepared_by: requestItem.prepared_by,
      last_modifier: requestItem.last_modifier,
      due_recieved_one: requestItem.due_recieved_one,
      due_recieved_one_by: requestItem.due_recieved_one_by,
      due_recieve_one_date: requestItem.due_recieve_one_date,
      due_recieved_two: requestItem.due_recieved_two,
      due_recieve_two_date: requestItem.due_recieve_two_date,
      total_cash_recieve: requestItem.total_cash_recieve,
      due_recieved_two_by: requestItem.due_recieved_two_by,
      advance_recieved_by: requestItem.advance_recieved_by,
    );

    await dbRefTestReqModel
        .child(updateTestRequestItem.mobile)
        .child(updateTestRequestItem.id)
        .update(jsonDecode(jsonEncode(updateTestRequestItem.toJson())));
  }

  Future<void> getStatusData(context) async {
    _onLoading(true);
    SharedPreferences ref = await SharedPreferences.getInstance();
    type = ref.getString("type");
    phone = ref.getString("phoneNumber");
    List<String> paths = getLastThreeMonthTestRequestPaths();

    for (String path in paths) {
      DatabaseReference dbRef = FirebaseDatabase.instance.ref(path);
      if (path == paths.first) {
        dbRef.onValue.listen((event) async {
          testStatusRequestList.clear();
          parseTestDataFromSnapshot(event.snapshot);
        });
      } else {
        DataSnapshot snapshot = await dbRef.get();
        parseTestDataFromSnapshot(snapshot);
      }
    }
    _onLoading(false);
  }

  void parseTestDataFromSnapshot(DataSnapshot snapshot) {
    List<TestDataRequest> tempList = [];
    for (DataSnapshot ds in snapshot.children) {
      for (DataSnapshot dsLater in ds.children) {
        TestDataRequest testData = TestDataRequest.fromJson(
          json.decode(jsonEncode(dsLater.value)),
        );
        if (type == "4" && phone != superUser) {
          if (testData.assigning == phone ||
              testData.radiology_assigning == phone) {
            if (widget.statusKey == "PRECOLLECTED") {
              if ((testData.pathology_done == true &&
                      testData.radiology_done == false) ||
                  (testData.pathology_done == false &&
                      testData.radiology_done == true)) {
                tempList.add(testData);
              }
            } else if (widget.statusKey == "RECIEVED") {
              if (testData.pathology_done == false ||
                  testData.radiology_done == false) {
                tempList.add(testData);
              }
            } else if (widget.statusKey == "COLLECTED") {
              if (testData.pathology_done == true &&
                  testData.radiology_done == true) {
                tempList.add(testData);
              }
            } else {
              tempList.add(testData);
            }
          }
        } else if (type == "3" && phone != superUser) {
          if (widget.statusKey == "PRECOLLECTED") {
            if ((testData.assigning?.isNotEmpty == true &&
                    testData.assigning != "null") ||
                (testData.radiology_assigning?.isNotEmpty == true &&
                    testData.radiology_assigning != "null")) {
              if (!(testData.pathology_done == true &&
                  testData.radiology_done == true)) {
                tempList.add(testData);
              }
            }
          } else if (widget.statusKey == "COLLECTED") {
            if (testData.pathology_done == true &&
                testData.radiology_done == true) {
              tempList.add(testData);
            }
          } else {
            tempList.add(testData);
          }
        } else {
          tempList.add(testData);
        }
      }
    }
    tempList.sort((a, b) => (b.lastupdate ?? 0).compareTo(a.lastupdate ?? 0));
    print("TemplIst" + tempList.toString());
    testStatusRequestList.addAll(tempList);
    tabStatusList();
  }

  Future getStoragePermission() async {
    PermissionStatus status = await Permission.storage.request();
    PermissionStatus status2 = await Permission.manageExternalStorage.request();
    if (status.isGranted && status2.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied || status2.isPermanentlyDenied) {
      await openAppSettings();
    } else if (status.isDenied) {
      print('Permission Denied');
    }
  }

  Future<void> getAdminNotification(phone, type, context) async {
    FirebaseDatabase.instance.setPersistenceEnabled(true);
    List<String> lastThreeMonthsPaths = getLastThreeMonthTestRequestPaths();
    for (String path in lastThreeMonthsPaths) {
      DatabaseReference dbRefTestModel = FirebaseDatabase.instance.ref(path);
      dbRefTestModel.keepSynced(true);
      final event = await dbRefTestModel.once();
      if (!event.snapshot.exists) continue;
      for (DataSnapshot ds in event.snapshot.children) {
        AdminUserModel testData =
            AdminUserModel.fromJson(json.decode(jsonEncode(ds.value)));
        if (testData.phone == phone || phone == "$superUser") {
          if (type == "1" || type == "7" || phone == "$superUser") {
            createPlantFoodNotification();
            showNotification(context);
          }
        }
      }
    }
  }

  String getFirstName(String name) {
    String firstName;
    List<String> test = name.split(" ");
    if (test.first == "Mr." ||
        test.first == "Mr" ||
        test.first == "Mrs." ||
        test.first == "Mrs" ||
        test.first == "Md." ||
        test.first == "Md" ||
        test.first == "Ms." ||
        test.first == "Ms") {
      firstName = test[1];
    } else {
      firstName = test.first;
    }
    return firstName.toString();
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      this.getStatusData(context);
    });
    super.initState();
  }

  List<TestDataRequest> _newTestRequestList = [];

  void tabStatusList() async {
    if (!mounted) return;
    setState(() {
      _newTestRequestList.clear();
      _newTestRequestList.addAll(
        testStatusRequestList
            .where((p0) =>
                createRequest_controller.status[p0.teststatus].toString() ==
                widget.statusKey.toString())
            .toList(),
      );
    });
  }

  List<TestDataRequest> _getFilteredList() {
    if (widget.searchQuery.isEmpty) {
      return _newTestRequestList;
    }
    return _newTestRequestList.where((item) {
      final invoiceCall = item.invoice_call?.toString().toLowerCase() ?? '';
      final name = item.name?.toLowerCase() ?? '';
      final query = widget.searchQuery.toLowerCase();
      return invoiceCall.contains(query) || name.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    bool showChangedByColumn =
        (createRequest_controller.toStatus[widget.statusKey]! <= 6 ||
                createRequest_controller.toStatus[widget.statusKey] == 8) &&
            _newTestRequestList.any((item) =>
                item.prepared_by != null || item.last_modifier != null);

    // Define column widths to ensure alignment
    const double typeWidth = 40.0;
    const double nameWidth = 70.0;
    const double invoiceWidth = 90.0;
    const double dateWidth = 80.0;
    const double changedByWidth = 80.0;
    const double buttonWidth = 80.0;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _getFilteredList().isNotEmpty
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    // Header Row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: DM.p8, vertical: DM.p8),
                        decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: Colors.black, width: DM.p2)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: typeWidth,
                              child: Text(
                                "T",
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: DM.p14,
                                  color: Color.fromARGB(255, 26, 1, 1),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Container(
                              width: nameWidth,
                              child: Text(
                                "Name",
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: DM.p14,
                                  color: Color.fromARGB(255, 26, 1, 1),
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Container(
                              width: invoiceWidth,
                              child: Text(
                                "Invoice Call",
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: DM.p14,
                                  color: Color.fromARGB(255, 26, 1, 1),
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Container(
                              width: dateWidth,
                              child: Text(
                                "Date",
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: DM.p14,
                                  color: Color.fromARGB(255, 26, 1, 1),
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),

                              Container(
                                width: changedByWidth,
                                child: showChangedByColumn
                                    ? Text(
                                  "Changed by",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: DM.p14,
                                    color: Color.fromARGB(255, 26, 1, 1),
                                  ),
                                  textAlign: TextAlign.left,
                                )
                                    : SizedBox.shrink(),
                              ),
                            if (widget.isButton &&
                                (createRequest_controller
                                            .toStatus[widget.statusKey]! <
                                        5 ||
                                    type == "7" ||
                                    type == "3" ||
                                    phone == "$superUser"))
                              Container(
                                width: buttonWidth,
                                child:
                                    SizedBox(), // Placeholder for button column
                              ),
                          ],
                        ),
                      ),
                    ),
                    // Data List
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _getFilteredList().length,
                      itemBuilder: (context, index) {
                        final item = _getFilteredList()[index];
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: InkWell(
                            onTap: () async {
                              if (type == "3" && phone != "$superUser") {
                                if (createRequest_controller
                                            .toStatus[widget.statusKey]! <
                                        3 ||
                                    createRequest_controller
                                            .toStatus[widget.statusKey]! ==
                                        8) {
                                  Get.to(TestRequestCreateTypeThree(
                                      testEachRequest: item));
                                }
                              } else if (type == "4" && phone != "$superUser") {
                                if (createRequest_controller
                                            .toStatus[widget.statusKey]! ==
                                        8 ||
                                    createRequest_controller
                                            .toStatus[widget.statusKey]! !=
                                        3) {
                                  if (item.assigning == phone &&
                                      !item.pathology_done) {
                                    Get.to(TestRequestCreate(
                                        testEachRequest: item));
                                  } else if (item.radiology_assigning ==
                                          phone &&
                                      !item.radiology_done) {
                                    Get.to(TestRequestCreate(
                                        testEachRequest: item));
                                  }
                                }
                              } else {
                                if (type == "7" &&
                                    phone != "$superUser" &&
                                    (createRequest_controller
                                                .toStatus[widget.statusKey]! <
                                            7 ||
                                        createRequest_controller
                                                .toStatus[widget.statusKey] ==
                                            8)) {
                                  Get.to(
                                      TestRequestCreate(testEachRequest: item));
                                } else {
                                  Get.to(
                                      TestRequestCreate(testEachRequest: item));
                                }
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: whiteColor,
                                borderRadius: BorderRadius.circular(DM.p10),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: DM.p8, vertical: DM.p5),
                              margin: EdgeInsets.symmetric(vertical: DM.p5),
                              height: DM.p60,
                              child: Row(
                                children: [
                                  Container(
                                    width: typeWidth,
                                    child: Text(
                                      "${createRequest_controller.typeName[item.type]![0]}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: DM.p12,
                                        color: Color.fromARGB(255, 26, 1, 1),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Container(
                                    width: nameWidth,
                                    child: Text(
                                      "${getFirstName(item.name)}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: DM.p12,
                                        color: Color.fromARGB(255, 26, 1, 1),
                                      ),
                                      softWrap: true,
                                      maxLines: 2,
                                    ),
                                  ),
                                  Container(
                                    width: invoiceWidth,
                                    child: Text(
                                      "#${item.invoice_call.toString()}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: DM.p12,
                                        color: Color.fromARGB(255, 26, 1, 1),
                                      ),
                                      softWrap: true,
                                      maxLines: 2,
                                    ),
                                  ),
                                  Container(
                                    width: dateWidth,
                                    child: Text(
                                      DateFormat('dd-MMM HH:mm').format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            item.dateofcreated),
                                      ),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: DM.p12,
                                        color: Color.fromARGB(255, 26, 1, 1),
                                      ),
                                      softWrap: true,
                                      maxLines: 2,
                                    ),
                                  ),

                                    Container(
                                      width: changedByWidth,
                                      child: showChangedByColumn
                                          ? Text(
                                        item.last_modifier ?? item.prepared_by ?? "N/A",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: DM.p12,
                                          color: Color.fromARGB(255, 26, 1, 1),
                                        ),
                                        softWrap: true,
                                        maxLines: 2,
                                      )
                                          : SizedBox.shrink(), // Keeps the width space even when hidden
                                    ),
                                  if (widget.isButton &&
                                      (createRequest_controller
                                                  .toStatus[widget.statusKey]! <
                                              5 ||
                                          type == "7" ||
                                          type == "3" ||
                                          phone == "$superUser"))
                                    Container(
                                      width: buttonWidth,
                                      child: MaterialButton(
                                        onPressed: () async {
                                          await _updateStatus(item);
                                        },
                                        height: DM.p40,
                                        shape: const StadiumBorder(),
                                        color: appTheme,
                                        child: Text(
                                          "Done",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: fullWhiteColor,
                                            fontSize: DM.p10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              )
            : Center(
                child: Padding(
                  padding: EdgeInsets.all(DM.p16),
                  child: Container(
                    height: DM.screenHeight * 0.65,
                    margin: EdgeInsets.symmetric(vertical: DM.p16),
                    child: Center(
                      child: Text(
                        "Request list empty ",
                        style: TextStyle(fontWeight: FontWeight.w400, fontSize: DM.p25, color: appTheme),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  String getMonthName(int month) {
    const List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }

  List<String> getLastThreeMonthTestRequestPaths() {
    List<String> paths = [];
    DateTime now = DateTime.now();
    for (int i = 0; i < 3; i++) {
      DateTime date = DateTime(now.year, now.month - i, 1);
      String year = date.year.toString();
      String month = getMonthName(date.month);
      paths.add("$database_name/testRequest/$year/$month");
    }
    return paths;
  }
}
