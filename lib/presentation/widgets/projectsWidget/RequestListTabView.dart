import 'dart:async';
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

  const RequestListTabView({
    super.key,
    required this.statusKey,
    required this.isButton,
  });

  @override
  State<RequestListTabView> createState() => _RequestListTabViewState();
}

class _RequestListTabViewState extends State<RequestListTabView> with AutomaticKeepAliveClientMixin {
  CreateRequestController createRequestController = Get.put(CreateRequestController());
  var testStatusRequestList = <TestDataRequest>[];
  var isLoading = false;
  var type;
  var phone;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final FocusNode _searchFocusNode = FocusNode();
  StreamSubscription<DatabaseEvent>? _notificationSubscription;
  List<TestDataRequest> _newTestRequestList = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      getStatusData(context);
      _setupNotificationListener(context);
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _notificationSubscription?.cancel();
    super.dispose();
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
      pathology_payment_date: requestItem.pathology_payment_date,
      advance_payment_date: requestItem.advance_payment_date,
      pathology_done: requestItem.pathology_done,
      radiology_done: requestItem.radiology_done,
      assigning: requestItem.assigning,
      radiology_assigning: requestItem.radiology_assigning,
      assigning_commission: requestItem.assigning_commission,
      radiology_assigning_commission: requestItem.radiology_assigning_commission,
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
    setState(() {
      isLoading = true;
    });
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
    setState(() {
      isLoading = false;
    });
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
          if (widget.statusKey == "PRECOLLECTED" || widget.statusKey == "COLLECTED") {
            tempList.add(testData);
          } else {
            tempList.add(testData);
          }
        } else {
          tempList.add(testData);
        }
      }
    }
    tempList.sort((a, b) => (b.lastupdate ?? 0).compareTo(a.lastupdate ?? 0));
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

  Future<void> _setupNotificationListener(BuildContext context) async {
    FirebaseDatabase.instance.setPersistenceEnabled(true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? phone = prefs.getString("phoneNumber");
    String? type = prefs.getString("type");

    List<String> lastThreeMonthsPaths = getLastThreeMonthTestRequestPaths();
    for (String path in lastThreeMonthsPaths) {
      DatabaseReference dbRefTestModel = FirebaseDatabase.instance.ref(path);
      dbRefTestModel.keepSynced(true);

      _notificationSubscription = dbRefTestModel.onChildAdded.listen((event) async {
        AdminUserModel testData =
        AdminUserModel.fromJson(json.decode(jsonEncode(event.snapshot.value)));
        if (testData.phone == phone || phone == "$superUser") {
          if (type == "1" || type == "7" || phone == "$superUser") {
            String notificationKey = "${event.snapshot.key}_${testData.phone}";
            bool isNotified = prefs.getBool(notificationKey) ?? false;
            if (!isNotified) {
              createPlantFoodNotification();
              showNotification(context);
              await prefs.setBool(notificationKey, true);
            }
          }
        }
      });

      _notificationSubscription = dbRefTestModel.onChildChanged.listen((event) async {
        AdminUserModel testData =
        AdminUserModel.fromJson(json.decode(jsonEncode(event.snapshot.value)));
        if (testData.phone == phone || phone == "$superUser") {
          if (type == "1" || type == "7" || phone == "$superUser") {
            String notificationKey = "${event.snapshot.key}_${testData.phone}_changed";
            bool isNotified = prefs.getBool(notificationKey) ?? false;
            if (!isNotified) {
              createPlantFoodNotification();
              showNotification(context);
              await prefs.setBool(notificationKey, true);
            }
          }
        }
      });
    }
  }

  String getFirstName(String name) {
    List<String> parts = name.trim().split(RegExp(r'\s+'));

    if (parts.isEmpty) return '';

    final honorifics = {'Mr', 'Mr.', 'Mrs', 'Mrs.', 'Md', 'Md.', 'Ms', 'Ms.'};

    if (parts.length >= 2 && honorifics.contains(parts.first)) {
      return parts[1];
    }

    return parts.first;
  }

  void tabStatusList() {
    if (!mounted) return;
    setState(() {
      _newTestRequestList.clear();
      _newTestRequestList.addAll(
        testStatusRequestList
            .where((p0) =>
        createRequestController.status[p0.teststatus].toString() ==
            widget.statusKey.toString())
            .toList(),
      );
    });
  }

  List<TestDataRequest> _getFilteredList() {
    if (_searchQuery.isEmpty) {
      return _newTestRequestList;
    }
    return _newTestRequestList.where((item) {
      final name = item.name?.toLowerCase() ?? '';
      final phone = item.mobile ?? '';
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || phone.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    bool showChangedByColumn =
        (createRequestController.toStatus[widget.statusKey]! <= 6 ||
            createRequestController.toStatus[widget.statusKey] == 8) &&
            _newTestRequestList.any((item) =>
            item.prepared_by != null || item.last_modifier != null);

    const double typeWidth = 40.0;
    const double nameWidth = 70.0;
    const double invoiceWidth = 90.0;
    const double dateWidth = 80.0;
    const double changedByWidth = 80.0;
    const double buttonWidth = 80.0;

    return SafeArea(
      child: isLoading
          ?  Center(
        child: CircularProgressIndicator(
          color: appTheme,
        ),
      )
          : SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          children: [
            // Search Box
            Padding(
              padding: EdgeInsets.only(top: DM.p16, right: DM.p8, left: DM.p8),
              child: Container(
                height: DM.p40,
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(DM.p10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: DM.p8,
                      offset:  Offset(0, DM.p2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Search by Invoice ID or Name',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: DM.p14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(DM.p10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: whiteColor,
                    prefixIcon: Icon(
                      Icons.search,
                      size: DM.p20,
                      color: _searchFocusNode.hasFocus ? appTheme : Colors.grey.shade600,
                    ),
                    contentPadding:  EdgeInsets.symmetric(vertical: DM.p8, horizontal: DM.p12),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                      icon: Icon(Icons.clear, size: DM.p20, color: Colors.grey.shade600),
                      onPressed: () {
                        _searchController.clear();
                        _searchFocusNode.unfocus();
                      },
                    )
                        : null,
                  ),
                  style:  TextStyle(fontSize: DM.p14, color: blackFontColor),
                  onTap: () {
                    setState(() {});
                  },
                ),
              ),
            ),
            // Request List
            _getFilteredList().isNotEmpty
                ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  // Header Row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      padding:  EdgeInsets.symmetric(
                          horizontal: DM.p8, vertical: DM.p8),
                      decoration:  BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: Colors.black, width: DM.p2)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: typeWidth,
                            child:  Text(
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
                            child:  Text(
                              "Name",
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: DM.p14,
                                color: Color.fromARGB(255, 26, 1, 1),
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),  SizedBox(width: DM.p4,),
                          Container(
                            width: invoiceWidth,
                            child:  Text(
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
                            child:  Text(
                              "Date",
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: DM.p14,
                                color: Color.fromARGB(255, 26, 1, 1),
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),  SizedBox(width: DM.p4,),
                          Container(
                            width: changedByWidth,
                            child: showChangedByColumn
                                ?  Text(
                              "Changed by",
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: DM.p14,
                                color: Color.fromARGB(255, 26, 1, 1),
                              ),
                              textAlign: TextAlign.left,
                            )
                                :  SizedBox.shrink(),
                          ),
                          if (widget.isButton &&
                              (createRequestController
                                  .toStatus[widget.statusKey]! <
                                  5 ||
                                  type == "7" ||
                                  type == "3" ||
                                  phone == "$superUser"))
                            Container(
                              width: buttonWidth,
                              child:  SizedBox(),
                            ),
                        ],
                      ),
                    ),
                  ),
                  // Data List
                  ListView.builder(
                    shrinkWrap: true,
                    physics:  NeverScrollableScrollPhysics(),
                    itemCount: _getFilteredList().length,
                    itemBuilder: (context, index) {
                      final item = _getFilteredList()[index];
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: InkWell(
                          onTap: () async {
                            if (type == "3" && phone != "$superUser") {
                              if (createRequestController
                                  .toStatus[widget.statusKey]! <
                                  3 ||
                                  createRequestController
                                      .toStatus[widget.statusKey]! ==
                                      8) {
                                Get.to(TestRequestCreateTypeThree(
                                    testEachRequest: item));
                              }
                            } else if (type == "4" && phone != "$superUser") {
                              if (createRequestController
                                  .toStatus[widget.statusKey]! ==
                                  8 ||
                                  createRequestController
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
                                  (createRequestController
                                      .toStatus[widget.statusKey]! <
                                      7 ||
                                      createRequestController
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
                            padding:  EdgeInsets.symmetric(
                                horizontal: DM.p8, vertical: DM.p5),
                            margin:  EdgeInsets.symmetric(vertical: DM.p5),
                            height: DM.p60,
                            child: Row(
                              children: [
                                Container(
                                  width: typeWidth,
                                  child: Text(
                                    "${createRequestController.typeName[item.type]![0]}",
                                    style:  TextStyle(
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
                                    getFirstName(item.name),
                                    style:  TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: DM.p12,
                                      color: Color.fromARGB(255, 26, 1, 1),
                                    ),
                                    softWrap: true,
                                    maxLines: 2,
                                  ),
                                ),  SizedBox(width: DM.p4,),
                                Container(
                                  width: invoiceWidth,
                                  child: Text(
                                    "#${item.invoice_call.toString()}",
                                    style:  TextStyle(
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
                                    style:  TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: DM.p12,
                                      color: Color.fromARGB(255, 26, 1, 1),
                                    ),
                                    softWrap: true,
                                    maxLines: 2,
                                  ),
                                ),  SizedBox(width: DM.p4,),
                                Container(
                                  width: changedByWidth,
                                  child: showChangedByColumn
                                      ? Text(
                                    item.last_modifier ??
                                        item.prepared_by ??
                                        "N/A",
                                    style:  TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: DM.p12,
                                      color: Color.fromARGB(255, 26, 1, 1),
                                    ),
                                    softWrap: true,
                                    maxLines: 2,
                                  )
                                      : const SizedBox.shrink(),
                                ),
                                if (widget.isButton &&
                                    (createRequestController
                                        .toStatus[widget.statusKey]! <
                                        5 ||
                                        type == "7" ||
                                        (type == "3" &&
                                            item.due_amount != null &&
                                            item.due_amount == 0) ||
                                        phone == "$superUser"))
                                  Container(
                                    width: buttonWidth,
                                    child: MaterialButton(
                                      onPressed: () async {
                                        await _updateStatus(item);
                                      },
                                      height: DM.p40,
                                      shape:  StadiumBorder(),
                                      color: appTheme,
                                      child:  Text(
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
                padding:  EdgeInsets.all(DM.p16),
                child: Container(
                  height: DM.screenHeight * 0.65,
                  margin:  EdgeInsets.symmetric(vertical: DM.p16),
                  child:  Center(
                    child: Text(
                      "Request list empty ",
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: DM.p25,
                          color: appTheme),
                    ),
                  ),
                ),
              ),
            ),
          ],
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