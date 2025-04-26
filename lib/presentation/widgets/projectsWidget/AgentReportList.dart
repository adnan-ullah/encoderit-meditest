import 'dart:convert';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthcare_homelab/constants/colors.dart';
import 'package:healthcare_homelab/db/databse_model.dart';
import 'package:healthcare_homelab/state_programming/Create_Request_Controller.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/app_info.dart';
import '../../../responsives/dimensions.dart';

class AgentReportList extends StatefulWidget {
  AgentReportList({
    super.key,
  });

  @override
  State<AgentReportList> createState() => _AgentReportListState();
}

var isLoading = false;
var referrer_code = "0";
var commission;

var end_datetime = DateTime(DateTime.now().year, DateTime.now().month,
    DateTime.now().day, 23, 59, 59)
    .millisecondsSinceEpoch;

var start_datetime = DateTime(DateTime.now().year, DateTime.now().month, 1)
    .millisecondsSinceEpoch;
double totalEarning = 0;
double totalTestCost = 0;
double totalPaidAmount = 0;
List<TestDataRequest> _newTestRequestList = [];
List<TestDataRequest> _allRequestListAdmin = [];
List<String> paidStatusList = ["PAID", "UNPAID", "BOTH"];

late TabController tabController;

var type = "0";
var phone = "0";
var paidStatus = "BOTH";

Map<dynamic, int> lastPaymentDate = {};
var referrer_input = new TextEditingController(text: "0");

class _AgentReportListState extends State<AgentReportList>
    with TickerProviderStateMixin {
  CreateRequest_controller createRequest_controller =
  Get.put(CreateRequest_controller());

  int _selectedIndex = 0;

  void _onLoading(isClosed) {
    if (isClosed) {
      setState(() {
        isLoading = true;
      });
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              height: DM.p120,
              padding: EdgeInsets.all(DM.p16),
              child: new Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  new CircularProgressIndicator(
                    color: orangeColor,
                  ),
                  SizedBox(
                    width: DM.p10,
                  ),
                  new Text(
                    "Loading, please wait...",
                    style: TextStyle(color: orangeColor),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else if (!isClosed && isLoading) {
      setState(() {
        isLoading = false;
      });
      Navigator.pop(context);
    }
  }

  Future<void> _updatePay(TestDataRequest requestItem) async {
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    late DatabaseReference DbrefTestReqModel;
    DbrefTestReqModel = FirebaseDatabase.instance.ref("$database_name/");
    TestDataRequest updateTestRequestItem;
    updateTestRequestItem = TestDataRequest(
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
      radiology_assigning_commission:
      requestItem.radiology_assigning_commission,
      imageDiscountFile: requestItem.imageDiscountFile,
    );

    if (updateTestRequestItem != null) {
      await DbrefTestReqModel.child("testRequest")
          .child(updateTestRequestItem.mobile)
          .child(updateTestRequestItem.id)
          .update(jsonDecode(jsonEncode(updateTestRequestItem.toJson())));
    }

    setState(() {
      filterStatusDateTime(referrer_input.text);
    });
  }

  Future<void> getStatusData() async {
    _onLoading(true);

    SharedPreferences ref = await SharedPreferences.getInstance();
    phone = ref.getString('phoneNumber')!;
    type = ref.getString("type")!;
    if (phone != "$superUser" && type != "7") {
      commission = ref.getString("commission");
      referrer_code = ref.getString("referrer_code")!;
    }

    late DatabaseReference _dbref_testReqModel;
    _dbref_testReqModel =
    await FirebaseDatabase.instance.ref("$database_name/testRequest/");

    _dbref_testReqModel.onValue.listen((event) async {
      _newTestRequestList.clear();
      _allRequestListAdmin.clear();

      for (DataSnapshot ds in event.snapshot.children) {
        for (DataSnapshot dsLater in ds.children) {
          TestDataRequest testData =
          TestDataRequest.fromJson(json.decode(jsonEncode(dsLater.value)));
          _allRequestListAdmin.add(testData);
        }
      }

      setState(() {
        if (referrer_input.text == "0") {
          _allRequestListAdmin.map((element) {
            if (paidStatus == "BOTH") {
              _newTestRequestList.add(element);
            } else if (paidStatus == "PAID") {
              if (element.is_paid == true) _newTestRequestList.add(element);
            } else if (paidStatus == "UNPAID") {
              if (element.is_paid == false) _newTestRequestList.add(element);
            }

//last date

            if (lastPaymentDate[element] == null) lastPaymentDate[element] = 0;
            if (element.is_paid == true) if (element.payment_date >
                lastPaymentDate[element]) {
              lastPaymentDate[element] = element.payment_date;
              print("lastPaymentDate" + lastPaymentDate[element].toString());
            }
          }).toList();
        }

        if (type == "2") {
          _newTestRequestList = _allRequestListAdmin
              .where((element) =>
          element.referrer.toString() == referrer_code.toString())
              .toList();
        }
      });

      totalEarning = 0;
      totalTestCost = 0;
      totalPaidAmount = 0;

      _newTestRequestList.map((e) {
        if (e.teststatus == 6) {
          totalEarning =
              totalEarning + e.agent_commission - e.total_agent_discount;

          totalTestCost = totalTestCost + e.total_payable;

          if (e.is_paid) {
            totalPaidAmount =
                totalPaidAmount + e.agent_commission - e.total_agent_discount;
          }
        }
      }).toList();
    });

    if (_newTestRequestList != null) _onLoading(false);

//Get.back();
  }

  Future<void> filterStatusDateTime(var referrer) async {
    _newTestRequestList.clear();
// _newTestRequestList.addAll(_allRequestListAdmin);

    if (type == "2") {
      referrer = referrer_code;
    }
    var last_payment = 0;
    _allRequestListAdmin.map((element) {
      if (referrer.isNotEmpty && referrer != "0") {
        if (element.referrer.toString() == referrer &&
            (start_datetime <= element.dateofcreated &&
                element.dateofcreated <= end_datetime)) {
          if (paidStatus == "BOTH") {
            _newTestRequestList.add(element);
          } else if (paidStatus == "PAID") {
            if (element.is_paid == true) _newTestRequestList.add(element);
          } else if (paidStatus == "UNPAID") {
            if (element.is_paid == false) _newTestRequestList.add(element);
          }
        }
      } else {
        if ((start_datetime <= element.dateofcreated &&
            element.dateofcreated <= end_datetime)) {
          if (paidStatus == "BOTH") {
            _newTestRequestList.add(element);
          } else if (paidStatus == "PAID") {
            if (element.is_paid == true) _newTestRequestList.add(element);
          } else if (paidStatus == "UNPAID") {
            if (element.is_paid == false) _newTestRequestList.add(element);
          }
        }
      }

//last date
      if (lastPaymentDate[element] == null) lastPaymentDate[element] = 0;
      if (element.is_paid == true) if (element.payment_date >
          lastPaymentDate[element]) {
        lastPaymentDate[element] = element.payment_date;
        print("lastPaymentDate" + lastPaymentDate[element].toString());
      }
    }).toList();

    totalEarning = 0;
    totalTestCost = 0;
    totalPaidAmount = 0;

    _newTestRequestList.map((e) {
      if (e.teststatus == 6) {
        totalEarning =
            totalEarning + e.agent_commission - e.total_agent_discount;

        totalTestCost = totalTestCost + e.total_payable;

        if (e.is_paid) {
          totalPaidAmount =
              totalPaidAmount + e.agent_commission - e.total_agent_discount;
        }
      }
    }).toList();
  }

  Future getStoragePermission() async {
    PermissionStatus status = await Permission.storage.request();
//PermissionStatus status1 = await Permission.accessMediaLocation.request();
    PermissionStatus status2 = await Permission.manageExternalStorage.request();
    print('status $status   -> $status2');
    if (status.isGranted && status2.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied || status2.isPermanentlyDenied) {
      await openAppSettings();
    } else if (status.isDenied) {
      print('Permission Denied');
    }
  }

  Future<void> exportToPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        margin: pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text('Agent Report', style: pw.TextStyle(fontSize: 24)),
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: [
                'Invoice Call',
                type == "2" && superUser != phone ? 'Patient Name' : 'Agent Name',
                if (type != "2" || superUser == phone) 'Agent Code',
                'Pathology Total',
                'Radiology Total',
                'Total Cost',
                'Commission',
                'Discount',
                'Earning',
                'Status',
                'Payment Date',
                'Last Payment Date',
                'Payment',
              ],
              data: _newTestRequestList.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return [
                  '#${item.invoice_call}',
                  item.name,
                  if (type != "2" || superUser == phone) item.id,
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
                      ? (item.agent_commission - item.total_agent_discount).toString()
                      : 'Processing',
                  createRequest_controller.status[item.teststatus].toString(),
                  item.payment_date == 0
                      ? 'NA'
                      : DateFormat('dd-MMM-yyyy')
                      .format(DateTime.fromMillisecondsSinceEpoch(item.payment_date)),
                  lastPaymentDate[item] == 0
                      ? 'NA'
                      : DateFormat('dd-MMM-yyyy')
                      .format(DateTime.fromMillisecondsSinceEpoch(lastPaymentDate[item]!)),
                  item.is_paid ? 'Paid' : 'Not Paid',
                ];
              }).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.center,
            ),
            pw.SizedBox(height: 20),
            pw.Text('Total Test Cost = $totalTestCost',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('Total Earning = $totalEarning/- Total Paid = $totalPaidAmount',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ];
        },
      ),
    );

    // Use public Documents directory
    final baseDir = Directory('/storage/emulated/0/Documents/Health Care Homelab report/agent report');
    // Create directories if they don't exist
    await baseDir.create(recursive: true);
    // Use agent name (referrer_code) for the file name, sanitized to remove invalid characters
    final agentName = referrer_code.replaceAll(RegExp(r'[^\w\s-]'), '_');
    final file = File('${baseDir.path}/${agentName}.pdf');
    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF saved to ${file.path}')),
    );
  }

  Future<void> permissionNeed() async {
    // final status = await Permission.request();

    // var state = await Permission.manageExternalStorage.request();
    //var state2 = await Permission.storage.status;

    if (await Permission.storage.request() == true) {}
  }

  @override
  void initState() {
    permissionNeed();
    referrer_input.text = "0";
    tabController = TabController(length: 0, vsync: this, initialIndex: 0);

    _selectedIndex = tabController.index;

    Future.delayed(Duration.zero, () {
      this.getStatusData();
    });

// TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamColor,
      appBar: AppBar(backgroundColor: orangeColor, actions: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: DM.p50, vertical: DM.p10),
          width: DM.screenWidth,
          child: Text(
            "Report",
            textAlign: TextAlign.left,
            style: TextStyle(color: creamColor, fontSize: DM.p30),
          ),
        ),
      ]),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            type == "7" || phone == "$superUser"
                ? Padding(
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
                          color: blackFontColor),
                    ),
                  ),
                  SizedBox(
                    width: DM.p5,
                  ),
                  Text(":"),
                  SizedBox(
                    width: DM.p10,
                  ),
                  Flexible(
                    child: Container(
                      height: DM.p50,
                      child: TextFormField(
                        keyboardType: TextInputType.name,
                        controller: referrer_input,
// inputFormatters: <TextInputFormatter>[
//   FilteringTextInputFormatter.digitsOnly
// ],
// validator: validateMobile,
                        onEditingComplete: (() {
                          setState(() {
                            filterStatusDateTime(
                                referrer_input.text.toString());
                          });

//_formKey.currentState?.validate();
                        }),
                        decoration: InputDecoration(
                            errorStyle: TextStyle(fontSize: DM.p9),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: DM.p1, color: orangeColor)),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: DM.p1,
                                  color: orangeColor), //<-- SEE HERE
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: InputBorder.none,
                            hintText: "0",
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: DM.p14,
                            )),
                      ),
                    ),
                  ),
                ],
              ),
            )
                : SizedBox(),
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
                            backgroundColor: orangeColor, elevation: 0),
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: start_datetime == null
                                  ? DateTime(DateTime.now().year,
                                  DateTime.now().month, 1, 0, 0, 1)
                                  : DateTime.fromMillisecondsSinceEpoch(
                                  start_datetime),
                              initialDatePickerMode: DatePickerMode.day,
                              firstDate: DateTime.fromMillisecondsSinceEpoch(
                                  1669831200000),
                              lastDate: DateTime.fromMillisecondsSinceEpoch(
                                  1922292000000));
                          if (picked != null)
                            setState(() {
// end_datetime =
//     DateFormat.yMMMd().format(picked);

//start_datetime = picked.millisecondsSinceEpoch;
                              DateTime? start = DateTime(picked.year,
                                  picked.month, picked.day, 0, 0, 1);

                              start_datetime = start.millisecondsSinceEpoch;

                              filterStatusDateTime(
                                  referrer_input.text.toString());
                            });
                        },
                        child: Text(
                          "Pick a first date time ${DateFormat.yMMMd().format(DateTime.fromMillisecondsSinceEpoch(start_datetime))}",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: DM.p15,
                  ),
                  Flexible(
                    child: Container(
                      height: DM.p60,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: orangeColor, elevation: 0),
                          onPressed: () async {
                            final DateTime? picked_end = await showDatePicker(
                                context: context,
                                initialDate: end_datetime == null
                                    ? DateTime.fromMillisecondsSinceEpoch(
                                    1669831200000)
                                    : DateTime.fromMillisecondsSinceEpoch(
                                    end_datetime),
                                initialDatePickerMode: DatePickerMode.day,
                                firstDate: DateTime.fromMillisecondsSinceEpoch(
                                    1669831200000),
                                lastDate: DateTime.fromMillisecondsSinceEpoch(
                                    1922292000000));
                            if (picked_end != null)
                              setState(() {
// end_datetime =
//     DateFormat.yMMMd().format(picked);
                                DateTime? end = DateTime(
                                    picked_end.year,
                                    picked_end.month,
                                    picked_end.day,
                                    23,
                                    59,
                                    59);

                                end_datetime = end.millisecondsSinceEpoch;

                                filterStatusDateTime(
                                    referrer_input.text.toString());
                              });
                          },
                          child: Text(
                            "Pick a last date time \n ${DateFormat.yMMMd().format(DateTime.fromMillisecondsSinceEpoch(end_datetime))}",
                            textAlign: TextAlign.center,
                          )),
                    ),
                  ),
                ],
              ),
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
                              color: Color.fromARGB(255, 26, 1, 1)),
                        ),
                      ),
                      SizedBox(
                        width: DM.p5,
                      ),
                      Text(":"),
                      SizedBox(
                        width: DM.p10,
                      ),
                      DropdownButton<String>(
                        hint: Text(
                          "${paidStatus}",
                          style: TextStyle(color: blackFontColor),
                        ),
                        items: paidStatusList.map((
                            String value,
                            ) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              "${value}",
                              style: TextStyle(color: blackFontColor),
                            ),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            paidStatus = newValue!;
                            filterStatusDateTime(referrer_input.text);
                          });
                        },
                      ),
                    ],
                  ),
                ),
                // Add Export to PDF button
                Padding(
                  padding: EdgeInsets.all(DM.p10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orangeColor,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(
                          horizontal: DM.p20, vertical: DM.p15),
                    ),
                    onPressed: () async {
                      await exportToPdf();
                    },
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
                        width: DM.screenWidth * 2.7,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: DM.p80,
                              child: Text(
                                "Invoice Call",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: DM.p10,
                                    color: Color.fromARGB(255, 26, 1, 1)),
                              ),
                            ),
                            type == "2" && superUser != phone
                                ? Container(
                              width: DM.p80,
                              child: Text(
                                "Patient Name",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: DM.p10,
                                    color: Color.fromARGB(255, 26, 1, 1)),
                              ),
                            )
                                : Row(
                              children: [
                                Container(
                                  width: DM.p80,
                                  child: Text(
                                    "Agent Name",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: DM.p10,
                                        color: Color.fromARGB(
                                            255, 26, 1, 1)),
                                  ),
                                ),
                                Container(
                                  width: DM.p80,
                                  child: Text(
                                    "Agent Code",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: DM.p10,
                                        color: Color.fromARGB(
                                            255, 26, 1, 1)),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: DM.p80,
                              child: Text(
                                "Pathology Total",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: DM.p10,
                                    color: Color.fromARGB(255, 26, 1, 1)),
                              ),
                            ),
                            Container(
                              width: DM.p80,
                              child: Text(
                                "Radiology Total",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: DM.p10,
                                    color: Color.fromARGB(255, 26, 1, 1)),
                              ),
                            ),
                            Container(
                              width: DM.p80,
                              child: Text(
                                "Total Cost",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: DM.p10,
                                    color: Color.fromARGB(255, 26, 1, 1)),
                              ),
                            ),
                            Container(
                              width: DM.p80,
                              child: Text(
                                "Commission",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: DM.p10,
                                    color: Color.fromARGB(255, 26, 1, 1)),
                              ),
                            ),
                            Container(
                              width: DM.p80,
                              child: Text(
                                "Discount",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: DM.p10,
                                    color: Color.fromARGB(255, 26, 1, 1)),
                              ),
                            ),
                            Container(
                              width: DM.p80,
                              child: Text(
                                "Earning",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: DM.p10,
                                    color: Color.fromARGB(255, 26, 1, 1)),
                              ),
                            ),
                            Container(
                              width: DM.p80,
                              child: Text(
                                "Status",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: DM.p10,
                                    color: Color.fromARGB(255, 26, 1, 1)),
                              ),
                            ),
                            Container(
                              width: DM.p80,
                              child: Text(
                                "Payment Date",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: DM.p10,
                                    color: Color.fromARGB(255, 26, 1, 1)),
                              ),
                            ),
                            Container(
                              width: DM.p80,
                              child: Text(
                                "Last Payment Date",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: DM.p10,
                                    color: Color.fromARGB(255, 26, 1, 1)),
                              ),
                            ),
                            Container(
                              width: DM.p80,
                              child: Text(
                                "Payment",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: DM.p10,
                                    color: Color.fromARGB(255, 26, 1, 1)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: isLoading == false
                            ? Container(
                            height: DM.screenHeight * 0.50,
                            width: DM.screenWidth * 2.7,
                            child: _newTestRequestList.isNotEmpty
                                ? Container(
                              height: DM.p100,
                              child: Column(
                                children: [
                                  Divider(
                                    thickness: DM.p2,
                                    color: Colors.black,
                                  ),
                                  Container(
                                    height: DM.screenHeight * 0.50,
                                    width: DM.screenWidth * 2.7,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount:
                                      _newTestRequestList.length,
                                      itemBuilder: (context, index) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: whiteColor,
                                            borderRadius:
                                            BorderRadius.circular(
                                                DM.p10),
                                          ),
                                          margin:
                                          EdgeInsets.symmetric(
                                              vertical: DM.p5),
                                          height: DM.p60,
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                            children: [
                                              Container(
                                                width: DM.p80,
                                                child: Text(
                                                  "#${_newTestRequestList[index].invoice_call.toString()}",
                                                  textAlign: TextAlign
                                                      .center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                      FontWeight
                                                          .w900,
                                                      fontSize:
                                                      DM.p10,
                                                      color: Color
                                                          .fromARGB(
                                                          255,
                                                          26,
                                                          1,
                                                          1)),
                                                ),
                                              ),
                                              type == "2" &&
                                                  superUser !=
                                                      phone
                                                  ? Container(
                                                width: DM.p80,
                                                child: Text(
                                                  "${_newTestRequestList[index].name.toString()}",
                                                  textAlign:
                                                  TextAlign
                                                      .center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                      FontWeight
                                                          .w900,
                                                      fontSize: DM
                                                          .p10,
                                                      color: Color
                                                          .fromARGB(
                                                          255,
                                                          26,
                                                          1,
                                                          1)),
                                                ),
                                              )
                                                  : Row(
                                                children: [
                                                  Container(
                                                    width:
                                                    DM.p80,
                                                    child: Text(
                                                      "${_newTestRequestList[index].name.toString()}",
                                                      textAlign:
                                                      TextAlign
                                                          .center,
                                                      style: TextStyle(
                                                          fontWeight: FontWeight
                                                              .w900,
                                                          fontSize: DM
                                                              .p10,
                                                          color: Color.fromARGB(
                                                              255,
                                                              26,
                                                              1,
                                                              1)),
                                                    ),
                                                  ),
                                                  Container(
                                                    width:
                                                    DM.p80,
                                                    child: Text(
                                                      "${_newTestRequestList[index].id.toString()}",
                                                      textAlign:
                                                      TextAlign
                                                          .center,
                                                      style: TextStyle(
                                                          fontWeight: FontWeight
                                                              .w900,
                                                          fontSize: DM
                                                              .p10,
                                                          color: Color.fromARGB(
                                                              255,
                                                              26,
                                                              1,
                                                              1)),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              _newTestRequestList[
                                              index]
                                                  .teststatus !=
                                                  1
                                                  ? SizedBox(
                                                width: DM.p80,
                                                child: Text(
                                                  "${(_newTestRequestList[index].total_payable_pathology_cost).toString()}",
                                                  textAlign:
                                                  TextAlign
                                                      .center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                      FontWeight
                                                          .w900,
                                                      fontSize: DM
                                                          .p10,
                                                      color: Color
                                                          .fromARGB(
                                                          255,
                                                          26,
                                                          1,
                                                          1)),
                                                ),
                                              )
                                                  : SizedBox(
                                                width: DM.p80,
                                                child: Text(
                                                  "Processing",
                                                  textAlign:
                                                  TextAlign
                                                      .center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                      FontWeight
                                                          .w900,
                                                      fontSize: DM
                                                          .p10,
                                                      color: Color
                                                          .fromARGB(
                                                          255,
                                                          26,
                                                          1,
                                                          1)),
                                                ),
                                              ),
                                              _newTestRequestList[
                                              index]
                                                  .teststatus !=
                                                  1
                                                  ? SizedBox(
                                                width: DM.p80,
                                                child: Text(
                                                  "${(_newTestRequestList[index].total_payable_imagine_cost).toString()}",
                                                  textAlign:
                                                  TextAlign
                                                      .center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                      FontWeight
                                                          .w900,
                                                      fontSize: DM
                                                          .p10,
                                                      color: Color
                                                          .fromARGB(
                                                          255,
                                                          26,
                                                          1,
                                                          1)),
                                                ),
                                              )
                                                  : SizedBox(
                                                width: DM.p80,
                                                child: Text(
                                                  "Processing",
                                                  textAlign:
                                                  TextAlign
                                                      .center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                      FontWeight
                                                          .w900,
                                                      fontSize: DM
                                                          .p10,
                                                      color: Color
                                                          .fromARGB(
                                                          255,
                                                          26,
                                                          1,
                                                          1)),
                                                ),
                                              ),
                                              _newTestRequestList[
                                              index]
                                                  .teststatus !=
                                                  1
                                                  ? SizedBox(
                                                width: DM.p80,
                                                child: Text(
                                                  "${(_newTestRequestList[index].total_payable).toString()}",
                                                  textAlign:
                                                  TextAlign
                                                      .center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                      FontWeight
                                                          .w900,
                                                      fontSize: DM
                                                          .p10,
                                                      color: Color
                                                          .fromARGB(
                                                          255,
                                                          26,
                                                          1,
                                                          1)),
                                                ),
                                              )
                                                  : SizedBox(
                                                width: DM.p80,
                                                child: Text(
                                                  "Processing",
                                                  textAlign:
                                                  TextAlign
                                                      .center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                      FontWeight
                                                          .w900,
                                                      fontSize: DM
                                                          .p10,
                                                      color: Color
                                                          .fromARGB(
                                                          255,
                                                          26,
                                                          1,
                                                          1)),
                                                ),
                                              ),
                                              _newTestRequestList[
                                              index]
                                                  .teststatus !=
                                                  1
                                                  ? SizedBox(
                                                width: DM.p80,
                                                child: Text(
                                                  _newTestRequestList[
                                                  index]
                                                      .agent_commission
                                                      .toString(),
                                                  textAlign:
                                                  TextAlign
                                                      .center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                      FontWeight
                                                          .w900,
                                                      fontSize: DM
                                                          .p10,
                                                      color: Color
                                                          .fromARGB(
                                                          255,
                                                          26,
                                                          1,
                                                          1)),
                                                ),
                                              )
                                                  : SizedBox(
                                                width: DM.p80,
                                                child: Text(
                                                  "Processing",
                                                  textAlign:
                                                  TextAlign
                                                      .center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                      FontWeight
                                                          .w900,
                                                      fontSize: DM
                                                          .p10,
                                                      color: Color
                                                          .fromARGB(
                                                          255,
                                                          26,
                                                          1,
                                                          1)),
                                                ),
                                              ),
                                              _newTestRequestList[
                                              index]
                                                  .teststatus !=
                                                  1
                                                  ? SizedBox(
                                                width: DM.p80,
                                                child: Text(
                                                  _newTestRequestList[
                                                  index]
                                                      .total_agent_discount
                                                      .toString(),
                                                  textAlign:
                                                  TextAlign
                                                      .center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                      FontWeight
                                                          .w900,
                                                      fontSize: DM
                                                          .p10,
                                                      color: Color
                                                          .fromARGB(
                                                          255,
                                                          26,
                                                          1,
                                                          1)),
                                                ),
                                              )
                                                  : SizedBox(
                                                width: DM.p80,
                                                child: Text(
                                                  "Processing",
                                                  textAlign:
                                                  TextAlign
                                                      .center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                      FontWeight
                                                          .w900,
                                                      fontSize: DM
                                                          .p10,
                                                      color: Color
                                                          .fromARGB(
                                                          255,
                                                          26,
                                                          1,
                                                          1)),
                                                ),
                                              ),
                                              _newTestRequestList[
                                              index]
                                                  .teststatus ==
                                                  6
                                                  ? SizedBox(
                                                width: DM.p80,
                                                child: Text(
                                                  (_newTestRequestList[index]
                                                      .agent_commission -
                                                      _newTestRequestList[index]
                                                          .total_agent_discount)
                                                      .toString(),
                                                  textAlign:
                                                  TextAlign
                                                      .center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                      FontWeight
                                                          .w900,
                                                      fontSize: DM
                                                          .p10,
                                                      color: Color
                                                          .fromARGB(
                                                          255,
                                                          26,
                                                          1,
                                                          1)),
                                                ),
                                              )
                                                  : SizedBox(
                                                width: DM.p80,
                                                child: Text(
                                                  "Processing",
                                                  textAlign:
                                                  TextAlign
                                                      .center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                      FontWeight
                                                          .w900,
                                                      fontSize: DM
                                                          .p10,
                                                      color: Color
                                                          .fromARGB(
                                                          255,
                                                          26,
                                                          1,
                                                          1)),
                                                ),
                                              ),
                                              SizedBox(
                                                width: DM.p80,
                                                child: Text(
                                                  createRequest_controller
                                                      .status[_newTestRequestList[
                                                  index]
                                                      .teststatus]
                                                      .toString(),
                                                  textAlign: TextAlign
                                                      .center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                      FontWeight
                                                          .w900,
                                                      fontSize:
                                                      DM.p10,
                                                      color: Color
                                                          .fromARGB(
                                                          255,
                                                          26,
                                                          1,
                                                          1)),
                                                ),
                                              ),
                                              SizedBox(
                                                width: DM.p80,
                                                child: _newTestRequestList[
                                                index]
                                                    .payment_date ==
                                                    0
                                                    ? Text(
                                                  "NA",
                                                  textAlign:
                                                  TextAlign
                                                      .center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                      FontWeight
                                                          .w900,
                                                      fontSize: DM
                                                          .p10,
                                                      color: Color
                                                          .fromARGB(
                                                          255,
                                                          26,
                                                          1,
                                                          1)),
                                                )
                                                    : Text(
                                                  (DateFormat('dd-MMM-yyyy')
                                                      .format(
                                                      DateTime.fromMillisecondsSinceEpoch(_newTestRequestList[index].payment_date)))
                                                      .toString(),
                                                  textAlign:
                                                  TextAlign
                                                      .center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                      FontWeight
                                                          .w900,
                                                      fontSize: DM
                                                          .p10,
                                                      color: Color
                                                          .fromARGB(
                                                          255,
                                                          26,
                                                          1,
                                                          1)),
                                                ),
                                              ),
                                              SizedBox(
                                                width: DM.p80,
                                                child: _newTestRequestList[
                                                index]
                                                    .payment_date ==
                                                    0
                                                    ? Text(
                                                  "NA",
                                                  textAlign:
                                                  TextAlign
                                                      .center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                      FontWeight
                                                          .w900,
                                                      fontSize: DM
                                                          .p10,
                                                      color: Color
                                                          .fromARGB(
                                                          255,
                                                          26,
                                                          1,
                                                          1)),
                                                )
                                                    : Text(
                                                  (DateFormat('dd-MMM-yyyy')
                                                      .format(
                                                      DateTime.fromMillisecondsSinceEpoch(lastPaymentDate[_newTestRequestList[index]]!)))
                                                      .toString(),
                                                  textAlign:
                                                  TextAlign
                                                      .center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                      FontWeight
                                                          .w900,
                                                      fontSize: DM
                                                          .p10,
                                                      color: Color
                                                          .fromARGB(
                                                          255,
                                                          26,
                                                          1,
                                                          1)),
                                                ),
                                              ),
                                              SizedBox(
                                                  width: DM.p80,
                                                  child: _newTestRequestList[
                                                  index]
                                                      .is_paid
                                                      ? Text(
                                                    "Paid",
                                                    textAlign:
                                                    TextAlign
                                                        .center,
                                                    style: TextStyle(
                                                        fontWeight:
                                                        FontWeight
                                                            .w900,
                                                        fontSize: DM
                                                            .p10,
                                                        color: Color.fromARGB(
                                                            255,
                                                            26,
                                                            1,
                                                            1)),
                                                  )
                                                      : (type == "7" ||
                                                      phone ==
                                                          "$superUser")
                                                      ? MaterialButton(
                                                    onPressed:
                                                        () async {
                                                      _updatePay(
                                                          _newTestRequestList[index]);
                                                    },
                                                    height:
                                                    DM.p40,
                                                    shape:
                                                    const StadiumBorder(),
                                                    color:
                                                    orangeColor,
                                                    child:
                                                    Text(
                                                      "Pay",
                                                      textAlign:
                                                      TextAlign.center,
                                                      style: TextStyle(
                                                          color: fullWhiteColor,
                                                          fontSize: DM.p13,
                                                          fontWeight: FontWeight.bold),
                                                    ),
                                                  )
                                                      : Text(
                                                    "Not Paid",
                                                    textAlign:
                                                    TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight: FontWeight
                                                            .w900,
                                                        fontSize: DM
                                                            .p10,
                                                        color: Color.fromARGB(
                                                            255,
                                                            26,
                                                            1,
                                                            1)),
                                                  ))
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            )
                                : Container(
                                height: DM.screenHeight * 0.65,
                                margin: EdgeInsets.symmetric(
                                    vertical: DM.p16),
                                child: Text(
                                  "Request list empty ",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: DM.p25,
                                      color: orangeColor),
                                )))
                            : SizedBox(),
                      )
                    ],
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: DM.p10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(
                      thickness: DM.p1,
                      color: blackFontColor,
                    ),
                    Text(
                      "Total Test Cost =  ${totalTestCost}",
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: DM.p15,
                          color: Color.fromARGB(255, 26, 1, 1)),
                    ),
                  ]),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: DM.p10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(
                      thickness: DM.p1,
                      color: blackFontColor,
                    ),
                    Text(
                      "Total Earning =  ${totalEarning}/- Total Paid = ${totalPaidAmount}",
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: DM.p15,
                          color: Color.fromARGB(255, 26, 1, 1)),
                    ),
                  ]),
            ),
          ],
        ),
      ),
    );
  }

//Return String
}
