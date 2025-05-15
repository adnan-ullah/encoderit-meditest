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
import '../../../db/models/CostModel.dart';

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
  List<TestDataRequest> sellRequests = [];
  List<CostModel> costRequests = [];
  int totalSellQuantity = 0;
  int totalCostQuantity = 0;
  double totalSellWithoutDue = 0;
  double totalCost = 0;
  double companyEarning = 0;
  double reporterEarning = 0;

  DateTime selectedMonth =
      DateTime(DateTime.now().year, DateTime.now().month, 1);
  int startDate =
      DateTime(DateTime.now().year, DateTime.now().month, 1, 0, 0, 1)
          .millisecondsSinceEpoch;
  int endDate =
      DateTime(DateTime.now().year, DateTime.now().month + 1, 1, 0, 0, 0, -1)
          .millisecondsSinceEpoch;

  String reportType = 'Sell';

  final GlobalKey _dialogKey = GlobalKey();

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

  List<String> _getYearMonthPaths() {
    final paths = <String>[];
    final formatter = DateFormat('MMMM');
    final year = selectedMonth.year;
    final monthName = formatter.format(selectedMonth);
    paths.add("$database_name/testRequest/$year/$monthName");
    return paths;
  }

  List<String> _getCostYearMonthPaths() {
    final paths = <String>[];
    final formatter = DateFormat('MMMM');
    final year = selectedMonth.year;
    final monthName = formatter.format(selectedMonth);
    paths.add("$database_name/cost/$year/$monthName");
    return paths;
  }

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
    });

    await _fetchPercentage();

    sellRequests.clear();
    costRequests.clear();
    totalSellQuantity = 0;
    totalCostQuantity = 0;
    totalSellWithoutDue = 0;
    totalCost = 0;
    companyEarning = 0;
    reporterEarning = 0;

    final ref = FirebaseDatabase.instance;

    try {
      // Fetch sell data
      final sellPaths = _getYearMonthPaths();
      for (var path in sellPaths) {
        final snapshot = await ref.ref(path).get();
        if (snapshot.exists) {
          _processSellSnapshot(snapshot);
        }
      }

      // Fetch cost data
      final costPaths = _getCostYearMonthPaths();
      for (var path in costPaths) {
        final snapshot = await ref.ref(path).get();
        if (snapshot.exists) {
          _processCostSnapshot(snapshot);
        }
      }

      // Calculate earnings
      companyEarning = totalSellWithoutDue - totalCost;
      reporterEarning = companyEarning * (percentage / 100);
    } catch (e) {
      print("Error fetching data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load data: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _processSellSnapshot(DataSnapshot snapshot) {
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
            if (!sellRequests
                .any((r) => r.id == data.id && r.mobile == data.mobile)) {
              sellRequests.add(data);
              totalSellQuantity++;
              final payable = data.total_payable ?? 0;
              final due = data.due_amount ?? 0;
              if (data.is_paid == true || due == 0) {
                totalSellWithoutDue += payable;
              }
            }
          }
        } catch (e) {
          print(
              "Error parsing TestDataRequest: $e for JSON: ${json.encode(dsLater.value)}");
        }
      }
    }
  }

  void _processCostSnapshot(DataSnapshot snapshot) {
    for (var ds in snapshot.children) {
      try {
        final data = CostModel.fromJson(json.decode(json.encode(ds.value)));
        if (data.voucherDate == null) {
          continue;
        }
        if (startDate <= data.voucherDate! && data.voucherDate! <= endDate) {
          costRequests.add(data);
          totalCostQuantity++;
          totalCost += int.parse(data.totalAmount) ?? 0;
        }
      } catch (e) {
        print("Error parsing CostModel: $e for JSON: ${json.encode(ds.value)}");
      }
    }
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

  Future<void> _showMonthPicker() async {
    final picked = await showDialog<DateTime>(
      context: context,
      builder: (context) => MonthPickerDialog(
        initialDate: selectedMonth,
        firstDate: DateTime(2022, 11),
        lastDate: DateTime(2030, 7),
      ),
    );
    if (picked != null) {
      setState(() {
        selectedMonth = picked;
        startDate = DateTime(picked.year, picked.month, 1, 0, 0, 1)
            .millisecondsSinceEpoch;
        endDate = DateTime(picked.year, picked.month + 1, 1, 0, 0, 0, -1)
            .millisecondsSinceEpoch;
        _fetchData();
      });
    }
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
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Filters
                Padding(
                  padding: EdgeInsets.all(DM.p15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: SizedBox(
                          height: DM.p60,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: appTheme,
                              elevation: 0,
                            ),
                            onPressed: _showMonthPicker,
                            child: Text(
                              "Month: ${DateFormat.yMMM().format(selectedMonth)}",
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: DM.p15),
                      Flexible(
                        child: Container(
                          height: DM.p60,
                          padding: EdgeInsets.symmetric(horizontal: DM.p10),
                          decoration: BoxDecoration(
                            color: appTheme,
                            borderRadius: BorderRadius.circular(DM.p5),
                          ),
                          child: DropdownButton<String>(
                            value: reportType,
                            isExpanded: true,
                            dropdownColor: appTheme,
                            style: const TextStyle(color: Colors.white),
                            underline: const SizedBox(),
                            items: ['Sell', 'Cost'].map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  reportType = value;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // List
                Container(
                  height: DM.screenHeight * 0.62,
                  margin:
                      EdgeInsets.symmetric(horizontal: DM.p10, vertical: DM.p5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderRow(),
                      Expanded(
                        child: isLoading
                            ? const SizedBox()
                            : Container(
                                width: DM.screenWidth - DM.p20,
                                child: (reportType == 'Sell'
                                        ? sellRequests.isNotEmpty
                                        : costRequests.isNotEmpty)
                                    ? Column(
                                        children: [
                                          Divider(
                                              thickness: DM.p2,
                                              color: Colors.black),
                                          Expanded(
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              itemCount: reportType == 'Sell'
                                                  ? sellRequests.length
                                                  : costRequests.length,
                                              itemBuilder: (_, index) =>
                                                  reportType == 'Sell'
                                                      ? _buildSellRequestRow(
                                                          index)
                                                      : _buildCostRequestRow(
                                                          index),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Container(
                                        height: DM.screenHeight * 0.65,
                                        margin: EdgeInsets.symmetric(
                                            vertical: DM.p16),
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
                // Summary
                _buildSummaryRow("Total Sell Quantity: $totalSellQuantity"),
                // _buildSummaryRow("Total Cost Quantity: $totalCostQuantity"),
                _buildSummaryRow(
                    "Total Sell (Without Due): ${NumberFormat.currency(symbol: '', decimalDigits: 2).format(totalSellWithoutDue)}"),
                _buildSummaryRow(
                    "Total Cost: ${NumberFormat.currency(symbol: '', decimalDigits: 2).format(totalCost)}"),
                _buildSummaryRow(
                    "Company Total Earning: ${NumberFormat.currency(symbol: '', decimalDigits: 2).format(companyEarning)}"),
                _buildSummaryRow(
                    "Reporter Earning ($percentage%): ${NumberFormat.currency(symbol: '', decimalDigits: 2).format(reporterEarning)}"),
              ],
            ),
          ),
          if (isLoading)
            Container(
              child: Center(
                child: CircularProgressIndicator(
                  color: appTheme,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    final headers = reportType == 'Sell'
        ? ["Invoice Id", "Name", "Date", "Sell"]
        : ["Date", "Voucher No", "Category", "Amount"];
    return Container(
      height: DM.p50,
      width: DM.screenWidth - DM.p20,
      padding: EdgeInsets.symmetric(horizontal: DM.p5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: headers.map((text) {
          return Expanded(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: DM.p12,
                color: Color.fromARGB(255, 26, 1, 1),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSellRequestRow(int index) {
    final request = sellRequests[index];
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
          NumberFormat.currency(symbol: '', decimalDigits: 2)
              .format(request.total_payable ?? 0),
        ].asMap().entries.map((entry) {
          return Expanded(
            child: Text(
              entry.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: DM.p12,
                color: Color.fromARGB(255, 26, 1, 1),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCostRequestRow(int index) {
    final request = costRequests[index];
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
          request.voucherDate == null
              ? "N/A"
              : DateFormat('dd-MMM-yyyy').format(
                  DateTime.fromMillisecondsSinceEpoch(request.voucherDate!)),
          request.voucherNo ?? "N/A",
          request.category ?? "N/A",
          NumberFormat.currency(symbol: '', decimalDigits: 2)
              .format(int.parse(request.totalAmount) ?? 0),
        ].asMap().entries.map((entry) {
          return Expanded(
            child: Text(
              entry.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: DM.p12,
                color: Color.fromARGB(255, 26, 1, 1),
              ),
            ),
          );
        }).toList(),
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

class MonthPickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const MonthPickerDialog({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  _MonthPickerDialogState createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<MonthPickerDialog> {
  late int selectedYear;
  late int selectedMonth;

  @override
  void initState() {
    super.initState();
    selectedYear = widget.initialDate.year;
    selectedMonth = widget.initialDate.month;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(DM.p16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Select Month",
              style: TextStyle(fontSize: DM.p20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: DM.p16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<int>(
                  value: selectedMonth,
                  items: List.generate(12, (index) => index + 1).map((month) {
                    return DropdownMenuItem(
                      value: month,
                      child:
                          Text(DateFormat.MMMM().format(DateTime(2023, month))),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedMonth = value;
                      });
                    }
                  },
                ),
                SizedBox(width: DM.p16),
                DropdownButton<int>(
                  value: selectedYear,
                  items: List.generate(
                    widget.lastDate.year - widget.firstDate.year + 1,
                    (index) => widget.firstDate.year + index,
                  ).map((year) {
                    return DropdownMenuItem(
                      value: year,
                      child: Text(year.toString()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedYear = value;
                      });
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: DM.p16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                        context, DateTime(selectedYear, selectedMonth, 1));
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
