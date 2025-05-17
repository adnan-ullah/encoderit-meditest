import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthcare_homelab/constants/api.dart';
import 'package:healthcare_homelab/constants/colors.dart';
import 'package:healthcare_homelab/state_programming/CreateRequestController.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants/app_info.dart';
import '../../../db/models/TestDataRequest.dart';
import '../../../responsives/dimensions.dart';
import '../../pages/LoginScreen.dart';

class AdminSuperReport extends StatefulWidget {
  const AdminSuperReport({super.key});

  @override
  State<AdminSuperReport> createState() => _AdminSuperReportState();
}

class _AdminSuperReportState extends State<AdminSuperReport> {
  final CreateRequestController createRequestController = Get.put(CreateRequestController());
  final TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  String? referrerCode;
  String? commission;
  int startDatetime = DateTime(DateTime.now().year, DateTime.now().month, 1, 0, 0, 1).millisecondsSinceEpoch;
  int endDatetime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59, 59).millisecondsSinceEpoch;
  double totalCost = 0;
  double totalTestCost = 0;
  double totalDiscount = 0;
  final List<TestDataRequest> _newTestRequestList = [];
  final List<TestDataRequest> _allRequestListAdmin = [];

  // Show or hide loading dialog
  void _showLoading(bool show) {
    if (show == isLoading) return;
    setState(() {
      isLoading = show;
    });
    if (show) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          child: Container(
            height: DM.p120,
            padding: EdgeInsets.all(DM.p16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: appTheme),
                SizedBox(width: DM.p10),
                Text(
                  "Loading, please wait...",
                  style: TextStyle(color: appTheme),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  // Generate list of year/month paths to query based on date range
  List<String> _getYearMonthPaths() {
    final start = DateTime.fromMillisecondsSinceEpoch(startDatetime);
    final end = DateTime.fromMillisecondsSinceEpoch(endDatetime);
    final paths = <String>[];
    final formatter = DateFormat('MMMM');

    var current = DateTime(start.year, start.month, 1);
    while (current.isBefore(end) || (current.year == end.year && current.month == end.month)) {
      final year = current.year;
      final monthName = formatter.format(current);
      paths.add("$database_name/testRequest/$year/$monthName");
      current = DateTime(current.year, current.month + 1, 1);
    }
    return paths;
  }

  // Fetch data from Firebase for all year/month paths
  Future<void> _fetchData() async {
    _allRequestListAdmin.clear();
    _newTestRequestList.clear();
    totalCost = 0;
    totalTestCost = 0;
    totalDiscount = 0;

    final prefs = await SharedPreferences.getInstance();
    commission = prefs.getString("commission");
    referrerCode = prefs.getString("referrer_code");

    final paths = _getYearMonthPaths();
    final ref = FirebaseDatabase.instance;

    try {
      for (var path in paths) {
        final snapshot = await ref.ref(path).get();
        if (snapshot.exists) {
          for (var ds in snapshot.children) {
            for (var dsLater in ds.children) {
              try {
                final data = TestDataRequest.fromJson(json.decode(jsonEncode(dsLater.value)));
                if (!_allRequestListAdmin.any((r) => r.id == data.id && r.mobile == data.mobile)) {
                  _allRequestListAdmin.add(data);
                }
              } catch (e) {
                print("Error parsing TestDataRequest: $e for JSON: ${jsonEncode(dsLater.value)}");
              }
            }
          }
        }
      }
      await _filterData();
    } catch (e) {
      print("Error fetching test requests: $e");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // Filter data by referrer and date range, calculate metrics
  Future<void> _filterData() async {
    _newTestRequestList.clear();
    totalCost = 0;
    totalTestCost = 0;
    totalDiscount = 0;

    if (searchController.text.isNotEmpty) {
      final input = searchController.text.toLowerCase();

      _newTestRequestList.addAll(
        _allRequestListAdmin.where(
              (element) =>
          (element.name?.toLowerCase().contains(input) == true ||
              element.mobile?.contains(searchController.text) == true) &&
              startDatetime <= (element.dateofcreated ?? 0) &&
              (element.dateofcreated ?? 0) <= endDatetime,
        ),
      );
    }
    else {
      _newTestRequestList.addAll(
        _allRequestListAdmin.where(
              (element) =>
          startDatetime <= (element.dateofcreated ?? 0) &&
              (element.dateofcreated ?? 0) <= endDatetime,
        ),
      );
    }

    for (var e in _newTestRequestList) {
      if (e.totalprice != null && e.totalprice.toString().isNotEmpty) {
        totalCost += e.totalprice!;
      }
      if (e.test_item_cost != null && e.test_item_cost.toString().isNotEmpty) {
        totalTestCost += e.test_item_cost!;
      }
      if (e.total_discount != null && e.total_discount.toString().isNotEmpty) {
        totalDiscount += e.total_discount!;
      }
    }

    if (mounted) setState(() {});
  }

  // Request storage permissions
  Future<bool> _getStoragePermission() async {
    final status = await Permission.storage.request();
    final status2 = await Permission.manageExternalStorage.request();
    if (status.isGranted && status2.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied || status2.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }
    print('Permission Denied');
    return false;
  }

  // Remove a request from Firebase using the year/month structure and update UI
  Future<void> _removeRequestFromFirebase(TestDataRequest testReq) async {
    if (testReq.dateofcreated == null || testReq.dateofcreated == 0) {
      print("Error: Invalid dateofcreated for request ${testReq.id}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cannot delete request: Invalid creation date")),
      );
      Get.back();
      return;
    }

    try {
      final date = DateTime.fromMillisecondsSinceEpoch(testReq.dateofcreated!);
      final year = date.year;
      final monthName = DateFormat('MMMM').format(date);
      final path = "$database_name/testRequest/$year/$monthName/${testReq.mobile}/${testReq.id}";
      final ref = FirebaseDatabase.instance.ref(path);
      await ref.remove();
      _allRequestListAdmin.removeWhere((r) => r.id == testReq.id && r.mobile == testReq.mobile);
      await _filterData();
      Get.back();
    } catch (e) {
      print("Error deleting request ${testReq.id}: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete request: $e")),
      );
      Get.back();
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, _fetchData);
  }

  @override
  void dispose() {
    searchController.dispose();
    if (isLoading) {
      Navigator.pop(context);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: secondaryColor,
      appBar: AppBar(
        backgroundColor: appTheme,
        title: Text(
          "Report",
          style: TextStyle(color: secondaryColor, fontSize: DM.p30),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: DM.p8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Referrer code input
            Padding(
              padding: EdgeInsets.all(DM.p10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: DM.p70,
                    child: Text(
                      "Search",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: DM.p14,
                        color: blackFontColor,
                      ),
                    ),
                  ),
                  SizedBox(width: DM.p5),
                  Text(":"),
                  SizedBox(width: DM.p10),
                  Flexible(
                    child: Container(
                      height: DM.p50,
                      child: TextFormField(
                        keyboardType: TextInputType.name,
                        controller: searchController,
                        onChanged: (value) => _filterData(),
                        decoration: InputDecoration(
                          errorStyle: TextStyle(fontSize: DM.p9),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: DM.p1, color: appTheme),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: DM.p1, color: appTheme),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "0",
                          hintStyle: TextStyle(color: Colors.grey, fontSize: DM.p14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Date filter buttons
            Padding(
              padding: EdgeInsets.all(DM.p5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Container(
                      height: DM.p45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appTheme,
                          elevation: 0,
                        ),
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.fromMillisecondsSinceEpoch(startDatetime),
                            firstDate: DateTime(2022, 11),
                            lastDate: DateTime(2030, 7),
                          );
                          if (picked != null) {
                            setState(() {
                              startDatetime = DateTime(picked.year, picked.month, picked.day, 0, 0, 1).millisecondsSinceEpoch;
                              _fetchData();
                            });
                          }
                        },
                        child: Text(
                          "First: ${DateFormat.yMMMd().format(DateTime.fromMillisecondsSinceEpoch(startDatetime))}",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: DM.p12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: DM.p15),
                  Flexible(
                    child: Container(
                      height: DM.p45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appTheme,
                          elevation: 0,
                        ),
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.fromMillisecondsSinceEpoch(endDatetime),
                            firstDate: DateTime(2022, 11),
                            lastDate: DateTime(2030, 7),
                          );
                          if (picked != null) {
                            setState(() {
                              endDatetime = DateTime(picked.year, picked.month, picked.day, 23, 59, 59).millisecondsSinceEpoch;
                              _fetchData();
                            });
                          }
                        },
                        child: Text(
                          "Last: ${DateFormat.yMMMd().format(DateTime.fromMillisecondsSinceEpoch(endDatetime))}",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: DM.p12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: DM.p10),
            // Request list
            _newTestRequestList.isNotEmpty
                ? Container(
              height: DM.screenHeight * 0.62,
              margin: EdgeInsets.symmetric(horizontal: DM.p5),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row
                      Container(
                        height: DM.p50,
                        child: Row(
                          children: [
                            Container(
                              width: DM.p80,
                              child: Text(
                                "Invoice Call",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: DM.p10,
                                  color: Color.fromARGB(255, 26, 1, 1),
                                ),
                              ),
                            ),
                            Container(
                              width: DM.p60,
                              child: Text(
                                "Total Cost",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: DM.p10,
                                  color: Color.fromARGB(255, 26, 1, 1),
                                ),
                              ),
                            ),
                            Container(
                              width: DM.p60,
                              child: Text(
                                "Test Cost",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: DM.p10,
                                  color: Color.fromARGB(255, 26, 1, 1),
                                ),
                              ),
                            ),
                            Container(
                              width: DM.p70,
                              child: Text(
                                "Total Discount",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: DM.p10,
                                  color: Color.fromARGB(255, 26, 1, 1),
                                ),
                              ),
                            ),
                            Container(
                              width: DM.p60,
                              child: Text(
                                "Status",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: DM.p10,
                                  color: Color.fromARGB(255, 26, 1, 1),
                                ),
                              ),
                            ),
                            Container(width: DM.p80),
                          ],
                        ),
                      ),
                      Divider(thickness: DM.p2, color: Colors.black),
                      // Request rows
                      Expanded(
                        child: Container(
                          height: DM.screenHeight * 0.50,
                          width: DM.screenWidth * 1.3,
                          child: ListView.builder(
                            itemCount: _newTestRequestList.length,
                            itemBuilder: (context, index) {
                              final request = _newTestRequestList[index];
                              return Container(
                                decoration: BoxDecoration(
                                  color: whiteColor,
                                  borderRadius: BorderRadius.circular(DM.p10),
                                ),
                                margin: EdgeInsets.symmetric(vertical: DM.p5),
                                height: DM.p60,
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: DM.p80,
                                      child: Text(
                                        "#${request.invoice_call ?? 'N/A'}",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: DM.p10,
                                          color: Color.fromARGB(255, 26, 1, 1),
                                        ),
                                      ),
                                    ),
                                    request.teststatus != 1
                                        ? SizedBox(
                                      width: DM.p60,
                                      child: Text(
                                        "${request.totalprice ?? 'N/A'}",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: DM.p10,
                                          color: Color.fromARGB(255, 26, 1, 1),
                                        ),
                                      ),
                                    )
                                        : SizedBox(
                                      width: DM.p60,
                                      child: Text(
                                        "Processing",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: DM.p10,
                                          color: Color.fromARGB(255, 26, 1, 1),
                                        ),
                                      ),
                                    ),
                                    request.teststatus != 1
                                        ? SizedBox(
                                      width: DM.p60,
                                      child: Text(
                                        "${request.test_item_cost ?? 'N/A'}",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: DM.p10,
                                          color: Color.fromARGB(255, 26, 1, 1),
                                        ),
                                      ),
                                    )
                                        : SizedBox(
                                      width: DM.p60,
                                      child: Text(
                                        "Processing",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: DM.p10,
                                          color: Color.fromARGB(255, 26, 1, 1),
                                        ),
                                      ),
                                    ),
                                    request.teststatus != 1
                                        ? SizedBox(
                                      width: DM.p70,
                                      child: Text(
                                        "${request.total_discount ?? 'N/A'}",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: DM.p10,
                                          color: Color.fromARGB(255, 26, 1, 1),
                                        ),
                                      ),
                                    )
                                        : SizedBox(
                                      width: DM.p70,
                                      child: Text(
                                        "Processing",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: DM.p10,
                                          color: Color.fromARGB(255, 26, 1, 1),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: DM.p60,
                                      child: Text(
                                        createRequestController.status[request.teststatus] ?? 'Unknown',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: DM.p10,
                                          color: Color.fromARGB(255, 26, 1, 1),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: DM.p60,
                                      margin: EdgeInsets.only(right: DM.p5),
                                      child: IconButton(
                                        color: appTheme,
                                        icon: Icon(
                                          CupertinoIcons.xmark_circle_fill,
                                          size: DM.p20,
                                        ),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => Scaffold(
                                              backgroundColor: Colors.transparent,
                                              body: Center(
                                                child: Container(
                                                  margin: EdgeInsets.all(DM.p10),
                                                  height: DM.p200,
                                                  color: secondaryColor,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Container(
                                                        padding: EdgeInsets.all(16),
                                                        margin: EdgeInsets.all(16),
                                                        child: Text(
                                                          "Are you sure you want to delete #${request.invoice_call}?",
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.w400,
                                                            fontSize: DM.p20,
                                                            color: Color.fromARGB(255, 26, 1, 1),
                                                          ),
                                                        ),
                                                      ),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Container(
                                                            margin: EdgeInsets.symmetric(horizontal: DM.p20, vertical: DM.p10),
                                                            child: MaterialButton(
                                                              onPressed: () => Get.back(),
                                                              height: DM.p40,
                                                              minWidth: DM.p120,
                                                              shape: const StadiumBorder(),
                                                              color: appTheme,
                                                              child: Text(
                                                                "Cancel",
                                                                style: TextStyle(
                                                                  color: fullWhiteColor,
                                                                  fontSize: DM.p15,
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            margin: EdgeInsets.symmetric(horizontal: DM.p20, vertical: DM.p10),
                                                            child: MaterialButton(
                                                              onPressed: () async {
                                                                if (await chechkingInternet()) {
                                                                  await _removeRequestFromFirebase(request);
                                                                }
                                                              },
                                                              height: DM.p40,
                                                              minWidth: DM.p120,
                                                              shape: const StadiumBorder(),
                                                              color: appTheme,
                                                              child: Text(
                                                                "Yes",
                                                                style: TextStyle(
                                                                  color: fullWhiteColor,
                                                                  fontSize: DM.p15,
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
                : Container(
              height: DM.screenHeight * 0.50,
              margin: EdgeInsets.symmetric(vertical: DM.p16),
              child: Center(
                child: Text(
                  "Request list empty",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: DM.p25,
                    color: appTheme,
                  ),
                ),
              ),
            ),
            // Summary metrics
            Container(
              margin: EdgeInsets.only(right: DM.p10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Divider(thickness: DM.p1, color: blackFontColor),
                  Text(
                    "Total Invoice Quantity: ${_newTestRequestList.length}",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: DM.p15,
                      color: Color.fromARGB(255, 26, 1, 1),
                    ),
                  ),
                  Text(
                    "Total Cost: $totalCost",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: DM.p15,
                      color: Color.fromARGB(255, 26, 1, 1),
                    ),
                  ),
                  Text(
                    "Total Test Cost: $totalTestCost",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: DM.p15,
                      color: Color.fromARGB(255, 26, 1, 1),
                    ),
                  ),
                  Text(
                    "Total Discount: $totalDiscount",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: DM.p15,
                      color: Color.fromARGB(255, 26, 1, 1),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}