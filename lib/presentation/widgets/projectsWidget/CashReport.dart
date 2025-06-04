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

import '../otherWidgets/MyDateFilter.dart';


class CashReportList extends StatefulWidget {
  const CashReportList({super.key});

  @override
  State<CashReportList> createState() => _CashReportListState();
}

class _CashReportListState extends State<CashReportList> {
  bool isLoading = false;
  List<AdminUserModel> usersWithRequests = [];
  Map<String, List<TestDataRequest>> userRequests = {};

  int startDate = DateFilterWithUtils.getDefaultStartDate();
  int endDate = DateFilterWithUtils.getDefaultEndDate();

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
            final data = AdminUserModel.fromJson(jsonDecode(jsonEncode(ds.value)));
            allUsers.add(data);
          } catch (e) {
            print("Error parsing AdminUserModel: $e");
          }
        }
        print("Fetched ${allUsers.length} admin users");
      } else {
        print("No admin users found at $adminUserApi/");
      }

      final paths = getYearMonthPathsForPastYears("testRequest");

      // Parallel fetch and process
      await Future.wait(paths.map((path) async {
        final snapshot = await ref.ref(path).get();
        if (snapshot.exists) {
          _processSnapshot(snapshot, allUsers);
        }
      }));

      // Filter users with matching requests
      usersWithRequests = allUsers
          .where((user) => userRequests[user.phone]?.isNotEmpty ?? false)
          .toList();

      totalCashReceived = totalAdvanced + totalDueReceived;
      totalQuantity = usersWithRequests.fold(
          0, (sum, user) => sum + (userRequests[user.phone]?.length ?? 0));

      print("Filtered ${usersWithRequests.length} users with matching requests");
    } catch (e) {
      print("Error fetching cash report data: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }


  List<String> getYearMonthPathsForPastYears(String type, {int pastYears = 10}) {
    final formatter = DateFormat.MMMM();
    final current = DateTime.now();
    final currentYear = current.year;
    final currentMonth = current.month;

    final paths = <String>[];

    for (int year = currentYear; year > currentYear - pastYears; year--) {
      for (int month = 1; month <= 12; month++) {
        if (year == currentYear && month > currentMonth) continue;

        final monthName = formatter.format(DateTime(year, month));
        final path = "$database_name/$type/$year/$monthName";
        paths.add(path);
      }
    }
    return paths;
  }

  void _processSnapshot(DataSnapshot snapshot, List<AdminUserModel> users) {
    for (var ds in snapshot.children) {
      for (var dsLater in ds.children) {
        try {
          final data = TestDataRequest.fromJson(jsonDecode(jsonEncode(dsLater.value)));
          if (data.advance_payment_date == null ||
              data.total_cash_recieve == null ||
              data.total_cash_recieve == 0) continue;

          for (var user in users) {
            final handledAdvance = data.advance_recieved_by == user.phone;
            final handledDueOne = data.due_recieved_one_by == user.phone;
            final handledDueTwo = data.due_recieved_two_by == user.phone;

            if (!handledAdvance && !handledDueOne && !handledDueTwo) continue;

            if (DateFilterWithUtils.isDateInRange(data, startDate, endDate,false)) {
              userRequests.putIfAbsent(user.phone, () => []);
              if (!userRequests[user.phone]!
                  .any((r) => r.id == data.id && r.mobile == data.mobile)) {
                userRequests[user.phone]!.add(data);
              }

              if (handledAdvance && DateFilterWithUtils.isDateInRangeInCash(data,data.advance_payment_date, startDate, endDate)) {
                totalAdvanced += data.advanced ?? 0;
              }

              if (handledDueOne && DateFilterWithUtils.isDateInRangeInCash(data,data.due_recieve_one_date, startDate, endDate)) {
                totalDueReceived += data.due_recieved_one ?? 0;
              }

              if (handledDueTwo && DateFilterWithUtils.isDateInRangeInCash(data,data.due_recieve_two_date, startDate, endDate)) {
                totalDueReceived += data.due_recieved_two ?? 0;
              }
            }
          }
        } catch (e) {
          print("Error parsing TestDataRequest: $e for JSON: ${jsonEncode(dsLater.value)}");
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
            DateFilterWithUtils(
              initialStartDate: startDate,
              initialEndDate: endDate,
              onStartDateChanged: (newStart) {
                setState(() {
                  startDate = newStart;
                  _fetchData();
                });
              },
              onEndDateChanged: (newEnd) {
                setState(() {
                  endDate = newEnd;
                  _fetchData();
                });
              },
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
                        ? Center(child: CircularProgressIndicator(color: appTheme))
                        : usersWithRequests.isNotEmpty
                        ? Column(
                      children: [
                        Divider(thickness: DM.p2, color: Colors.black),
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: usersWithRequests.length,
                            itemBuilder: (_, index) => _buildRequestRow(index),
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
                  Container(
                    padding: EdgeInsets.all(DM.p10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: DM.p15),
                        Text(
                          "Total Cash Received: ${totalCashReceived.toStringAsFixed(2)}",
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
        children: ["User Name", "Total Cash\n(Taka)", "Advance\n(Taka)", "Due Received\n(Taka)"]
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

    double userAdvanced = requests.fold(0, (sum, r) {
      if (r.advance_recieved_by == user.phone && DateFilterWithUtils.isDateInRangeInCash(r,r.advance_payment_date, startDate, endDate)) {
        return sum + (r.advanced ?? 0);
      }
      return sum;
    });

    double userDueReceived = requests.fold(0, (sum, r) {
      double dueSum = 0;
      if (r.due_recieved_one_by == user.phone && DateFilterWithUtils.isDateInRangeInCash(r, r.due_recieve_one_date,startDate, endDate)) {
        dueSum += r.due_recieved_one ?? 0;
      }
      if (r.due_recieved_two_by == user.phone && DateFilterWithUtils.isDateInRangeInCash(r, r.due_recieve_two_date,startDate, endDate)) {
        dueSum += r.due_recieved_two ?? 0;
      }
      return sum + dueSum;
    });

    double userTotalCash = userAdvanced + userDueReceived;

    return userTotalCash != 0
        ? Container(
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
              color: const Color.fromARGB(255, 26, 1, 1),
            ),
          ),
        ))
            .toList(),
      ),
    )
        : const SizedBox();
  }
}