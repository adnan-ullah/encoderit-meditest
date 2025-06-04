import 'dart:convert';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthcare_homelab/constants/api.dart';
import 'package:healthcare_homelab/constants/app_info.dart';
import 'package:healthcare_homelab/constants/colors.dart';
import 'package:healthcare_homelab/db/models/AdminUserModel.dart';
import 'package:healthcare_homelab/db/models/TestDataRequest.dart';
import 'package:healthcare_homelab/responsives/dimensions.dart';
import 'package:healthcare_homelab/state_programming/CreateRequestController.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../otherWidgets/MyDateFilter.dart';

class CollectionReport extends StatefulWidget {
  const CollectionReport({super.key});

  @override
  State<CollectionReport> createState() => _CollectionReportState();
}

class _CollectionReportState extends State<CollectionReport> {
  final CreateRequestController createRequestController =
  Get.put(CreateRequestController());
  final TextEditingController searchInput = TextEditingController();
  final List<String> assigningFilterList = ['Pathology', 'Radiology'];
  final List<String> paymentStatusFilterList = ['Paid', 'Unpaid', 'Both'];
  final List<TestDataRequest> _allRequestListAdmin = [];
  final List<TestDataRequest> _newTestRequestList = [];
  final List<Map<String, dynamic>> collectionUserMapList = [];

  bool isLoading = true;
  String phone = '0';
  String type = '0';
  String assigningFilter = 'Pathology';
  String paymentStatusFilter = 'Both';
  int startDatetime = DateFilterWithUtils.getDefaultStartDate();
  int endDatetime = DateFilterWithUtils.getDefaultEndDate();
  double totalCommission = 0;
  double totalTestCost = 0;
  int totalInvoiceQuantity = 0;
  double totalPaid = 0;
  TestDataRequest? lastPaymentTestReq;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    searchInput.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    await permissionNeed();
    await getCollectionUsers();
    await _fetchData();
  }

  Future<void> permissionNeed() async {
    if (await Permission.storage.request() != PermissionStatus.granted) {
      // Handle permission denial
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

  String getNameByPhoneNumber(String phoneNumber) {
    final userMap = collectionUserMapList.firstWhere(
          (user) => user['phone'] == phoneNumber,
      orElse: () => {},
    );
    return userMap.isNotEmpty ? userMap['name'] ?? 'Unknown' : 'Unknown';
  }

  Future<void> getCollectionUsers() async {
    collectionUserMapList.clear();
    final ref = FirebaseDatabase.instance;
    final userSnapshot = await ref.ref('$adminUserApi/').get();

    if (userSnapshot.exists) {
      for (var ds in userSnapshot.children) {
        try {
          final data =
          AdminUserModel.fromJson(json.decode(json.encode(ds.value)));
          if (data.type.toString() == '4' &&
              data.name != null &&
              data.name!.isNotEmpty &&
              data.phone != null &&
              data.phone!.isNotEmpty) {
            collectionUserMapList.add({
              'name': data.name!,
              'phone': data.phone!,
            });
          }
        } catch (e) {
          debugPrint('Error parsing AdminUserModel: $e');
        }
      }
    }
  }

  TestDataRequest? getLatestPaymentData(List<TestDataRequest> payments) {
    if (payments.isEmpty) return null;
    return payments.reduce((a, b) {
      final aDate = (a.pathology_payment_date ?? a.radiology_payment_date ?? 0);
      final bDate = (b.pathology_payment_date ?? b.radiology_payment_date ?? 0);
      return aDate > bDate ? a : b;
    });
  }

  Future<void> _fetchData() async {
    setState(() => isLoading = true);
    _allRequestListAdmin.clear();
    _newTestRequestList.clear();
    totalCommission = 0;
    totalTestCost = 0;
    totalPaid = 0;
    totalInvoiceQuantity = 0;

    final prefs = await SharedPreferences.getInstance();
    phone = prefs.getString('phoneNumber') ?? '0';
    type = prefs.getString('type') ?? '0';

    final paths = getYearMonthPathsForPastYears("testRequest");
    final ref = FirebaseDatabase.instance;

    try {
      await Future.wait(paths.map((path) async {
        final snapshot = await ref.ref(path).get();
        if (snapshot.exists) {
          for (var ds in snapshot.children) {
            for (var dsLater in ds.children) {
              try {
                final data = TestDataRequest.fromJson(
                    json.decode(jsonEncode(dsLater.value)));

                final isDuplicate = _allRequestListAdmin
                    .any((r) => r.id == data.id && r.mobile == data.mobile);
                final isValid = _isValidRequest(data);

                if (!isDuplicate && isValid) {
                  _allRequestListAdmin.add(data);
                }
              } catch (e) {
                debugPrint(
                    'Error parsing TestDataRequest: $e for JSON: ${jsonEncode(dsLater.value)}');
              }
            }
          }
        }
      }));

      debugPrint('Fetched ${_allRequestListAdmin.length} requests from Firebase');
      await _filterData(searchInput.text);
    } catch (e) {
      debugPrint('Error fetching test requests: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }


  bool _isValidRequest(TestDataRequest data) {
    final assigningStr = data.assigning?.toString().trim() ?? "";
    final radiologyAssigningStr =
        data.radiology_assigning?.toString().trim() ?? "";

    if (assigningStr.isEmpty && radiologyAssigningStr.isEmpty) return false;

    if (type == '4') {
      return assigningStr == phone || radiologyAssigningStr == phone;
    } else if (type == '7' || phone == superUser) {
      return assigningStr.isNotEmpty || radiologyAssigningStr.isNotEmpty;
    }

    return false;
  }

  Future<void> _filterData(String searchQuery) async {
    setState(() => isLoading = true);
    _newTestRequestList.clear();
    totalCommission = 0;
    totalTestCost = 0;
    totalPaid = 0;
    totalInvoiceQuantity = 0;

    final lowerCaseQuery = searchQuery.toLowerCase();

    for (var element in _allRequestListAdmin) {
      final collectionPhone = assigningFilter == 'Pathology'
          ? element.assigning
          : element.radiology_assigning;

      final matchesSearch = lowerCaseQuery.isEmpty ||
          element.name.toLowerCase().contains(lowerCaseQuery) ||
          (collectionPhone?.toString().toLowerCase().contains(lowerCaseQuery) ??
              false);

      final matchesDate = DateFilterWithUtils.isDateInRange(
        element,
        startDatetime,
        endDatetime,
        true,
      );

      var matchesAssigningFilter = type == "4" && assigningFilter == 'Pathology'
          ? _matchesAssigning(element.assigning, phone)
          : _matchesAssigning(element.radiology_assigning, phone);

      if (type == "7" || phone == superUser) {
        matchesAssigningFilter = assigningFilter == 'Pathology'
            ? element.assigning != null &&
            element.assigning.toString().isNotEmpty
            : element.radiology_assigning != null &&
            element.radiology_assigning.toString().isNotEmpty;
      }

      final matchesPaymentStatus = _matchesPaymentStatus(element);

      if (matchesSearch &&
          matchesDate &&
          matchesAssigningFilter &&
          matchesPaymentStatus) {
        _newTestRequestList.add(element);
        _updateMetrics(element);
      }
    }

    totalInvoiceQuantity = _newTestRequestList.length;
    lastPaymentTestReq = getLatestPaymentData(_newTestRequestList);
    _sortData();

    debugPrint('Filtered ${_newTestRequestList.length} requests');
    if (mounted) setState(() => isLoading = false);
  }

  bool _matchesAssigning(dynamic assigning, String phone) {
    final value = assigning?.toString().trim();
    return value != null && value.isNotEmpty && value == phone;
  }

  bool _matchesPaymentStatus(TestDataRequest element) {
    if (paymentStatusFilter == 'Both') return true;
    if (assigningFilter == 'Pathology') {
      return paymentStatusFilter == 'Paid'
          ? element.is_pathology_paid == true
          : element.is_pathology_paid != true;
    } else {
      return paymentStatusFilter == 'Paid'
          ? element.is_radiology_paid == true
          : element.is_radiology_paid != true;
    }
  }

  void _updateMetrics(TestDataRequest element) {
    final hasValidAssigning =
    !(element.assigning?.toString().trim().isEmpty ?? true);
    final hasValidRadiologyAssigning =
    !(element.radiology_assigning?.toString().trim().isEmpty ?? true);

    if (assigningFilter == 'Pathology' && hasValidAssigning) {
      if(!(element.teststatus<=5 || element.teststatus==8)){
        totalCommission += element.assigning_commission ?? 0;
      }
      totalTestCost += element.total_payable_pathology_cost ?? 0;

      if (element.is_pathology_paid == true) {
        totalPaid += element.assigning_commission ?? 0;
      }
    } else if (assigningFilter == 'Radiology' && hasValidRadiologyAssigning) {
      if(!(element.teststatus<=5 || element.teststatus==8)){
        totalCommission += element.radiology_assigning_commission ?? 0;
      }
      totalTestCost += element.total_payable_imagine_cost ?? 0;

      if (element.is_radiology_paid == true) {
        totalPaid += element.radiology_assigning_commission ?? 0;
      }
    }
  }

  void _sortData() {
    _newTestRequestList.sort((a, b) {
      final assigningA = assigningFilter == 'Pathology'
          ? a.assigning?.toString().trim() ?? ''
          : a.radiology_assigning?.toString().trim() ?? '';

      final assigningB = assigningFilter == 'Pathology'
          ? b.assigning?.toString().trim() ?? ''
          : b.radiology_assigning?.toString().trim() ?? '';

      final nameComparison = assigningA.compareTo(assigningB);
      if (nameComparison != 0) return nameComparison;

      return (b.dateofcreated ?? 0)
          .compareTo(a.dateofcreated ?? 0); // Descending by date
    });
  }

  Future<void> _updatePay(
      TestDataRequest requestItem, String paymentType) async {
    if (requestItem.dateofcreated == null || requestItem.dateofcreated == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Cannot update payment: Invalid creation date')),
      );
      return;
    }

    try {
      final date =
      DateTime.fromMillisecondsSinceEpoch(requestItem.dateofcreated!);
      final year = date.year;
      final monthName = DateFormat('MMMM').format(date);
      final path =
          '$database_name/testRequest/$year/$monthName/${requestItem.mobile}/${requestItem.id}';
      final ref = FirebaseDatabase.instance.ref(path);

      final currentTime = DateTime.now().millisecondsSinceEpoch;
      final updateTestRequestItem =
      _createUpdatedTestRequest(requestItem, paymentType, currentTime);

      await ref.update(jsonDecode(jsonEncode(updateTestRequestItem.toJson())));

      final index = _newTestRequestList.indexWhere((item) =>
      item.id == requestItem.id && item.mobile == requestItem.mobile);
      if (index != -1) {
        _newTestRequestList[index] = updateTestRequestItem;
        _recalculateMetrics();
        setState(() {});
      }

      await _fetchData();
    } catch (e) {
      debugPrint('Error updating payment for request ${requestItem.id}: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update payment: $e')),
      );
    }
  }

  TestDataRequest _createUpdatedTestRequest(
      TestDataRequest requestItem, String paymentType, int currentTime) {
    return TestDataRequest(
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
      is_paid: requestItem.is_paid,
      total_unpayable_pathology: requestItem.total_unpayable_pathology,
      total_unpayable_imagine: requestItem.total_unpayable_imagine,
      payment_date: requestItem.payment_date,
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
      due_recieved_two_by: requestItem.due_recieved_two_by,
      pathology_payment_date: paymentType == 'Pathology'
          ? currentTime
          : requestItem.pathology_payment_date,
      radiology_payment_date: paymentType == 'Radiology'
          ? currentTime
          : requestItem.radiology_payment_date,
      is_pathology_paid:
      paymentType == 'Pathology' ? true : requestItem.is_pathology_paid,
      is_radiology_paid:
      paymentType == 'Radiology' ? true : requestItem.is_radiology_paid,
    );
  }

  void _recalculateMetrics() {
    totalCommission = 0;
    totalTestCost = 0;
    totalPaid = 0;
    for (var e in _newTestRequestList) {
      _updateMetrics(e);
    }
  }

  Future<bool> chechkingInternet() async {
    // Placeholder for internet check logic
    return true;
  }

  Future<void> _exportToPdf() async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(16),
          build: (pw.Context context) => [
            pw.Center(child:    pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  'HEALTHCARE HOMELAB',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                  textAlign: pw.TextAlign.center,
                ),
                pw.Text(
                  'Steel Mills Bazar, Patenga',
                  style: pw.TextStyle(fontSize: 12),
                  textAlign: pw.TextAlign.center,
                ),
                pw.Text(
                  '01785-890750',
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.blue,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  assigningFilter=="Pathology"?'Collection Report(Pathology)':'Collection Report (Radiology)',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 10),
              ],
            ),
            ),


            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headers: [
                'Invoice',
                'Patient Name',
                'Collection Name',
                'Collection Phone',
                'Total Test Cost',
                'Commission',
                'Payment Date',
                'Payment Status',
              ],
              data: _newTestRequestList.map((item) {
                final commission = assigningFilter == 'Pathology'
                    ? (item.assigning_commission ?? 0).toString()
                    : (item.radiology_assigning_commission ?? 0).toString();
                final testCost = assigningFilter == 'Pathology'
                    ? (item.total_payable_pathology_cost ?? 0).toString()
                    : (item.total_payable_imagine_cost ?? 0).toString();
                final collectionPhone = assigningFilter == 'Pathology'
                    ? (item.assigning ?? 'Unknown')
                    : (item.radiology_assigning ?? 'Unknown');
                final collectionName = getNameByPhoneNumber(collectionPhone);
                final paymentDate = assigningFilter == 'Pathology'
                    ? (item.pathology_payment_date ?? 0)
                    : (item.radiology_payment_date ?? 0);
                final paymentStatus = assigningFilter == 'Pathology'
                    ? (item.is_pathology_paid == true ? 'Paid' : 'Not Paid')
                    : (item.is_radiology_paid == true ? 'Paid' : 'Not Paid');

                return [
                  '#${item.invoice_call}',
                  item.name,
                  collectionName,
                  collectionPhone,
                  testCost,
                  !(item.teststatus <= 5 || item.teststatus == 8) ? commission : 'Processing',
                  paymentDate == 0
                      ? 'NA'
                      : DateFormat('dd-MMM-yyyy').format(
                      DateTime.fromMillisecondsSinceEpoch(paymentDate)),
                  paymentStatus,
                ];
              }).toList(),
              cellStyle: const pw.TextStyle(fontSize: 9),
              headerStyle:
              pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
              cellAlignment: pw.Alignment.center,
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'Last Payment Date = ${DateFormat('dd-MMM-yyyy').format(DateTime.fromMillisecondsSinceEpoch(lastPaymentTestReq?.pathology_payment_date ?? lastPaymentTestReq?.radiology_payment_date ?? 0))}',
            ),
            pw.Text('Total Invoice Quantity = $totalInvoiceQuantity'),
            pw.Text('Total Test Cost = $totalTestCost'),
            pw.Text('Total Commission = $totalCommission'),
            pw.Text('Total Paid Amount = $totalPaid'),
          ],
        ),
      );

      final baseDir = Directory(
          '/storage/emulated/0/Documents/Health Care Homelab report/collection report');
      await baseDir.create(recursive: true);

      final file = File('${baseDir.path}/collection_${assigningFilter}.pdf');
      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF saved to ${file.path}')),
      );

      final result = await OpenFile.open(file.path);
      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        backgroundColor: appTheme,
        title: Text(
          'Collection Report',
          style: TextStyle(color: secondaryColor, fontSize: DM.p30),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            (type=="7" || phone==superUser)? _buildSearchBar():const SizedBox(),
            _buildDatePickers(),
            _buildFiltersAndExport(),
            _buildDataTable(),
            _buildSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(DM.p10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: DM.p70,
            child: Text(
              'Search',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: DM.p14,
                color: blackFontColor,
              ),
            ),
          ),
          SizedBox(width: DM.p5),
          const Text(':'),
          SizedBox(width: DM.p10),
          Flexible(
            child: SizedBox(
              height: DM.p50,
              child: TextFormField(
                keyboardType: TextInputType.text,
                controller: searchInput,
                onChanged: _filterData,
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
                  hintText: 'Name or Phone Number',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: DM.p14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickers() {
    return DateFilterWithUtils(
      initialStartDate: startDatetime,
      initialEndDate: endDatetime,
      onStartDateChanged: (newStart) {
        setState(() {
          startDatetime = newStart;
          isLoading = true;
          _fetchData();
        });
      },
      onEndDateChanged: (newEnd) {
        setState(() {
          endDatetime = newEnd;
          isLoading = true;
          _fetchData();
        });
      },
    );
  }

  Widget _buildFiltersAndExport() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                      'Collection Type:',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: DM.p14,
                        color: blackFontColor,
                      ),
                    ),
                  ),
                  SizedBox(width: DM.p5),
                  const Text(':'),
                  SizedBox(width: DM.p10),
                  DropdownButton<String>(
                    value: assigningFilter,
                    items: assigningFilterList
                        .map((value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value,
                                  style: TextStyle(color: blackFontColor)),
                            ))
                        .toList(),
                    onChanged: (newValue) {
                      setState(() {
                        assigningFilter = newValue!;
                        _filterData(searchInput.text);
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
        Padding(
          padding: EdgeInsets.all(DM.p10),
          child: Row(
            children: [
              SizedBox(
                width: DM.p100,
                child: Text(
                  'Payment Status:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: DM.p14,
                    color: blackFontColor,
                  ),
                ),
              ),
              SizedBox(width: DM.p5),
              const Text(':'),
              SizedBox(width: DM.p10),
              DropdownButton<String>(
                value: paymentStatusFilter,
                items: paymentStatusFilterList
                    .map((value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value,
                              style: TextStyle(color: blackFontColor)),
                        ))
                    .toList(),
                onChanged: (newValue) {
                  setState(() {
                    paymentStatusFilter = newValue!;
                    _filterData(searchInput.text);
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDataTable() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      margin: EdgeInsets.symmetric(horizontal: DM.p5),
      child: isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(appTheme),
        ),
      )
          : ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTableHeader(),
              Divider(thickness: DM.p2, color: Colors.black),
              Expanded(
                child: Container(
                  width: (type == '7' || phone == superUser)
                      ? DM.screenWidth * 2.1
                      : DM.screenWidth * 1.9,
                  child: _newTestRequestList.isNotEmpty
                      ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: _newTestRequestList.length,
                    itemBuilder: (context, index) =>
                        _buildTableRow(_newTestRequestList[index]),
                  )
                      : Center(
                    child: Text(
                      'Request list empty',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: DM.p25,
                        color: appTheme,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      height: DM.p50,
      width: (type == '7' || phone == superUser)
          ? DM.screenWidth * 2.1
          : DM.screenWidth * 1.9,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTableCell('Invoice', width: DM.p80),
          _buildTableCell('Patient Name', width: DM.p80),
          _buildTableCell('Collection Name', width: DM.p80),
          _buildTableCell('Collection Phone', width: DM.p80),
          _buildTableCell('Total Test Cost', width: DM.p80),
          _buildTableCell('Commission', width: DM.p80),
          _buildTableCell('Payment Date', width: DM.p80),
          _buildTableCell('Payment Status', width: DM.p80),
          if (type == '7' || phone == superUser)
            _buildTableCell('Actions', width: DM.p100),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, {required double width}) {
    return Container(
      width: width,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: DM.p10,
          color: blackFontColor,
        ),
      ),
    );
  }

  Widget _buildTableRow(TestDataRequest request) {
    final commission = assigningFilter == 'Pathology'
        ? (request.assigning_commission ?? 0)
        : (request.radiology_assigning_commission ?? 0);
    final testCost = assigningFilter == 'Pathology'
        ? (request.total_payable_pathology_cost ?? 0)
        : (request.total_payable_imagine_cost ?? 0);
    final collectionPhone = assigningFilter == 'Pathology'
        ? (request.assigning ?? 'Unknown')
        : (request.radiology_assigning ?? 'Unknown');
    final collectionName = getNameByPhoneNumber(collectionPhone);
    final paymentDate = assigningFilter == 'Pathology'
        ? (request.pathology_payment_date ?? 0)
        : (request.radiology_payment_date ?? 0);
    final paymentStatus = assigningFilter == 'Pathology'
        ? (request.is_pathology_paid == true ? 'Paid' : 'Not Paid')
        : (request.is_radiology_paid == true ? 'Paid' : 'Not Paid');

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
          Container(
            width: DM.p80,
            child: Text(
              '#${request.invoice_call}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: DM.p10,
                color: blackFontColor,
              ),
            ),
          ),
          Container(
            width: DM.p80,
            child: Text(
              request.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: DM.p10,
                color: blackFontColor,
              ),
            ),
          ),
          Container(
            width: DM.p80,
            child: Text(
              collectionName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: DM.p10,
                color: blackFontColor,
              ),
            ),
          ),
          Container(
            width: DM.p80,
            child: Text(
              collectionPhone,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: DM.p10,
                color: blackFontColor,
              ),
            ),
          ),
          Container(
            width: DM.p80,
            child: Text(
              testCost.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: DM.p10,
                color: blackFontColor,
              ),
            ),
          ),
          Container(
            width: DM.p80,
            child: Text(
                !(request.teststatus <= 5 || request.teststatus == 8) ? commission.toString() : 'Processing',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: DM.p10,
                color: blackFontColor,
              ),
            ),
          ),
          Container(
            width: DM.p80,
            child: Text(
              paymentDate == 0
                  ? 'NA'
                  : DateFormat('dd-MMM-yyyy')
                  .format(DateTime.fromMillisecondsSinceEpoch(paymentDate)),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: DM.p10,
                color: blackFontColor,
              ),
            ),
          ),
          Container(
            width: DM.p80,
            child: Text(
              paymentStatus,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: DM.p10,
                color: blackFontColor,
              ),
            ),
          ),
          if (type == '7' || phone == superUser)
            Container(
              width: DM.p100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (((type == '7' && request.teststatus==6) || phone == superUser) &&
                      paymentStatus == 'Not Paid')
                    MaterialButton(
                      onPressed: () async =>
                          await _updatePay(request, assigningFilter),
                      height: DM.p40,
                      shape: const StadiumBorder(),
                      color: appTheme,
                      child: Text(
                        'Pay',
                        style: TextStyle(
                          color: fullWhiteColor,
                          fontSize: DM.p13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: DM.p10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(thickness: DM.p1, color: blackFontColor),
          Text(
            'Last Payment Date: ${DateFormat('dd-MMM-yyyy').format(DateTime.fromMillisecondsSinceEpoch(lastPaymentTestReq?.pathology_payment_date ?? lastPaymentTestReq?.radiology_payment_date ?? 0))}',
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: DM.p15,
                color: blackFontColor),
          ),
          Text(
            'Total Invoice Quantity: $totalInvoiceQuantity',
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: DM.p15,
                color: blackFontColor),
          ),
          Text(
            'Total Test Cost: $totalTestCost',
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: DM.p15,
                color: blackFontColor),
          ),
          Text(
            'Total Commission: $totalCommission',
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: DM.p15,
                color: blackFontColor),
          ),
          Text(
            'Total Paid Amount: $totalPaid',
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: DM.p15,
                color: blackFontColor),
          ),
        ],
      ),
    );
  }
}