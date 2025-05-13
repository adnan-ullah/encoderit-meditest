import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthcare_homelab/constants/api.dart';
import 'package:healthcare_homelab/constants/colors.dart';
import 'package:healthcare_homelab/db/models/AdminUserModel.dart';
import 'package:healthcare_homelab/db/models/TestDataRequest.dart';
import 'package:healthcare_homelab/responsives/dimensions.dart';
import 'package:healthcare_homelab/state_programming/CreateRequestController.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/app_info.dart';

class ShareholderReportList extends StatefulWidget {
  const ShareholderReportList({super.key});

  @override
  State<ShareholderReportList> createState() => _ShareholderReportListState();
}

class _ShareholderReportListState extends State<ShareholderReportList> {
  final controller = Get.put(CreateRequestController());
  bool isLoading = false;
  bool _isDialogOpen = false;
  String phone = "";
  double percentage = 0;
  List<TestDataRequest> requests = [];
  int totalQuantity = 0;
  double totalSellWithoutDue = 0,
      totalCost = 0,
      companyEarning = 0,
      reporterEarning = 0;

  // Date filter variables
  int startDate =
      DateTime(DateTime.now().year, DateTime.now().month, 1, 0, 0, 1)
          .millisecondsSinceEpoch;
  int endDate = DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, 23, 59, 59)
      .millisecondsSinceEpoch;

  final GlobalKey _dialogKey = GlobalKey();

  void _showLoading(bool show) {
    if (show == isLoading || (show && _isDialogOpen)) return;
    setState(() {
      isLoading = show;
      _isDialogOpen = show;
    });
    if (show) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Dialog(
          key: _dialogKey,
          child: Container(
            height: DM.p120,
            padding: EdgeInsets.all(DM.p16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: appTheme),
                SizedBox(width: DM.p10),
                Text("Loading...", style: TextStyle(color: appTheme)),
              ],
            ),
          ),
        ),
      );
    } else {
      while (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      _isDialogOpen = false;
    }
  }

  Future<void> _fetchPercentage() async {
    final prefs = await SharedPreferences.getInstance();
    phone = prefs.getString('phoneNumber') ?? "";
    if (phone.isEmpty) {
      print("Error: No phone number in SharedPreferences");
      return;
    }
    final ref = FirebaseDatabase.instance.ref("$adminUserApi/$phone");
    final snapshot = await ref.get();
    if (snapshot.exists) {
      try {
        final user =
            AdminUserModel.fromJson(json.decode(json.encode(snapshot.value)));
        percentage = double.tryParse(user.percentage ?? "0") ?? 0;
        print("Fetched percentage: $percentage for phone: $phone");
      } catch (e) {
        print("Error parsing AdminUserModel: $e");
      }
    }
  }

  // Generate list of year/month paths to query based on date range
  List<String> _getYearMonthPaths() {
    final start = DateTime.fromMillisecondsSinceEpoch(startDate);
    final end = DateTime.fromMillisecondsSinceEpoch(endDate);
    final paths = <String>[];
    final formatter = DateFormat('MMMM'); // Month name (e.g., January)

    // Iterate through each month in the date range
    var current = DateTime(start.year, start.month, 1);
    while (current.isBefore(end) ||
        (current.year == end.year && current.month == end.month)) {
      final year = current.year;
      final monthName = formatter.format(current);
      paths.add("$database_name/testRequest/$year/$monthName");
      // Move to next month
      current = DateTime(current.year, current.month + 1, 1);
    }

    return paths;
  }

  Future<void> _fetchData() async {
    // _showLoading(true);
    await _fetchPercentage();

    requests.clear();
    totalQuantity = 0;
    totalSellWithoutDue = 0;
    totalCost = 0;
    companyEarning = 0;

    final paths = _getYearMonthPaths();
    final ref = FirebaseDatabase.instance;

    try {
      // Fetch data for all paths
      for (var path in paths) {
        final snapshot = await ref.ref(path).get();
        if (snapshot.exists) {
          _processSnapshot(snapshot);
        }
      }
    } catch (e) {
      print("Error fetching test requests: $e");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _processSnapshot(DataSnapshot snapshot) {
    for (var ds in snapshot.children) {
      for (var dsLater in ds.children) {
        try {
          final data =
              TestDataRequest.fromJson(json.decode(json.encode(dsLater.value)));
          if (data.dateofcreated == null || data.teststatus != 6) {
            continue;
          }
          if (startDate <= data.dateofcreated! &&
              data.dateofcreated! <= endDate) {
            // Avoid duplicate requests by checking if already in list
            if (!requests
                .any((r) => r.id == data.id && r.mobile == data.mobile)) {
              requests.add(data);
              totalQuantity++;
              final payable = data.total_payable ?? 0;
              final due = data.due_amount ?? 0;
              if (data.is_paid == true || due == 0)
                totalSellWithoutDue += payable;
              totalCost += data.totalprice ?? 0;
              companyEarning = totalSellWithoutDue - totalCost;
            }
          }
        } catch (e) {
          print(
              "Error parsing TestDataRequest: $e for JSON: ${json.encode(dsLater.value)}");
        }
      }
    }

    reporterEarning = companyEarning * (percentage / 100);
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, _fetchData);
  }

  @override
  void dispose() {
    if (_isDialogOpen) {
      while (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        backgroundColor: appTheme,
        title: Text(
          "Shareholder Report",
          style: TextStyle(color: secondaryColor, fontSize: DM.p30),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Date filter buttons
            Padding(
              padding: EdgeInsets.all(DM.p15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      height: DM.p60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appTheme,
                          elevation: 0,
                        ),
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate:
                                DateTime.fromMillisecondsSinceEpoch(startDate),
                            firstDate: DateTime(2022, 11),
                            lastDate: DateTime(2030, 7),
                          );
                          if (picked != null) {
                            setState(() {
                              startDate = DateTime(picked.year, picked.month,
                                      picked.day, 0, 0, 1)
                                  .millisecondsSinceEpoch;
                              _fetchData();
                            });
                          }
                        },
                        child: Text(
                          "First: ${DateFormat.yMMMd().format(DateTime.fromMillisecondsSinceEpoch(startDate))}",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: DM.p15),
                  Flexible(
                    child: Container(
                      height: DM.p60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appTheme,
                          elevation: 0,
                        ),
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate:
                                DateTime.fromMillisecondsSinceEpoch(endDate),
                            firstDate: DateTime(2022, 11),
                            lastDate: DateTime(2030, 7),
                          );
                          if (picked != null) {
                            setState(() {
                              endDate = DateTime(picked.year, picked.month,
                                      picked.day, 23, 59, 59)
                                  .millisecondsSinceEpoch;
                              _fetchData();
                            });
                          }
                        },
                        child: Text(
                          "Last: ${DateFormat.yMMMd().format(DateTime.fromMillisecondsSinceEpoch(endDate))}",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: DM.screenHeight * 0.62,
              margin: EdgeInsets.symmetric(horizontal: DM.p10, vertical: DM.p5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderRow(),
                  Expanded(
                    child: isLoading
                        ? const SizedBox()
                        : Container(
                            width: DM.screenWidth - DM.p20,
                            child: requests.isNotEmpty
                                ? Column(
                                    children: [
                                      Divider(
                                          thickness: DM.p2,
                                          color: Colors.black),
                                      Expanded(
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: requests.length,
                                          itemBuilder: (_, index) =>
                                              _buildRequestRow(index),
                                        ),
                                      ),
                                    ],
                                  )
                                : Container(
                                    height: DM.screenHeight * 0.65,
                                    margin:
                                        EdgeInsets.symmetric(vertical: DM.p16),
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
                          ),
                  ),
                ],
              ),
            ),
            _buildSummaryRow("Total Collection Quantity = $totalQuantity"),
            _buildSummaryRow("Total Sell (Without Due) = $totalSellWithoutDue"),
            _buildSummaryRow("Total Cost = $totalCost"),
            _buildSummaryRow("Company Total Earning = $companyEarning"),
            _buildSummaryRow(
                "Reporter Earning ($percentage%) = $reporterEarning"),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Container(
      height: DM.p50,
      width: DM.screenWidth - DM.p20,
      padding: EdgeInsets.symmetric(horizontal: DM.p5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: ["Invoice Id", "Name", "Date", "Sell"]
            .map((text) => Expanded(
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: DM.p12,
                      color: Color.fromARGB(255, 26, 1, 1),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildRequestRow(int index) {
    final request = requests[index];
    return Container(
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(DM.p10),
      ),
      margin: EdgeInsets.symmetric(vertical: DM.p5, horizontal: DM.p5),
      height: DM.p60,
      padding: EdgeInsets.symmetric(horizontal: DM.p5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          request.invoice_call?.toString() ?? "N/A",
          request.name ?? "N/A",
          request.dateofcreated == null
              ? "N/A"
              : DateFormat('dd-MMM-yyyy').format(
                  DateTime.fromMillisecondsSinceEpoch(request.dateofcreated!)),
          "${request.total_payable ?? 0}",
        ]
            .asMap()
            .entries
            .map((entry) => Expanded(
                  child: Text(
                    entry.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: DM.p12,
                      color: Color.fromARGB(255, 26, 1, 1),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildSummaryRow(String text) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: DM.p10, vertical: DM.p5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(thickness: DM.p1, color: blackFontColor),
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: DM.p15,
              color: Color.fromARGB(255, 26, 1, 1),
            ),
          ),
        ],
      ),
    );
  }
}
