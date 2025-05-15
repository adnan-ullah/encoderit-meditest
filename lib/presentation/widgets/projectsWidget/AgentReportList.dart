import 'dart:convert';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthcare_homelab/constants/colors.dart';
import 'package:healthcare_homelab/state_programming/CreateRequestController.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/api.dart';
import '../../../constants/app_info.dart';
import '../../../db/models/AdminUserModel.dart';
import '../../../db/models/TestDataRequest.dart';
import '../../../responsives/dimensions.dart';

class AgentReportList extends StatefulWidget {
  const AgentReportList({super.key});

  @override
  State<AgentReportList> createState() => _AgentReportListState();
}

class _AgentReportListState extends State<AgentReportList> {
  final CreateRequestController createRequestController =
      Get.put(CreateRequestController());
  final TextEditingController referrerInput = TextEditingController(text: "0");
  bool isLoading = true;
  String referrerCode = "0";
  String? commission;
  String type = "0";
  String phone = "0";
  String paidStatus = "BOTH";
  TestDataRequest? lastPaymentTestReq;
  int startDatetime =
      DateTime(DateTime.now().year, DateTime.now().month, 1, 0, 0, 1)
          .millisecondsSinceEpoch;
  int endDatetime = DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, 23, 59, 59)
      .millisecondsSinceEpoch;
  double totalEarning = 0;
  double totalTestCost = 0;
  double totalPaidAmount = 0;
  final List<TestDataRequest> _newTestRequestList = [];
  final List<TestDataRequest> _allRequestListAdmin = [];
  final List<String> paidStatusList = ["PAID", "UNPAID", "BOTH"];
  final Set<String> agentReferrerCodes = {};
  final List<Map<dynamic, dynamic>> agentUserMapList = [];

  // Generate list of year/month paths to query based on date range
  List<String> _getYearMonthPaths() {
    final start = DateTime.fromMillisecondsSinceEpoch(startDatetime);
    final end = DateTime.fromMillisecondsSinceEpoch(endDatetime);
    final paths = <String>[];
    final formatter = DateFormat('MMMM');

    var current = DateTime(start.year, start.month, 1);
    while (current.isBefore(end) ||
        (current.year == end.year && current.month == end.month)) {
      final year = current.year;
      final monthName = formatter.format(current);
      paths.add("$database_name/testRequest/$year/$monthName");
      current = DateTime(current.year, current.month + 1, 1);
    }
    return paths;
  }

  String getNameByReferrerCode(String referrerCode) {
    final userMap = agentUserMapList.firstWhere(
      (user) => user['referrer_code'] == referrerCode,
      orElse: () => {}, // Return an empty map if not found
    );

    return userMap.isNotEmpty ? userMap['name'] ?? "Unknown" : "Unknown";
  }

  Future<void> getAgentUsers() async {
    agentReferrerCodes.clear();
    agentUserMapList.clear();
    final ref = FirebaseDatabase.instance;
    final userSnapshot = await ref.ref("$adminUserApi/").get();
    if (userSnapshot.exists) {
      for (var ds in userSnapshot.children) {
        try {
          final data = AdminUserModel.fromJson(
            json.decode(json.encode(ds.value)),
          );

          if (data.type.toString() == "2" &&
              data.referrer_code != null &&
              data.referrer_code.toString().isNotEmpty &&
              data.name != null &&
              data.name.toString().isNotEmpty) {
            agentReferrerCodes.add(data.referrer_code!);
            agentUserMapList.add({
              "name": data.name!,
              "referrer_code": data.referrer_code!,
            });
          }
        } catch (e) {
          print("Error parsing AdminUserModel: $e");
        }
      }
    }
  }

  TestDataRequest? getLatestPaymentData(List<TestDataRequest> payments) {
    if (payments.isEmpty) return null;

    // Find the one with the maximum paymentDate
    return payments.reduce(
        (a, b) => (a.payment_date ?? 0) > (b.payment_date ?? 0) ? a : b);
  }

  // Fetch data from Firebase for all year/month paths
  Future<void> _fetchData() async {
    _allRequestListAdmin.clear();
    _newTestRequestList.clear();
    totalEarning = 0;
    totalTestCost = 0;
    totalPaidAmount = 0;

    final prefs = await SharedPreferences.getInstance();
    phone = prefs.getString('phoneNumber') ?? "0";
    type = prefs.getString("type") ?? "0";
    if (phone != superUser && type != "7") {
      commission = prefs.getString("commission");
      referrerCode = prefs.getString("referrer_code") ?? "0";
    }

    final paths = _getYearMonthPaths();
    final ref = FirebaseDatabase.instance;

    try {
      for (var path in paths) {
        final snapshot = await ref.ref(path).get();
        if (snapshot.exists) {
          for (var ds in snapshot.children) {
            for (var dsLater in ds.children) {
              try {
                final data = TestDataRequest.fromJson(
                  json.decode(jsonEncode(dsLater.value)),
                );

                final isDuplicate = _allRequestListAdmin.any(
                  (r) => r.id == data.id && r.mobile == data.mobile,
                );

                final hasValidReferrer = data.referrer != null &&
                    data.referrer != 0 &&
                    data.referrer.toString().isNotEmpty;

                final isReferrerRecognized = agentUserMapList.any(
                  (entry) => entry['referrer_code'] == data.referrer.toString(),
                );

                print("agentUserMapList: $agentUserMapList");

                if (!isDuplicate && hasValidReferrer && isReferrerRecognized) {
                  _allRequestListAdmin.add(data);
                }
              } catch (e) {
                print(
                    "Error parsing TestDataRequest: $e for JSON: ${jsonEncode(dsLater.value)}");
              }
            }
          }
        }
      }
      print("Fetched ${_allRequestListAdmin.length} requests from Firebase");
      await _filterData(referrerInput.text);
    } catch (e) {
      print("Error fetching test requests: $e");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // Filter data by referrer, date range, and paid status, calculate metrics
  Future<void> _filterData(String referrer) async {
    isLoading = true;
    _newTestRequestList.clear();
    totalEarning = 0;
    totalTestCost = 0;
    totalPaidAmount = 0;

    if (type == "2") {
      referrer = referrerCode;
    }

    for (var element in _allRequestListAdmin) {
      bool matchesReferrer = referrer.isNotEmpty && referrer != "0"
          ? element.referrer.toString() == referrer
          : true;
      bool matchesDate = startDatetime <= (element.dateofcreated ?? 0) &&
          (element.dateofcreated ?? 0) <= endDatetime;
      bool matchesPaidStatus = paidStatus == "BOTH" ||
          (paidStatus == "PAID" && element.is_paid == true) ||
          (paidStatus == "UNPAID" && element.is_paid == false);

      if (matchesReferrer && matchesDate && matchesPaidStatus) {
        _newTestRequestList.add(element);
      }

      // Update last payment date
    }

    _agentNameSorting();

    for (var e in _newTestRequestList) {
      if (e.teststatus == 6) {
        totalEarning += e.agent_commission - e.total_agent_discount;
        totalTestCost += e.total_payable;
        if (e.is_paid) {
          totalPaidAmount += e.agent_commission - e.total_agent_discount;
        }
      }
    }
    lastPaymentTestReq = getLatestPaymentData(_newTestRequestList);

    print("Filtered ${_newTestRequestList.length} requests");
    if (mounted) setState(() {
      isLoading = false;
    });
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
      final date =
          DateTime.fromMillisecondsSinceEpoch(requestItem.dateofcreated!);
      final year = date.year;
      final monthName = DateFormat('MMMM').format(date);
      final path =
          "$database_name/testRequest/$year/$monthName/${requestItem.mobile}/${requestItem.id}";
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
          total_payable_pathology_cost:
              requestItem.total_payable_pathology_cost,
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
          radiology_assigning_commission:
              requestItem.radiology_assigning_commission,
          imageDiscountFile: requestItem.imageDiscountFile,
          advance_recieved_by: requestItem.advance_recieved_by,
          total_cash_recieve: requestItem.total_cash_recieve,
          prepared_by: requestItem.prepared_by,
          last_modifier: requestItem.last_modifier,
          advance_payment_date: requestItem.advance_payment_date,
          due_recieve_one_date: requestItem.due_recieve_one_date,
          due_recieve_two_date: requestItem.due_recieve_two_date,
          due_recieved_one: requestItem.due_recieved_one,
          due_recieved_one_by: requestItem.due_recieved_one_by,
          due_recieved_two: requestItem.due_recieved_two,
          due_recieved_two_by: requestItem.due_recieved_two_by);

      // Update Firebase
      await ref.update(jsonDecode(jsonEncode(updateTestRequestItem.toJson())));

      // Update local list to reflect the change immediately
      final index = _newTestRequestList.indexWhere((item) =>
          item.id == requestItem.id && item.mobile == requestItem.mobile);
      if (index != -1) {
        _newTestRequestList[index] = updateTestRequestItem;

        // Recalculate metrics
        totalEarning = 0;
        totalTestCost = 0;
        totalPaidAmount = 0;
        for (var e in _newTestRequestList) {
          if (e.teststatus == 6) {
            totalEarning += e.agent_commission - e.total_agent_discount;
            totalTestCost += e.total_payable;
            if (e.is_paid) {
              totalPaidAmount += e.agent_commission - e.total_agent_discount;
            }
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

  Future<void> _exportToPdf() async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(16),
          build: (pw.Context context) {
            return [
              pw.Header(
                level: 0,
                child:
                    pw.Text('Agent Report', style: pw.TextStyle(fontSize: 22)),
              ),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: [
                  'Date',
                  'Invoice',
                  'Patient',
                  'Agent',
                  'Code',
                  'Path.',
                  'Radio.',
                  'Total',
                  'Comm.',
                  'Disc.',
                  'Earn.',
                  'Status',
                  'Pay Date',
                  'Payment',
                ],
                data: _newTestRequestList.map((item) {
                  return [
                    item.dateofcreated == 0
                        ? 'NA'
                        : DateFormat('dd-MMM-yyyy').format(
                            DateTime.fromMillisecondsSinceEpoch(
                                item.dateofcreated)),
                    '#${item.invoice_call}',
                    item.name,
                    getNameByReferrerCode(item.referrer.toString()),
                    item.referrer.toString(),
                    item.teststatus != 1
                        ? item.total_payable_pathology_cost.toString()
                        : 'Processing',
                    item.teststatus != 1
                        ? item.total_payable_imagine_cost.toString()
                        : 'Processing',
                    item.teststatus != 1
                        ? item.total_payable.toString()
                        : 'Processing',
                    item.teststatus != 1
                        ? item.agent_commission.toString()
                        : 'Processing',
                    item.teststatus != 1
                        ? item.total_agent_discount.toString()
                        : 'Processing',
                    item.teststatus == 6
                        ? (item.agent_commission - item.total_agent_discount)
                            .toString()
                        : 'Processing',
                    createRequestController.status[item.teststatus].toString(),
                    item.payment_date == 0
                        ? 'NA'
                        : DateFormat('dd-MMM-yyyy').format(
                            DateTime.fromMillisecondsSinceEpoch(
                                item.payment_date)),
                    item.is_paid ? 'Paid' : 'Unpaid',
                  ];
                }).toList(),
                cellStyle: pw.TextStyle(fontSize: 9),
                headerStyle:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                cellAlignment: pw.Alignment.center,
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                  'Last Payment Date = ${DateFormat('dd-MMM-yyyy').format(DateTime.fromMillisecondsSinceEpoch(lastPaymentTestReq?.payment_date ?? 0))}'),
              pw.Text('Total Invoice Quantity = ${_newTestRequestList.length}'),
              pw.Text('Total Test Cost = $totalTestCost'),
              pw.Text(
                  'Total Earning = $totalEarning/-  Total Paid = $totalPaidAmount'),
            ];
          },
        ),
      );

      final baseDir = Directory(
          '/storage/emulated/0/Documents/Health Care Homelab report/agent report');
      await baseDir.create(recursive: true);

      final agentName = referrerCode.replaceAll(RegExp(r'[^\w\s-]'), '_');
      final file = File('${baseDir.path}/$agentName.pdf');
      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF saved to ${file.path}')),
      );

      // Open the file automatically
      final result = await OpenFile.open(file.path);
      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Could not open the PDF. Please open it manually.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting PDF: $e')),
      );
    }
  }

  Future<void> permissionNeed() async {
    if (await Permission.storage.request() == true) {}
  }

  void _agentNameSorting() {

    //sort with user wise and date wise
    final Map<String, String> codeToNameMap = {
      for (var agent in agentUserMapList) agent['referrer_code']: agent['name']
    };

    _newTestRequestList.sort((a, b) {
      final nameA = codeToNameMap[a.referrer.toString()] ?? '';
      final nameB = codeToNameMap[b.referrer.toString()] ?? '';
      final nameComparison = nameA.compareTo(nameB);
      if (nameComparison != 0) return nameComparison;
      return a.dateofcreated.compareTo(b.dateofcreated);
    });
  }

  @override
  void initState() {
    permissionNeed();
    getAgentUsers();
    super.initState();
    Future.delayed(Duration.zero, _fetchData);
  }

  @override
  void dispose() {
    referrerInput.dispose();
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
          "Report",
          style: TextStyle(color: secondaryColor, fontSize: DM.p30),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Referrer code input for superusers
            if (type == "7" || phone == superUser)
              Padding(
                padding: EdgeInsets.all(DM.p10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: DM.p70,
                      child: Text(
                        "Referrer Code",
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
                          controller: referrerInput,
                          onChanged: (value) => _filterData(value),
                          decoration: InputDecoration(
                            errorStyle: TextStyle(fontSize: DM.p9),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(width: DM.p1, color: appTheme),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(width: DM.p1, color: appTheme),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            hintText: "0",
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: DM.p14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
                        style: ElevatedButton.styleFrom(
                            backgroundColor: appTheme, elevation: 0),
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.fromMillisecondsSinceEpoch(
                                startDatetime),
                            firstDate: DateTime(2022, 11),
                            lastDate: DateTime(2030, 7),
                          );
                          if (picked != null) {
                            setState(() {
                              startDatetime = DateTime(picked.year,
                                      picked.month, picked.day, 0, 0, 1)
                                  .millisecondsSinceEpoch;
                              _fetchData();
                            });
                          }
                        },
                        child: Text(
                          "First: ${DateFormat.yMMMd().format(DateTime.fromMillisecondsSinceEpoch(startDatetime))}",
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(color: Colors.white, fontSize: DM.p12),
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
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.fromMillisecondsSinceEpoch(
                                endDatetime),
                            firstDate: DateTime(2022, 11),
                            lastDate: DateTime(2030, 7),
                          );
                          if (picked != null) {
                            setState(() {
                              endDatetime = DateTime(picked.year, picked.month,
                                      picked.day, 23, 59, 59)
                                  .millisecondsSinceEpoch;
                              isLoading = true;
                              _fetchData();
                            });
                          }
                        },
                        child: Text(
                          "Last: ${DateFormat.yMMMd().format(DateTime.fromMillisecondsSinceEpoch(endDatetime))}",
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(color: Colors.white, fontSize: DM.p12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Paid status dropdown and export button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.all(DM.p10),
                  child: Row(
                    children: [
                      SizedBox(
                        width: DM.p100,
                        child: Text(
                          "Paid Status:",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: DM.p14,
                            color: Color.fromARGB(255, 26, 1, 1),
                          ),
                        ),
                      ),
                      SizedBox(width: DM.p5),
                      Text(":"),
                      SizedBox(width: DM.p10),
                      DropdownButton<String>(
                        value: paidStatus,
                        items: paidStatusList.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(color: blackFontColor),
                            ),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            paidStatus = newValue!;
                            _filterData(referrerInput.text);
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(DM.p10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appTheme,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(
                          horizontal: DM.p20, vertical: DM.p15),
                    ),
                    onPressed: _exportToPdf,
                    child: Text(
                      'Export',
                      style: TextStyle(
                        color: fullWhiteColor,
                        fontSize: DM.p16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Request list
            Container(
              height: DM.screenHeight * 0.62,
              margin: EdgeInsets.symmetric(horizontal: DM.p5),
              child:
              !isLoading? ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: DM.p50,
                        width: DM.screenWidth * 2.7,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                width: DM.p80,
                                child: Text("Date",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: DM.p10,
                                        color: Color.fromARGB(255, 26, 1, 1)))),
                            Container(
                                width: DM.p80,
                                child: Text("Invoice Call",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: DM.p10,
                                        color: Color.fromARGB(255, 26, 1, 1)))),
                            // if (type == "2" && superUser != phone)
                            Container(
                                width: DM.p80,
                                child: Text("Patient Name",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: DM.p10,
                                        color: Color.fromARGB(255, 26, 1, 1)))),
                            Row(
                              children: [
                                Container(
                                    width: DM.p80,
                                    child: Text("Agent Name",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: DM.p10,
                                            color: Color.fromARGB(
                                                255, 26, 1, 1)))),
                                Container(
                                    width: DM.p80,
                                    child: Text("Agent Code",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: DM.p10,
                                            color: Color.fromARGB(
                                                255, 26, 1, 1)))),
                              ],
                            ),
                            Container(
                                width: DM.p80,
                                child: Text("Pathology Total",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: DM.p10,
                                        color: Color.fromARGB(255, 1, 1, 1)))),
                            Container(
                                width: DM.p80,
                                child: Text("Radiology Total",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: DM.p10,
                                        color: Color.fromARGB(255, 1, 1, 1)))),
                            Container(
                                width: DM.p80,
                                child: Text("Total Cost",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: DM.p10,
                                        color: Color.fromARGB(255, 1, 1, 1)))),
                            Container(
                                width: DM.p80,
                                child: Text("Commission",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: DM.p10,
                                        color: Color.fromARGB(255, 1, 1, 1)))),
                            Container(
                                width: DM.p80,
                                child: Text("Discount",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: DM.p10,
                                        color: Color.fromARGB(255, 1, 1, 1)))),
                            Container(
                                width: DM.p80,
                                child: Text("Earning",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: DM.p10,
                                        color: Color.fromARGB(255, 1, 1, 1)))),
                            Container(
                                width: DM.p80,
                                child: Text("Status",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: DM.p10,
                                        color: Color.fromARGB(255, 1, 1, 1)))),
                            Container(
                                width: DM.p80,
                                child: Text("Payment Date",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: DM.p10,
                                        color: Color.fromARGB(255, 1, 1, 1)))),
                            Container(
                                width: DM.p80,
                                child: Text("Payment",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: DM.p10,
                                        color: Color.fromARGB(255, 1, 1, 1)))),
                          ],
                        ),
                      ),
                      Divider(thickness: DM.p2, color: Colors.black),
                      Expanded(
                        child: Container(
                          height: DM.screenHeight * 0.50,
                          width: DM.screenWidth * 2.7,
                          child: _newTestRequestList.isNotEmpty
                              ? ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _newTestRequestList.length,
                                  itemBuilder: (context, index) {
                                    final request = _newTestRequestList[index];
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: whiteColor,
                                        borderRadius:
                                            BorderRadius.circular(DM.p10),
                                      ),
                                      margin:
                                          EdgeInsets.symmetric(vertical: DM.p5),
                                      height: DM.p60,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                              width: DM.p80,
                                              child: Text(
                                                  DateFormat('dd-MMM-yyyy')
                                                      .format(DateTime
                                                          .fromMillisecondsSinceEpoch(
                                                              request
                                                                  .dateofcreated)),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      fontSize: DM.p10,
                                                      color: Color.fromARGB(
                                                          255, 26, 1, 1)))),
                                          Container(
                                              width: DM.p80,
                                              child: Text(
                                                  "#${request.invoice_call}",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      fontSize: DM.p10,
                                                      color: Color.fromARGB(
                                                          255, 26, 1, 1)))),
                                          // if (type == "2" && superUser != phone)
                                          Container(
                                              width: DM.p80,
                                              child: Text("${request.name}",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      fontSize: DM.p10,
                                                      color: Color.fromARGB(
                                                          255, 26, 1, 1)))),
                                          Row(
                                            children: [
                                              Container(
                                                  width: DM.p80,
                                                  child: Text(
                                                      getNameByReferrerCode(
                                                          request.referrer
                                                              .toString()),
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          fontSize: DM.p10,
                                                          color: Color.fromARGB(
                                                              255, 26, 1, 1)))),
                                              Container(
                                                  width: DM.p80,
                                                  child: Text(
                                                      "${request.referrer ?? 0}",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          fontSize: DM.p10,
                                                          color: Color.fromARGB(
                                                              255, 26, 1, 1)))),
                                            ],
                                          ),
                                          request.teststatus != 1
                                              ? SizedBox(
                                                  width: DM.p80,
                                                  child: Text(
                                                      "${request.total_payable_pathology_cost}",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          fontSize: DM.p10,
                                                          color: Color.fromARGB(
                                                              255, 26, 1, 1))))
                                              : SizedBox(
                                                  width: DM.p80,
                                                  child: Text("Processing",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          fontSize: DM.p10,
                                                          color: Color.fromARGB(
                                                              255, 26, 1, 1)))),
                                          request.teststatus != 1
                                              ? SizedBox(
                                                  width: DM.p80,
                                                  child: Text(
                                                      "${request.total_payable_imagine_cost}",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          fontSize: DM.p10,
                                                          color: Color.fromARGB(
                                                              255, 26, 1, 1))))
                                              : SizedBox(
                                                  width: DM.p80,
                                                  child: Text("Processing",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          fontSize: DM.p10,
                                                          color: Color.fromARGB(
                                                              255, 26, 1, 1)))),
                                          request.teststatus != 1
                                              ? SizedBox(
                                                  width: DM.p80,
                                                  child: Text(
                                                      "${request.total_payable}",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          fontSize: DM.p10,
                                                          color: Color.fromARGB(
                                                              255, 26, 1, 1))))
                                              : SizedBox(
                                                  width: DM.p80,
                                                  child: Text("Processing",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          fontSize: DM.p10,
                                                          color: Color.fromARGB(
                                                              255, 26, 1, 1)))),
                                          request.teststatus != 1
                                              ? SizedBox(
                                                  width: DM.p80,
                                                  child: Text(
                                                      "${request.agent_commission}",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          fontSize: DM.p10,
                                                          color: Color.fromARGB(
                                                              255, 26, 1, 1))))
                                              : SizedBox(
                                                  width: DM.p80,
                                                  child: Text("Processing",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          fontSize: DM.p10,
                                                          color: Color.fromARGB(
                                                              255, 26, 1, 1)))),
                                          request.teststatus != 1
                                              ? SizedBox(
                                                  width: DM.p80,
                                                  child: Text(
                                                      "${request.total_agent_discount}",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          fontSize: DM.p10,
                                                          color: Color.fromARGB(
                                                              255, 26, 1, 1))))
                                              : SizedBox(
                                                  width: DM.p80,
                                                  child: Text("Processing",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          fontSize: DM.p10,
                                                          color: Color.fromARGB(
                                                              255, 26, 1, 1)))),
                                          request.teststatus == 6
                                              ? SizedBox(
                                                  width: DM.p80,
                                                  child: Text(
                                                      "${request.agent_commission - request.total_agent_discount}",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          fontSize: DM.p10,
                                                          color: Color.fromARGB(
                                                              255, 26, 1, 1))))
                                              : SizedBox(
                                                  width: DM.p80,
                                                  child: Text("Processing",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          fontSize: DM.p10,
                                                          color: Color.fromARGB(
                                                              255, 26, 1, 1)))),
                                          SizedBox(
                                              width: DM.p80,
                                              child: Text(
                                                  createRequestController
                                                      .status[
                                                          request.teststatus]
                                                      .toString(),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      fontSize: DM.p10,
                                                      color: Color.fromARGB(
                                                          255, 26, 1, 1)))),
                                          SizedBox(
                                            width: DM.p80,
                                            child: request.payment_date == 0
                                                ? Text("NA",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        fontSize: DM.p10,
                                                        color: Color.fromARGB(
                                                            255, 26, 1, 1)))
                                                : Text(
                                                    DateFormat('dd-MMM-yyyy').format(
                                                        DateTime.fromMillisecondsSinceEpoch(
                                                            request
                                                                .payment_date)),
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.w900,
                                                        fontSize: DM.p10,
                                                        color: Color.fromARGB(255, 26, 1, 1))),
                                          ),
                                          SizedBox(
                                            width: DM.p80,
                                            child: request.is_paid
                                                ? Text("Paid",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        fontSize: DM.p10,
                                                        color: Color.fromARGB(
                                                            255, 26, 1, 1)))
                                                : (type == "7" ||
                                                        phone == superUser)
                                                    ? MaterialButton(
                                                        onPressed: () async =>
                                                            await _updatePay(
                                                                request),
                                                        height: DM.p40,
                                                        shape:
                                                            const StadiumBorder(),
                                                        color: appTheme,
                                                        child: Text(
                                                          "Pay",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              color:
                                                                  fullWhiteColor,
                                                              fontSize: DM.p13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      )
                                                    : Text("Not Paid",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w900,
                                                            fontSize: DM.p10,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    26,
                                                                    1,
                                                                    1))),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                )
                              : Center(
                                  child: Text(
                                    "Request list empty",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: DM.p25,
                                        color: appTheme),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ):
              Container(
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(appTheme),
                  ),
                ),
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
                    "Last Payment Date: ${DateFormat('dd-MMM-yyyy').format(DateTime.fromMillisecondsSinceEpoch(lastPaymentTestReq?.payment_date ?? 0))}",
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: DM.p15,
                        color: Color.fromARGB(255, 26, 1, 1)),
                  ),
                  Text(
                    "Total Invoice Quantity: ${_newTestRequestList.length}",
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: DM.p15,
                        color: Color.fromARGB(255, 26, 1, 1)),
                  ),
                  Text(
                    "Total Test Cost: $totalTestCost",
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: DM.p15,
                        color: Color.fromARGB(255, 26, 1, 1)),
                  ),
                  Text(
                    "Total Earning: $totalEarning / Total Paid: $totalPaidAmount",
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: DM.p15,
                        color: Color.fromARGB(255, 26, 1, 1)),
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
