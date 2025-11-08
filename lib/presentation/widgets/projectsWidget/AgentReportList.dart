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
import '../../../constants/commission_types.dart';
import '../../../db/models/AdminUserModel.dart';
import '../../../db/models/TestDataRequest.dart';
import '../../../responsives/dimensions.dart';

import '../otherWidgets/MyDateFilter.dart';

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
  int startDate = DateFilterWithUtils.getDefaultStartDate();
  int endDate = DateFilterWithUtils.getDefaultEndDate();
  double totalEarning = 0;
  double totalTestCost = 0;
  double totalPaidAmount = 0;
  final List<TestDataRequest> _newTestRequestList = [];
  final List<TestDataRequest> _allRequestListAdmin = [];
  final List<String> paidStatusList = ["PAID", "UNPAID", "BOTH"];
  final Set<String> agentReferrerCodes = {};
  final List<Map<dynamic, dynamic>> agentUserMapList = [];
  final List<AdminUserModel> agentUserModelList = [];

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


  String getNameByReferrerCode(String? referrerCode) {
    final userMap = agentUserMapList.firstWhere(
          (user) => user['referrer_code'] == referrerCode,
      orElse: () => {},
    );
    return userMap.isEmpty ? "Unknown" : userMap['name'] ?? "Unknown";
  }

  Future<void> getAgentUsers() async {
    agentReferrerCodes.clear();
    agentUserMapList.clear();
    agentUserModelList.clear();
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
            agentUserModelList.add(data);
          }
        } catch (e) {
          print("Error parsing AdminUserModel: $e");
        }
      }
    }
  }

  /// Get AdminUserModel by referrer code
  AdminUserModel? getAgentByReferrerCode(String? referrerCode) {
    try {
      return agentUserModelList.firstWhere(
        (user) => user.referrer_code == referrerCode,
      );
    } catch (e) {
      return null;
    }
  }

  /// Calculate commission amounts by type for an invoice based on test items
  Map<String, int> calculateCommissionsByType(TestDataRequest request) {
    final Map<String, int> commissionsByType = {};
    final agent = getAgentByReferrerCode(request.referrer?.toString());
    
    if (agent == null || request.testlist == null || request.testlist!.isEmpty) {
      // Return empty map with zeros for all types
      for (final type in CommissionTypes.allTypes) {
        commissionsByType[type] = 0;
      }
      return commissionsByType;
    }

    // Initialize all commission types to 0
    for (final type in CommissionTypes.allTypes) {
      commissionsByType[type] = 0;
    }

    // Calculate commission for each test item
    for (final testItem in request.testlist!) {
      if (testItem.is_payable == false) continue; // Skip unpayable items
      
      final testPrice = int.tryParse(testItem.testprice.toString()) ?? 0;
      final testDiscount = int.tryParse(testItem.discount.toString()) ?? 0;
      final amount = testPrice - testDiscount; // Amount after discount
      
      // Get commission type from test category
      final commissionType = testItem.getCommissionType();
      
      // Get agent's commission percentage for this type
      final commissionPercent = int.tryParse(agent.getCommission(commissionType)?.toString() ?? '0') ?? 0;
      
      // Calculate commission: amount * percentage / 100
      final commission = (amount * commissionPercent) ~/ 100;
      
      // Add to the appropriate commission type
      commissionsByType[commissionType] = (commissionsByType[commissionType] ?? 0) + commission;
    }

    return commissionsByType;
  }

  /// Calculate total commission for an invoice
  int calculateTotalCommission(TestDataRequest request) {
    final commissionsByType = calculateCommissionsByType(request);
    return commissionsByType.values.fold(0, (sum, value) => sum + value);
  }

  TestDataRequest? getLatestPaymentData(List<TestDataRequest> payments) {
    if (payments.isEmpty) return null;

    // Find the one with the maximum paymentDate
    return payments.reduce(
        (a, b) => (a.payment_date ?? 0) > (b.payment_date ?? 0) ? a : b);
  }

  Future<void> _fetchData() async {
    _allRequestListAdmin.clear();
    _newTestRequestList.clear();
    totalEarning = 0;
    totalTestCost = 0;
    totalPaidAmount = 0;

    final prefs = await SharedPreferences.getInstance();
    phone = prefs.getString('phoneNumber') ?? "0";
    type = prefs.getString('type') ?? "0";
    if (phone != superUser && type != "7") {
      commission = prefs.getString("commission");
      referrerCode = prefs.getString("referrer_code") ?? "0";
    }

    final paths = getYearMonthPathsForPastYears("testRequest");
    final ref = FirebaseDatabase.instance;

    try {
      final futures = paths.map((path) async {
        final snapshot = await ref.ref(path).get();
        if (!snapshot.exists) return;

        for (var snapshotChild in snapshot.children) {
          for (var ds in snapshotChild.children) {
            try {
              final data = TestDataRequest.fromJson(jsonDecode(jsonEncode(ds.value)));
              final isDuplicate = _allRequestListAdmin.any(
                    (r) => r.id == data.id && r.mobile == data.mobile,
              );
              final hasValidReferrer = data.referrer != null &&
                  data.referrer != 0 &&
                  data.referrer.toString().isNotEmpty;
              final isReferrerRecognized = agentUserMapList.any(
                    (entry) => entry['referrer_code'] == data.referrer.toString(),
              );

              if (!isDuplicate && hasValidReferrer && isReferrerRecognized) {
                _allRequestListAdmin.add(data);
              }
            } catch (e) {
              print("Error parsing TestDataRequest: $e for JSON: ${jsonEncode(ds.value)}");
            }
          }
        }
      }).toList();

      await Future.wait(futures);

      print("Fetched ${_allRequestListAdmin.length} requests from Firebase");
      await _filterData(referrerInput.text);
    } catch (e) {
      print("Error fetching data: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }


  Future<void> _filterData(String referrer) async {
    setState(() => isLoading = true);
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
      bool matchesDate = DateFilterWithUtils.isDateInRange(element, startDate, endDate,true);
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
        final totalCommission = calculateTotalCommission(e);
        final earning = totalCommission - (e.total_agent_discount ?? 0);
        totalEarning += earning;
        totalTestCost += e.total_payable ?? 0;
        if (e.is_paid) {
          totalPaidAmount += earning;
        }
      }
    }
    lastPaymentTestReq = getLatestPaymentData(_newTestRequestList);

    print("Filtered ${_newTestRequestList.length} requests");
    if (mounted) setState(() => isLoading = false);
  }

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
          pathology_payment_date: requestItem.pathology_payment_date,
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

      await ref.update(jsonDecode(jsonEncode(updateTestRequestItem.toJson())));

      final index = _newTestRequestList.indexWhere((item) => item.id == requestItem.id && item.mobile == requestItem.mobile);
      if (index != -1) {
        _newTestRequestList[index] = updateTestRequestItem;
        totalEarning = 0;
        totalTestCost = 0;
        totalPaidAmount = 0;
        for (var e in _newTestRequestList) {
          if (e.teststatus == 6) {
            final totalCommission = calculateTotalCommission(e);
            final earning = totalCommission - (e.total_agent_discount ?? 0);
            totalEarning += earning;
            totalTestCost += e.total_payable ?? 0;
            if (e.is_paid) {
              totalPaidAmount += earning;
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
          build: (pw.Context context) => [
            pw.Center(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    'HEALTHCARE HOMELAB',
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.Text(
                    'Steel Mills Bazar, Patenga',
                    style: const pw.TextStyle(fontSize: 12),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.Text(
                    '01785-890750',
                    style: const pw.TextStyle(fontSize: 12, color: PdfColors.blue),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'Agent Report',
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 10),
                ],
              ),
            ),
            pw.Table.fromTextArray(
              headers: [
                'Date',
                'Invoice',
                'Patient',
                'Agent',
                'Code',
                'Hematology',
                'Biochemistry',
                'Hormone',
                'Serology',
                'Immunology',
                'Radiology',
                'Imaging',
                'Others',
                'Total Comm.',
                'Discount',
                'Earning',
                'Pay Date',
                'Payment',
              ],
              data: [
                ..._newTestRequestList.map((item) {
                  final commissions = calculateCommissionsByType(item);
                  final totalCommission = calculateTotalCommission(item);
                  final earning = item.teststatus == 6 
                      ? (totalCommission - (int.tryParse(item.total_agent_discount?.toString() ?? '0') ?? 0)).toString() 
                      : '';
                  return [
                    item.dateofcreated == 0
                        ? 'NA'
                        : DateFormat('dd-MMM-yyyy').format(DateFilterWithUtils.toDateTime(item.dateofcreated!)),
                    '#${item.invoice_call}',
                    item.name ?? '',
                    getNameByReferrerCode(item.referrer.toString()),
                    item.referrer.toString(),
                    item.teststatus != 1 ? (commissions[CommissionTypes.hematology] ?? 0).toString() : 'Pending',
                    item.teststatus != 1 ? (commissions[CommissionTypes.biochemistry] ?? 0).toString() : 'Pending',
                    item.teststatus != 1 ? (commissions[CommissionTypes.hormone] ?? 0).toString() : 'Pending',
                    item.teststatus != 1 ? (commissions[CommissionTypes.serology] ?? 0).toString() : 'Pending',
                    item.teststatus != 1 ? (commissions[CommissionTypes.immunology] ?? 0).toString() : 'Pending',
                    item.teststatus != 1 ? (commissions[CommissionTypes.radiology] ?? 0).toString() : 'Pending',
                    item.teststatus != 1 ? (commissions[CommissionTypes.imaging] ?? 0).toString() : 'Pending',
                    item.teststatus != 1 ? (commissions[CommissionTypes.others] ?? 0).toString() : 'Pending',
                    item.teststatus != 1 ? totalCommission.toString() : 'Pending',
                    item.teststatus != 1 ? (int.tryParse(item.total_agent_discount?.toString() ?? '0') ?? 0).toString() : '',
                    earning,
                    item.payment_date == 0
                        ? 'NA'
                        : DateFormat('dd-MMM-yyyy').format(DateFilterWithUtils.toDateTime(item.payment_date!)),
                    item.is_paid ? 'Paid' : 'Unpaid',
                  ];
                }).toList(),
                // Total Rows
                [
                  'Total',
                  '',
                  '',
                  '',
                  '',
                  _calculateTotalForCommissionType(CommissionTypes.hematology).toString(),
                  _calculateTotalForCommissionType(CommissionTypes.biochemistry).toString(),
                  _calculateTotalForCommissionType(CommissionTypes.hormone).toString(),
                  _calculateTotalForCommissionType(CommissionTypes.serology).toString(),
                  _calculateTotalForCommissionType(CommissionTypes.immunology).toString(),
                  _calculateTotalForCommissionType(CommissionTypes.radiology).toString(),
                  _calculateTotalForCommissionType(CommissionTypes.imaging).toString(),
                  _calculateTotalForCommissionType(CommissionTypes.others).toString(),
                  _calculateTotalCommissionSum().toString(),
                  _calculateTotalDiscountSum().toString(),
                  _calculateTotalEarningSum().toString(),
                  '',
                  '',
                ],
                // Profit Rows
                [
                  'Profit',
                  '',
                  '',
                  '',
                  '',
                  _calculateProfitForCommissionType(CommissionTypes.hematology).toString(),
                  _calculateProfitForCommissionType(CommissionTypes.biochemistry).toString(),
                  _calculateProfitForCommissionType(CommissionTypes.hormone).toString(),
                  _calculateProfitForCommissionType(CommissionTypes.serology).toString(),
                  _calculateProfitForCommissionType(CommissionTypes.immunology).toString(),
                  _calculateProfitForCommissionType(CommissionTypes.radiology).toString(),
                  _calculateProfitForCommissionType(CommissionTypes.imaging).toString(),
                  _calculateProfitForCommissionType(CommissionTypes.others).toString(),
                  _calculateTotalProfitCommission().toString(),
                  '',
                  (_calculateTotalProfitCommission() - _calculateTotalDiscountSum()).toString(),
                  '',
                  '',
                ],
              ],
              cellStyle: const pw.TextStyle(fontSize: 9),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
              cellAlignment: pw.Alignment.center,
            ),
            pw.SizedBox(height: 10),
            pw.Text('Last Payment Date = ${DateFormat('dd-MMM-yyyy').format(DateFilterWithUtils.toDateTime(lastPaymentTestReq?.payment_date ?? 0))}'),
            pw.Text('Total Invoice Quantity = ${_newTestRequestList.length}'),
            pw.Text('Total Test Cost = $totalTestCost'),
            pw.Text('Total Earning = $totalEarning/-  Total Paid = $totalPaidAmount'),
          ],
        ),
      );

      final baseDir = Directory('/storage/emulated/0/Documents/Health Care Homelab report/agent report');
      await baseDir.create(recursive: true);

      final agentName = referrerCode.replaceAll(RegExp(r'[^\w\s-]'), '_');
      final file = File('${baseDir.path}/$agentName.pdf');
      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF saved to ${file.path}')),
      );

      final result = await OpenFile.open(file.path);
      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the PDF. Please open it manually.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting PDF: $e')),
      );
    }
  }

  Future<void> permissionNeed() async {
    if (await Permission.storage.request().isGranted) {}
  }

  void _agentNameSorting() {
    final Map<String?, String?> codeToNameMap = {
      for (var agent in agentUserMapList) agent['referrer_code']: agent['name']
    };

    _newTestRequestList.sort((a, b) {
      final nameA = codeToNameMap[a.referrer.toString()] ?? '';
      final nameB = codeToNameMap[b.referrer.toString()] ?? '';
      final nameComparison = nameA.compareTo(nameB);
      if (nameComparison != 0) return nameComparison;
      return (a.dateofcreated ?? 0).compareTo(b.dateofcreated ?? 0);
    });
  }

  Widget _buildCommissionCell(TestDataRequest request, String commissionType) {
    if (request.teststatus == 1) {
      return SizedBox(
        width: DM.p70,
        child: Text("Processing",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: DM.p9,
                color: Color.fromARGB(255, 26, 1, 1))),
      );
    }
    
    // Calculate commissions based on test items and agent commission percentages
    final commissions = calculateCommissionsByType(request);
    final commissionValue = commissions[commissionType] ?? 0;
    
    return SizedBox(
      width: DM.p70,
      child: Text(
        commissionValue.toString(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: DM.p9,
          color: Color.fromARGB(255, 26, 1, 1),
        ),
      ),
    );
  }

  /// Calculate total sum for a specific commission type across all invoices
  int _calculateTotalForCommissionType(String commissionType) {
    int total = 0;
    for (var request in _newTestRequestList) {
      if (request.teststatus != 1) {
        final commissions = calculateCommissionsByType(request);
        total += commissions[commissionType] ?? 0;
      }
    }
    return total;
  }

  /// Calculate total commission sum across all invoices
  int _calculateTotalCommissionSum() {
    int total = 0;
    for (var request in _newTestRequestList) {
      if (request.teststatus != 1) {
        total += calculateTotalCommission(request);
      }
    }
    return total;
  }

  /// Calculate total discount sum across all invoices
  int _calculateTotalDiscountSum() {
    int total = 0;
    for (var request in _newTestRequestList) {
      if (request.teststatus != 1) {
        total += int.tryParse(request.total_agent_discount?.toString() ?? '0') ?? 0;
      }
    }
    return total;
  }

  /// Calculate total earning sum across all invoices
  int _calculateTotalEarningSum() {
    int total = 0;
    for (var request in _newTestRequestList) {
      if (request.teststatus == 6) {
        final totalCommission = calculateTotalCommission(request);
        final discount = int.tryParse(request.total_agent_discount?.toString() ?? '0') ?? 0;
        total += totalCommission - discount;
      }
    }
    return total;
  }

  /// Calculate total profit (total commission - total discount)
  int _calculateTotalProfit() {
    return _calculateTotalCommissionSum() - _calculateTotalDiscountSum();
  }

  /// Get the agent for the filtered referrer code (or first agent if filtering by referrer)
  AdminUserModel? _getFilteredAgent() {
    if (type == "2") {
      // If viewing as agent, get the logged-in agent
      return getAgentByReferrerCode(referrerCode);
    } else if (referrerInput.text.isNotEmpty && referrerInput.text != "0") {
      // If filtering by referrer code, get that agent
      return getAgentByReferrerCode(referrerInput.text);
    } else if (_newTestRequestList.isNotEmpty) {
      // If no filter, get the first agent from the list (or most common agent)
      final firstRequest = _newTestRequestList.first;
      return getAgentByReferrerCode(firstRequest.referrer?.toString());
    }
    return null;
  }

  /// Calculate profit for a specific commission type based on percentage
  /// Profit = (Total commission for that type) * (agent's commission percentage) / 100
  /// Example: If Hormone column total is 1000 and agent has 10% commission, profit = 1000 * 10 / 100 = 100
  int _calculateProfitForCommissionType(String commissionType) {
    final agent = _getFilteredAgent();
    if (agent == null) return 0;
    
    // Get the total commission amount for this type (sum of all invoices)
    final totalCommissionForType = _calculateTotalForCommissionType(commissionType);
    
    // Get agent's commission percentage for this type
    final commissionPercent = int.tryParse(agent.getCommission(commissionType)?.toString() ?? '0') ?? 0;
    
    // Profit = total commission * percentage / 100
    // This shows the percentage value of the total commission
    return (totalCommissionForType * commissionPercent) ~/ 100;
  }

  /// Calculate total profit commission (sum of all commission type profits)
  int _calculateTotalProfitCommission() {
    int total = 0;
    for (final type in CommissionTypes.allTypes) {
      total += _calculateProfitForCommissionType(type);
    }
    return total;
  }

  /// Build total cell for a commission type
  Widget _buildTotalCell(String commissionType) {
    return SizedBox(
      width: DM.p70,
      child: Text(
        _calculateTotalForCommissionType(commissionType).toString(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: DM.p10,
          color: Color.fromARGB(255, 26, 1, 1),
        ),
      ),
    );
  }

  /// Build profit cell for a commission type (percentage-based profit)
  Widget _buildProfitCell(String commissionType) {
    return SizedBox(
      width: DM.p70,
      child: Text(
        _calculateProfitForCommissionType(commissionType).toString(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: DM.p10,
          color: Color.fromARGB(255, 0, 128, 0),
        ),
      ),
    );
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
                    const Text(":"),
                    SizedBox(width: DM.p10),
                    Flexible(
                      child: SizedBox(
                        height: DM.p50,
                        child: TextFormField(
                          keyboardType: TextInputType.name,
                          controller: referrerInput,
                          onChanged: (value) => _filterData(value),
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
            DateFilterWithUtils(
              initialStartDate: startDate,
              initialEndDate: endDate,
              onStartDateChanged: (newStart) {
                setState(() {
                  startDate = newStart;
                  isLoading = true;
                  _fetchData();
                });
              },
              onEndDateChanged: (newEnd) {
                setState(() {
                  endDate = newEnd;
                  isLoading = true;
                  _fetchData();
                });
              },
            ),
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
                            color: const Color(0xFF1A0101),
                          ),
                        ),
                      ),
                      SizedBox(width: DM.p5),
                      const Text(":"),
                      SizedBox(width: DM.p10),
                      DropdownButton<String>(
                        value: paidStatus,
                        items: paidStatusList
                            .map((value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: TextStyle(color: blackFontColor)),
                        ))
                            .toList(),
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
                      padding: EdgeInsets.symmetric(horizontal: DM.p20, vertical: DM.p15),
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
            SizedBox(
              height: DM.screenHeight * 0.60,
              child: isLoading
                  ?  Center(child: CircularProgressIndicator(color: appTheme,))
                  : ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: DM.p50,
                        width: DM.screenWidth * 3.8,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                width: DM.p70,
                                child: Text("Date",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: DM.p9,
                                        color: Color.fromARGB(255, 26, 1, 1)))),
                            Container(
                                width: DM.p70,
                                child: Text("Invoice",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: DM.p9,
                                        color: Color.fromARGB(255, 26, 1, 1)))),
                            Container(
                                width: DM.p80,
                                child: Text("Patient Name",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: DM.p9,
                                        color: Color.fromARGB(255, 26, 1, 1)))),
                            Row(
                              children: [
                                Container(
                                    width: DM.p80,
                                    child: Text("Agent Name",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: DM.p9,
                                            color: Color.fromARGB(
                                                255, 26, 1, 1)))),
                                Container(
                                    width: DM.p70,
                                    child: Text("Agent Code",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: DM.p9,
                                            color: Color.fromARGB(
                                                255, 26, 1, 1)))),
                              ],
                            ),
                            Container(
                                width: DM.p70,
                                child: Text("Hematology",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: DM.p9,
                                        color: Color.fromARGB(255, 1, 1, 1)))),
                            Container(
                                width: DM.p70,
                                child: Text("Biochemistry",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: DM.p9,
                                        color: Color.fromARGB(255, 1, 1, 1)))),
                            Container(
                                width: DM.p70,
                                child: Text("Hormone",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: DM.p9,
                                        color: Color.fromARGB(255, 1, 1, 1)))),
                            Container(
                                width: DM.p70,
                                child: Text("Serology",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: DM.p9,
                                        color: Color.fromARGB(255, 1, 1, 1)))),
                            Container(
                                width: DM.p70,
                                child: Text("Immunology",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: DM.p9,
                                        color: Color.fromARGB(255, 1, 1, 1)))),
                            Container(
                                width: DM.p70,
                                child: Text("Radiology",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: DM.p9,
                                        color: Color.fromARGB(255, 1, 1, 1)))),
                            Container(
                                width: DM.p70,
                                child: Text("Imaging",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: DM.p9,
                                        color: Color.fromARGB(255, 1, 1, 1)))),
                            Container(
                                width: DM.p70,
                                child: Text("Others",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: DM.p9,
                                        color: Color.fromARGB(255, 1, 1, 1)))),
                            Container(
                                width: DM.p70,
                                child: Text("Total Comm.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: DM.p9,
                                        color: Color.fromARGB(255, 1, 1, 1)))),
                            Container(
                                width: DM.p70,
                                child: Text("Discount",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: DM.p9,
                                        color: Color.fromARGB(255, 1, 1, 1)))),
                            Container(
                                width: DM.p70,
                                child: Text("Earning",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: DM.p9,
                                        color: Color.fromARGB(255, 1, 1, 1)))),
                            Container(
                                width: DM.p70,
                                child: Text("Pay Date",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: DM.p9,
                                        color: Color.fromARGB(255, 1, 1, 1)))),
                            Container(
                                width: DM.p70,
                                child: Text("Payment",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: DM.p9,
                                        color: Color.fromARGB(255, 1, 1, 1)))),
                          ],
                        ),
                      ),
                      Divider(thickness: DM.p2, color: Colors.black),
                      Expanded(
                        child: SizedBox(
                          width: DM.screenWidth * 3.8,
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
                                              width: DM.p70,
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
                                                      fontSize: DM.p9,
                                                      color: Color.fromARGB(
                                                          255, 26, 1, 1)))),
                                          Container(
                                              width: DM.p70,
                                              child: Text(
                                                  "#${request.invoice_call}",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      fontSize: DM.p9,
                                                      color: Color.fromARGB(
                                                          255, 26, 1, 1)))),
                                          Container(
                                              width: DM.p80,
                                              child: Text("${request.name}",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      fontSize: DM.p9,
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
                                                          fontSize: DM.p9,
                                                          color: Color.fromARGB(
                                                              255, 26, 1, 1)))),
                                              Container(
                                                  width: DM.p70,
                                                  child: Text(
                                                      "${request.referrer ?? 0}",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          fontSize: DM.p9,
                                                          color: Color.fromARGB(
                                                              255, 26, 1, 1)))),
                                            ],
                                          ),
                                          _buildCommissionCell(request, CommissionTypes.hematology),
                                          _buildCommissionCell(request, CommissionTypes.biochemistry),
                                          _buildCommissionCell(request, CommissionTypes.hormone),
                                          _buildCommissionCell(request, CommissionTypes.serology),
                                          _buildCommissionCell(request, CommissionTypes.immunology),
                                          _buildCommissionCell(request, CommissionTypes.radiology),
                                          _buildCommissionCell(request, CommissionTypes.imaging),
                                          _buildCommissionCell(request, CommissionTypes.others),
                                          request.teststatus != 1
                                              ? SizedBox(
                                                  width: DM.p70,
                                                  child: Text(
                                                      "${calculateTotalCommission(request)}",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          fontSize: DM.p9,
                                                          color: Color.fromARGB(
                                                              255, 26, 1, 1))))
                                              : SizedBox(
                                                  width: DM.p70,
                                                  child: Text("Processing",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          fontSize: DM.p9,
                                                          color: Color.fromARGB(
                                                              255, 26, 1, 1)))),
                                          request.teststatus != 1
                                              ? SizedBox(
                                                  width: DM.p70,
                                                  child: Text(
                                                      "${request.total_agent_discount ?? 0}",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          fontSize: DM.p9,
                                                          color: Color.fromARGB(
                                                              255, 26, 1, 1))))
                                              : SizedBox(
                                                  width: DM.p70,
                                                  child: Text("Processing",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          fontSize: DM.p9,
                                                          color: Color.fromARGB(
                                                              255, 26, 1, 1)))),
                                          request.teststatus == 6
                                              ? SizedBox(
                                                  width: DM.p70,
                                                  child: Text(
                                                      "${calculateTotalCommission(request) - (request.total_agent_discount ?? 0)}",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          fontSize: DM.p9,
                                                          color: Color.fromARGB(
                                                              255, 26, 1, 1))))
                                              : SizedBox(
                                                  width: DM.p70,
                                                  child: Text("Processing",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          fontSize: DM.p9,
                                                          color: Color.fromARGB(
                                                              255, 26, 1, 1)))),
                                          SizedBox(
                                            width: DM.p70,
                                            child: request.payment_date == 0
                                                ? Text("NA",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        fontSize: DM.p9,
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
                                                        fontSize: DM.p9,
                                                        color: Color.fromARGB(255, 26, 1, 1))),
                                          ),
                                          SizedBox(
                                            width: DM.p70,
                                            child: request.is_paid
                                                ? Text("Paid",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        fontSize: DM.p9,
                                                        color: Color.fromARGB(
                                                            255, 26, 1, 1)))
                                                : ((type == "7" && request.teststatus==6) ||
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
                                                              fontSize: DM.p12,
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
                                                            fontSize: DM.p9,
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
                                color: appTheme,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Total Rows - Show individual totals of each column
                      if (_newTestRequestList.isNotEmpty) ...[
                        Divider(thickness: DM.p2, color: Colors.black),
                        Container(
                          height: DM.p50,
                          width: DM.screenWidth * 3.8,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(DM.p5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: DM.p70,
                                child: Text("Total",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: DM.p10,
                                        color: Color.fromARGB(255, 26, 1, 1))),
                              ),
                              Container(width: DM.p70, child: SizedBox()), // Invoice
                              Container(width: DM.p80, child: SizedBox()), // Patient Name
                              Row(
                                children: [
                                  Container(width: DM.p80, child: SizedBox()), // Agent Name
                                  Container(width: DM.p70, child: SizedBox()), // Agent Code
                                ],
                              ),
                              _buildTotalCell(CommissionTypes.hematology),
                              _buildTotalCell(CommissionTypes.biochemistry),
                              _buildTotalCell(CommissionTypes.hormone),
                              _buildTotalCell(CommissionTypes.serology),
                              _buildTotalCell(CommissionTypes.immunology),
                              _buildTotalCell(CommissionTypes.radiology),
                              _buildTotalCell(CommissionTypes.imaging),
                              _buildTotalCell(CommissionTypes.others),
                              SizedBox(
                                width: DM.p70,
                                child: Text(
                                  "${_calculateTotalCommissionSum()}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: DM.p10,
                                    color: Color.fromARGB(255, 26, 1, 1),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: DM.p70,
                                child: Text(
                                  "${_calculateTotalDiscountSum()}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: DM.p10,
                                    color: Color.fromARGB(255, 26, 1, 1),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: DM.p70,
                                child: Text(
                                  "${_calculateTotalEarningSum()}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: DM.p10,
                                    color: Color.fromARGB(255, 26, 1, 1),
                                  ),
                                ),
                              ),
                              Container(width: DM.p70, child: SizedBox()), // Pay Date
                              Container(width: DM.p70, child: SizedBox()), // Payment
                            ],
                          ),
                        ),
                        // Profit Rows - Show individual commission type profit
                        Divider(thickness: DM.p2, color: Colors.black),
                        Container(
                          height: DM.p50,
                          width: DM.screenWidth * 3.8,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(DM.p5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: DM.p70,
                                child: Text("Profit",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: DM.p10,
                                        color: Color.fromARGB(255, 26, 1, 1))),
                              ),
                              Container(width: DM.p70, child: SizedBox()), // Invoice
                              Container(width: DM.p80, child: SizedBox()), // Patient Name
                              Row(
                                children: [
                                  Container(width: DM.p80, child: SizedBox()), // Agent Name
                                  Container(width: DM.p70, child: SizedBox()), // Agent Code
                                ],
                              ),
                              _buildProfitCell(CommissionTypes.hematology),
                              _buildProfitCell(CommissionTypes.biochemistry),
                              _buildProfitCell(CommissionTypes.hormone),
                              _buildProfitCell(CommissionTypes.serology),
                              _buildProfitCell(CommissionTypes.immunology),
                              _buildProfitCell(CommissionTypes.radiology),
                              _buildProfitCell(CommissionTypes.imaging),
                              _buildProfitCell(CommissionTypes.others),
                              SizedBox(
                                width: DM.p70,
                                child: Text(
                                  "${_calculateTotalProfitCommission()}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: DM.p10,
                                    color: Color.fromARGB(255, 26, 1, 1),
                                  ),
                                ),
                              ),
                              Container(width: DM.p70, child: SizedBox()), // Discount
                              SizedBox(
                                width: DM.p70,
                                child: Text(
                                  "${_calculateTotalProfitCommission() - _calculateTotalDiscountSum()}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: DM.p10,
                                    color: Color.fromARGB(255, 0, 128, 0),
                                  ),
                                ),
                              ),
                              Container(width: DM.p70, child: SizedBox()), // Pay Date
                              Container(width: DM.p70, child: SizedBox()), // Payment
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: DM.p10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Divider(thickness: 1, color: blackFontColor),
                  Text(
                    "Last Payment Date: ${DateFormat('dd-MMM-yyyy').format(DateFilterWithUtils.toDateTime(lastPaymentTestReq?.payment_date ?? 0))}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: Color(0xFF1A0101),
                    ),
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
