import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthcare_homelab/constants/api.dart';
import 'package:healthcare_homelab/constants/colors.dart';
import 'package:healthcare_homelab/state_programming/CreateRequestController.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants/app_info.dart';
import '../../../db/models/TestDataRequest.dart';
import '../../../responsives/dimensions.dart';

class CollectionReportList extends StatefulWidget {
  const CollectionReportList({super.key});

  @override
  State<CollectionReportList> createState() => _CollectionReportListState();
}

class _CollectionReportListState extends State<CollectionReportList> {
  final CreateRequestController createRequestController = Get.put(CreateRequestController());
  bool isLoading = false;
  String type = "0";
  String phone = "0";
  String? commission;
  int startDatetime = DateTime(DateTime.now().year, DateTime.now().month, 1, 0, 0, 1).millisecondsSinceEpoch;
  int endDatetime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59, 59).millisecondsSinceEpoch;
  double totalEarning = 0;
  double totalTestCost = 0;
  int totalQuantity = 0;
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
    _showLoading(true);
    _allRequestListAdmin.clear();
    _newTestRequestList.clear();
    totalEarning = 0;
    totalTestCost = 0;
    totalQuantity = 0;

    final prefs = await SharedPreferences.getInstance();
    phone = prefs.getString('phoneNumber') ?? "0";
    type = prefs.getString("type") ?? "0";
    commission = prefs.getString("commission");

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
                if ((data.assigning == phone || data.radiology_assigning == phone) &&
                    !_allRequestListAdmin.any((r) => r.id == data.id && r.mobile == data.mobile)) {
                  _allRequestListAdmin.add(data);
                }
              } catch (e) {
                print("Error parsing TestDataRequest: $e for JSON: ${jsonEncode(dsLater.value)}");
              }
            }
          }
        }
      }
      print("Fetched ${_allRequestListAdmin.length} requests from Firebase");
      await _filterData();
    } catch (e) {
      print("Error fetching test requests: $e");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // Filter data by date range, calculate metrics
  Future<void> _filterData() async {
    _newTestRequestList.clear();
    totalEarning = 0;
    totalTestCost = 0;
    totalQuantity = 0;

    for (var element in _allRequestListAdmin) {
      if (startDatetime <= (element.dateofcreated ?? 0) && (element.dateofcreated ?? 0) <= endDatetime) {
        _newTestRequestList.add(element);

        if (element.assigning == phone) {
          totalEarning += element.assigning_commission;
          totalTestCost += element.total_payable_pathology_cost;
        }
        if (element.radiology_assigning == phone) {
          totalEarning += element.radiology_assigning_commission;
          totalTestCost += element.total_payable_imagine_cost;
        }
        totalQuantity++;
      }
    }

    print("Filtered ${_newTestRequestList.length} requests");
    if (mounted) setState(() {});
  }

  // Update payment status in Firebase and refresh UI
  Future<void> _updatePay(TestDataRequest requestItem) async {
    if (requestItem.dateofcreated == null || requestItem.dateofcreated == 0) {
      print("Error: Invalid dateofcreated for request ${requestItem.id}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cannot update payment: Invalid creation date")),
      );
      return;
    }

    try {
      final date = DateTime.fromMillisecondsSinceEpoch(requestItem.dateofcreated!);
      final year = date.year;
      final monthName = DateFormat('MMMM').format(date);
      final path = "$database_name/testRequest/$year/$monthName/${requestItem.mobile}/${requestItem.id}";
      final ref = FirebaseDatabase.instance.ref(path);

      final currentTime = DateTime.now().millisecondsSinceEpoch;
      final updateTestRequestItem = TestDataRequest(
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
        teststatus: requestItem.teststatus,
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
        assigning: requestItem.assigning,
        assigning_commission: requestItem.assigning_commission,
        advanced: requestItem.advanced,
        delivery_date: requestItem.delivery_date,
        due_amount: requestItem.due_amount,
        test_item_cost: requestItem.test_item_cost,
        test_item_discount: requestItem.test_item_discount,
        total_admin_discount: requestItem.total_admin_discount,
        total_agent_discount: requestItem.total_agent_discount,
        total_discount: requestItem.total_discount,
        is_paid: true,
        total_unpayable_pathology: requestItem.total_unpayable_pathology,
        total_unpayable_imagine: requestItem.total_unpayable_imagine,
        payment_date: currentTime,
        pathology_done: requestItem.pathology_done,
        radiology_done: requestItem.radiology_done,
        radiology_assigning: requestItem.radiology_assigning,
        radiology_assigning_commission: requestItem.radiology_assigning_commission,
        imageDiscountFile: requestItem.imageDiscountFile,
      );

      // Update Firebase
      await ref.update(jsonDecode(jsonEncode(updateTestRequestItem.toJson())));

      // Update local list to reflect the change immediately
      final index = _newTestRequestList.indexWhere(
              (item) => item.id == requestItem.id && item.mobile == requestItem.mobile);
      if (index != -1) {
        _newTestRequestList[index] = updateTestRequestItem;
        // Recalculate metrics
        totalEarning = 0;
        totalTestCost = 0;
        totalQuantity = 0;
        for (var element in _newTestRequestList) {
          if (startDatetime <= (element.dateofcreated ?? 0) && (element.dateofcreated ?? 0) <= endDatetime) {
            if (element.assigning == phone) {
              totalEarning += element.assigning_commission;
              totalTestCost += element.total_payable_pathology_cost;
            }
            if (element.radiology_assigning == phone) {
              totalEarning += element.radiology_assigning_commission;
              totalTestCost += element.total_payable_imagine_cost;
            }
            totalQuantity++;
          }
        }
        setState(() {});
      }

      // Refresh data from Firebase
      await _fetchData();
    } catch (e) {
      print("Error updating payment for request ${requestItem.id}: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update payment: $e")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, _fetchData);
  }

  @override
  void dispose() {
    if (isLoading) {
      Navigator.pop(context);
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
          "Collection Report",
          style: TextStyle(color: secondaryColor, fontSize: DM.p30),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Date filter buttons
            Padding(
              padding: EdgeInsets.all(DM.p15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Container(
                      height: DM.p60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: appTheme, elevation: 0),
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
                      height: DM.p60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: appTheme, elevation: 0),
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
            // Request list
            Container(
              height: DM.screenHeight * 0.62,
              margin: EdgeInsets.symmetric(horizontal: DM.p5),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: DM.p50,
                        width: DM.screenWidth * 1.2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(width: DM.p80, child: Text("Invoice Call", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900, fontSize: DM.p10, color: Color.fromARGB(255, 26, 1, 1)))),
                            Container(width: DM.p80, child: Text("Test Cost", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900, fontSize: DM.p10, color: Color.fromARGB(255, 26, 1, 1)))),
                            Container(width: DM.p80, child: Text("Commission", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900, fontSize: DM.p10, color: Color.fromARGB(255, 26, 1, 1)))),
                            Container(width: DM.p80, child: Text("Payment Date", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900, fontSize: DM.p10, color: Color.fromARGB(255, 26, 1, 1)))),
                            Container(width: DM.p80, child: Text("Status", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900, fontSize: DM.p10, color: Color.fromARGB(255, 26, 1, 1)))),
                          ],
                        ),
                      ),
                      Divider(thickness: DM.p2, color: Colors.black),
                      Expanded(
                        child: Container(
                          height: DM.screenHeight * 0.50,
                          width: DM.screenWidth * 1.2,
                          child: _newTestRequestList.isNotEmpty
                              ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: _newTestRequestList.length,
                            itemBuilder: (context, index) {
                              final request = _newTestRequestList[index];
                              final isBoth = request.assigning == phone && request.radiology_assigning == phone;
                              final testCost = isBoth
                                  ? request.total_payable_pathology_cost + request.total_payable_imagine_cost
                                  : request.assigning == phone
                                  ? request.total_payable_pathology_cost
                                  : request.total_payable_imagine_cost;
                              final commission = isBoth
                                  ? request.assigning_commission + request.radiology_assigning_commission
                                  : request.assigning == phone
                                  ? request.assigning_commission
                                  : request.radiology_assigning_commission;
                              return Container(
                                decoration: BoxDecoration(
                                  color: whiteColor,
                                  borderRadius: BorderRadius.circular(DM.p10),
                                ),
                                margin: EdgeInsets.symmetric(vertical: DM.p5),
                                height: DM.p60,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(width: DM.p80, child: Text("#${request.invoice_call}", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900, fontSize: DM.p10, color: Color.fromARGB(255, 26, 1, 1)))),
                                    Container(width: DM.p80, child: Text("$testCost", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900, fontSize: DM.p10, color: Color.fromARGB(255, 26, 1, 1)))),
                                    Container(width: DM.p80, child: Text("$commission", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900, fontSize: DM.p10, color: Color.fromARGB(255, 26, 1, 1)))),
                                    Container(
                                      width: DM.p80,
                                      child: request.payment_date == 0
                                          ? Text("NA", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900, fontSize: DM.p10, color: Color.fromARGB(255, 26, 1, 1)))
                                          : Text(
                                        DateFormat('dd-MMM-yyyy').format(DateTime.fromMillisecondsSinceEpoch(request.payment_date)),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: DM.p10, color: Color.fromARGB(255, 26, 1, 1)),
                                      ),
                                    ),
                                    Container(
                                      width: DM.p80,
                                      child: request.is_paid
                                          ? Text("Paid", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900, fontSize: DM.p10, color: Color.fromARGB(255, 26, 1, 1)))
                                          : (type == "7" || phone == superUser)
                                          ? MaterialButton(
                                        onPressed: () async => await _updatePay(request),
                                        height: DM.p40,
                                        shape: const StadiumBorder(),
                                        color: appTheme,
                                        child: Text(
                                          "Pay",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: fullWhiteColor, fontSize: DM.p13, fontWeight: FontWeight.bold),
                                        ),
                                      )
                                          : Text("Not Paid", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900, fontSize: DM.p10, color: Color.fromARGB(255, 26, 1, 1))),
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                              : Center(
                            child: Text(
                              "Request list empty",
                              style: TextStyle(fontWeight: FontWeight.w400, fontSize: DM.p25, color: appTheme),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Summary metrics
            Container(
              margin: EdgeInsets.symmetric(horizontal: DM.p10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(thickness: DM.p1, color: blackFontColor),
                  Text(
                    "Total Invoice Quantity: $totalQuantity",
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: DM.p15, color: Color.fromARGB(255, 26, 1, 1)),
                  ),
                  Text(
                    "Total Test Cost: $totalTestCost",
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: DM.p15, color: Color.fromARGB(255, 26, 1, 1)),
                  ),
                  Text(
                    "Total Earning: $totalEarning",
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: DM.p15, color: Color.fromARGB(255, 26, 1, 1)),
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