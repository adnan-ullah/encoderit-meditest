import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:healthcare_homelab/constants/api.dart';
import 'package:healthcare_homelab/constants/app_info.dart';
import 'package:healthcare_homelab/constants/colors.dart';
import 'package:healthcare_homelab/db/models/AdminUserModel.dart';
import 'package:healthcare_homelab/db/models/TestDataRequest.dart';
import 'package:healthcare_homelab/responsives/dimensions.dart';
import 'package:intl/intl.dart';

class CashReportList extends StatefulWidget {
  const CashReportList({super.key});

  @override
  State<CashReportList> createState() => _CashReportListState();
}

class _CashReportListState extends State<CashReportList> {
  bool isLoading = false;
  List<AdminUserModel> usersWithRequests = [];
  Map<String, List<TestDataRequest>> userRequests = {};

  // Date filter variables
  int startDate =
      DateTime(DateTime.now().year, DateTime.now().month, 1, 0, 0, 1)
          .millisecondsSinceEpoch;
  int endDate = DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, 23, 59, 59)
      .millisecondsSinceEpoch;

  // Summary variables
  int totalQuantity = 0;
  double totalCashReceived = 0;
  double totalAdvanced = 0;
  double totalDueReceived = 0;

  Future<void> _fetchData() async {
    if (isLoading) return;
    setState(() => isLoading = true);
    usersWithRequests.clear();
    userRequests.clear();
    totalQuantity = 0;
    totalCashReceived = 0;
    totalAdvanced = 0;
    totalDueReceived = 0;

    final ref = FirebaseDatabase.instance;

    try {
      // Fetch admin users
      final userSnapshot = await ref.ref("$adminUserApi/").get();
      final List<AdminUserModel> allUsers = [];
      if (userSnapshot.exists) {
        for (var ds in userSnapshot.children) {
          try {
            final data =
                AdminUserModel.fromJson(json.decode(json.encode(ds.value)));
            allUsers.add(data);
          } catch (e) {
            print("Error parsing AdminUserModel: $e");
          }
        }
        print("Fetched ${allUsers.length} admin users");
      } else {
        print("No admin users found at database/adminUser/");
      }

      // Fetch test requests
      final paths = _getYearMonthPaths();
      for (var path in paths) {
        final snapshot = await ref.ref(path).get();
        if (snapshot.exists) {
          _processSnapshot(snapshot, allUsers);
        }
      }
      print("Processed ${userRequests.length} users with requests");

      // Filter users with matching requests
      usersWithRequests = allUsers
          .where((user) => userRequests[user.phone]?.isNotEmpty ?? false)
          .toList();

      print(
          "Filtered ${usersWithRequests.length} users with matching requests");
    } catch (e) {
      print("Error fetching cash report data: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  List<String> _getYearMonthPaths() {
    final start = DateTime.fromMillisecondsSinceEpoch(startDate);
    final end = DateTime.fromMillisecondsSinceEpoch(endDate);
    final paths = <String>[];
    final formatter = DateFormat('MMMM');

    var current = DateTime(start.year, start.month, 1);
    while (current.isBefore(end) ||
        (current.year == end.year && current.month == end.month)) {
      paths.add(
          "$database_name/testRequest/${current.year}/${formatter.format(current)}");
      current = DateTime(current.year, current.month + 1, 1);
    }
    return paths;
  }

  void _processSnapshot(DataSnapshot snapshot, List<AdminUserModel> users) {
    for (var ds in snapshot.children) {
      for (var dsLater in ds.children) {
        try {
          final data =
          TestDataRequest.fromJson(json.decode(json.encode(dsLater.value)));
          if (data.payment_date == null ||
              data.total_cash_recieve == null ||
              data.total_cash_recieve == 0) continue;

          dynamic filterDate = (data.due_recieved != null &&
              data.due_recieved! > 0 &&
              data.due_recieve_date != null && data.due_recieved_by!=null)
              ? data.due_recieve_date
              : data.payment_date;

          if (startDate <= filterDate && filterDate <= endDate) {
            bool isCountedForQuantity = false;

            for (var user in users) {
              final handledAdvance = data.advance_recieved_by == user.phone;
              final handledDue = data.due_recieved_by == user.phone;

              if (!handledAdvance && !handledDue) continue;

              // Add to user's list only once
              userRequests.putIfAbsent(user.phone, () => []);
              if (!userRequests[user.phone]!
                  .any((r) => r.id == data.id && r.mobile == data.mobile)) {
                userRequests[user.phone]!.add(data);
              }

              // Count advanced only if this user handled advance
              if (handledAdvance) {
                totalAdvanced += data.advanced ?? 0;
              }

              // Count due only if this user handled due
              if (handledDue) {
                totalDueReceived += data.due_recieved ?? 0;
              }

              // Only count quantity and totalCash once globally
              if (!isCountedForQuantity) {
                totalQuantity++;
                // totalCashReceived += data.total_cash_recieve ?? 0;
                isCountedForQuantity = true;
              }
            }
          }
        } catch (e) {
          print("Error parsing TestDataRequest: $e for JSON: ${json.encode(dsLater.value)}");
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, _fetchData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        backgroundColor: appTheme,
        title: Text(
          "Cash Report",
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
                            backgroundColor: appTheme, elevation: 0),
                        onPressed: () async {
                          final picked = await showDatePicker(
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
                            backgroundColor: appTheme, elevation: 0),
                        onPressed: () async {
                          final picked = await showDatePicker(
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
                        ? Center(
                            child: CircularProgressIndicator(color: appTheme))
                        : usersWithRequests.isNotEmpty
                            ? Column(
                                children: [
                                  Divider(
                                      thickness: DM.p2, color: Colors.black),
                                  Expanded(
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: usersWithRequests.length,
                                      itemBuilder: (_, index) =>
                                          _buildRequestRow(index),
                                    ),
                                  ),
                                ],
                              )
                            : Container(
                                height: DM.screenHeight * 0.65,
                                margin: EdgeInsets.symmetric(vertical: DM.p16),
                                child: Center(
                                  child: Text(
                                    "Cash report list empty",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: DM.p25,
                                      color: appTheme,
                                    ),
                                  ),
                                ),
                              ),
                  ),
                  // Summary Section
                  Container(
                    padding: EdgeInsets.all(DM.p10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: DM.p15),
                        // Text(
                        //   "Users: $totalQuantity",
                        //   style: TextStyle(
                        //     fontWeight: FontWeight.w600,
                        //     fontSize: DM.p14,
                        //     color: Colors.black,
                        //   ),
                        // ),
                        Text(
                          "Total Cashed Received: ${(totalAdvanced+totalDueReceived).toStringAsFixed(2)}",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: DM.p14,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          "Total Advanced: ${totalAdvanced.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: DM.p14,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          "Total Due Received: ${totalDueReceived.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: DM.p14,
                            color: Colors.black,
                          ),
                        ),
                      ],
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

  Widget _buildHeaderRow() {
    return Container(
      height: DM.p50,
      width: DM.screenWidth - DM.p20,
      padding: EdgeInsets.symmetric(horizontal: DM.p5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: ["User Name", "Total Cash", "Advance", "Due Received"]
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
    final user = usersWithRequests[index];
    final requests = userRequests[user.phone]!;

    double userAdvanced = requests.fold(
      0,
          (sum, r) => r.advance_recieved_by == user.phone
          ? sum + (r.advanced ?? 0)
          : sum,
    );

    double userDueReceived = requests.fold(
      0,
          (sum, r) => r.due_recieved_by == user.phone
          ? sum + (r.due_recieved ?? 0)
          : sum,
    );

    double userTotalCash = userAdvanced + userDueReceived;

    return Container(
      decoration: BoxDecoration(
          color: whiteColor, borderRadius: BorderRadius.circular(DM.p10)),
      margin: EdgeInsets.symmetric(vertical: DM.p5, horizontal: DM.p5),
      height: DM.p60,
      padding: EdgeInsets.symmetric(horizontal: DM.p5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          user.name ?? "N/A",
          userTotalCash.toStringAsFixed(2),
          userAdvanced.toStringAsFixed(2),
          userDueReceived.toStringAsFixed(2),
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
}
