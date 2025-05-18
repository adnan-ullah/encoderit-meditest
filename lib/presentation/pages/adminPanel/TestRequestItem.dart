import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthcare_homelab/constants/api.dart';
import 'package:healthcare_homelab/presentation/pages/adminPanel/TestListDialogueAdmin.dart';
import 'package:healthcare_homelab/presentation/widgets/otherWidgets/MyDialogView.dart';
import 'package:healthcare_homelab/presentation/widgets/projectsWidget/FormUserAge.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/app_info.dart';
import '../../../constants/colors.dart';
import '../../../db/models/AdminUserModel.dart';
import '../../../db/models/TestData.dart';
import '../../../db/models/TestDataRequest.dart';
import '../../../responsives/dimensions.dart';
import '../../../state_programming/CreateRequestController.dart';
import '../../widgets/otherWidgets/PhotoViewImage.dart';
import '../Invoice_pdf/api/pdf_api.dart';
import '../Invoice_pdf/api/pdf_invoice_api.dart';
import '../Invoice_pdf/api/pdf_invoice_no_customer.dart';
import '../Invoice_pdf/model/customer.dart';
import '../Invoice_pdf/model/invoice.dart';
import '../LoginScreen.dart';

class TestRequestCreate extends StatefulWidget {
  TestDataRequest? testEachRequest;

  TestRequestCreate({Key? key, this.testEachRequest}) : super(key: key);

  @override
  _TestRequestCreateState createState() => _TestRequestCreateState();
}

class _TestRequestCreateState extends State<TestRequestCreate> {
  bool isTestlistOpen = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  dynamic latitude;
  dynamic longitude;
  var dateTime_delivery;
  var updateTestRequestItem;
  var name = new TextEditingController();
  String gender = "Male";
  var phone = new TextEditingController();
  var age = new TextEditingController();
  var totalprice = new TextEditingController();
  var servicecharge = new TextEditingController();
  var address = new TextEditingController();
  var referrer = new TextEditingController();
  var lastupdate = new TextEditingController();
  var dateofcreated = new TextEditingController();
  var softdelete = new TextEditingController();

  var teststatus = new TextEditingController();
  var invoice_call = new TextEditingController();
  var type = new TextEditingController();
  var image_one = new TextEditingController();
  var image_two = new TextEditingController();
  var image_discount_card = new TextEditingController();

  var comments = new TextEditingController();
  var delivery_date = new TextEditingController();

  var advanced = new TextEditingController();
  var due_amount = new TextEditingController();
  var due_recieved_one = new TextEditingController();
  var due_recieved_two = new TextEditingController();
  var admin_discount = new TextEditingController();

  var agent_discount = new TextEditingController();
  var total_discount = new TextEditingController();
  var agent_commission = new TextEditingController();

  var admin_pathology_discount = new TextEditingController();
  var admin_radiology_discount = new TextEditingController();
  var agent_pathology_discount = new TextEditingController();
  var agent_radiology_discount = new TextEditingController();

  var assigning_commission = new TextEditingController();
  var radiology_assigning_commission = new TextEditingController();

  bool isReadOnlyDueReceivedOne = true;
  bool isReadOnlyDueReceivedTwo = true;
  bool handleFirstTimeInitPage = false;

  List<TestData> testItemList = [];
  List<AdminUserModel> adminUserList = [];
  List<TestData> testData_updated = [];

  Map<String, bool> testItemListWithSelected = {};
  var totalTestCost = 0;
  var totalCost = 0;
  var serviceCost = 0;
  var tubeCost = 0;
  var totalDiscount = 0;
  var totalDueRecievedOne = 0;
  var totalDueRecievedTwo = 0;
  var test_item_cost = 0;
  var test_item_discount = 0;
  var total_payable_pathology = 0;
  var total_payable_imaging = 0;
  var total_unpayable_pathology = 0;
  var total_unpayable_imaging = 0;
  var total_payable_item = 0;
  var total_unpayable_item = 0;
  var totalCashRecieve = 0;
  var urlDownload1;
  var urlDownload2;
  var urlDownload3;
  var newRequestData;
  var paymentDate;
  bool isFromNetwork1 = false;
  bool isFromNetwork2 = false;
  bool isFromNetwork_discount = false;
  File? imageFile1, imageFile2, imageDiscountFile;
  UploadTask? uploadTask1, uploadTask2, uploadTask3;
  bool init = false;
  var phoneNumber = "";
  var typeUser = "";

  List<AdminUserModel> collectionUserList = [];
  String pathologyAssigningPhone = "";
  String radiologyAssigningPhone = "";
  Map<String, String> assigningMapping = {"": ""};
  bool pathologyDone = false;
  bool radiologyDone = false;

  Future<void> _getTestItemList() async {
    testItemList.clear();
    testItemListWithSelected.clear();

    List<String> paths = getLastSixMonthTestDataPaths();
    List<TestData> allItems = [];

    for (String path in paths) {
      final dbRef = FirebaseDatabase.instance.ref(path);
      final snapshot = await dbRef.get();

      if (snapshot.exists) {
        for (DataSnapshot ds in snapshot.children) {
          Map<String, dynamic> json = jsonDecode(jsonEncode(ds.value));
          json['id'] = ds.key;
          final item = TestData.fromJson(json);
          if (!allItems.any((e) => e.id == item.id)) {
            setState(() {
              testItemList.add(item);
              testItemListWithSelected[item.id] ??= false;
            });
          }
        }
      }
    }
  }

  Future<void> getAdminUserList() async {
    FirebaseDatabase.instance.setPersistenceEnabled(true);

    final dbRefTestModel = FirebaseDatabase.instance.ref(adminUserApi);
    dbRefTestModel.keepSynced(true);

    dbRefTestModel.onValue.listen((event) {
      final List<AdminUserModel> tempAdminUsers = [];
      final List<AdminUserModel> tempCollectionUsers = [];
      final Map<String, String> tempAssigningMapping = {};

      for (DataSnapshot ds in event.snapshot.children) {
        final data = ds.value;
        if (data == null) continue;

        final testData = AdminUserModel.fromJson(json.decode(jsonEncode(data)));
        tempAdminUsers.add(testData);

        if (testData.type == "4") {
          tempCollectionUsers.add(testData);
          tempAssigningMapping[testData.phone ?? ""] = testData.name ?? "";
        }
      }

      setState(() {
        adminUserList = tempAdminUsers;
        collectionUserList = tempCollectionUsers;
        assigningMapping = tempAssigningMapping;
        calculationProcess();
      });
    });
  }

  Future<String?> getLoggedUserName() async {
    final refs = await SharedPreferences.getInstance();
    final phoneNumber = refs.getString("phoneNumber");
    final typeUser = refs.getString("type");

    if (phoneNumber == "$superUser") return "Super User";

    if (phoneNumber == null || typeUser == null) {
      return null;
    }
    final matchingUser = adminUserList.firstWhere(
        (user) => user.phone == phoneNumber && user.type == typeUser);
    return matchingUser.name;
  }

  Future<void> openMap(double latitude, double longitude) async {
    if (await MapLauncher.isMapAvailable(MapType.google) != null) {
      await MapLauncher.showMarker(
        zoom: 1000,
        mapType: MapType.google,
        coords: Coords(latitude, longitude),
        title: "title",
        description: "description",
      );
    }
  }

  Future<void> retreiveEachDataRequest() async {
    SharedPreferences refs = await SharedPreferences.getInstance();
    phoneNumber = refs.getString("phoneNumber")!;
    typeUser = refs.getString("type")!;

    int currentTime = DateTime.now().millisecondsSinceEpoch;
    type.text =
        createReqController.typeName[widget.testEachRequest!.type].toString();
    invoice_call.text = widget.testEachRequest!.invoice_call.toString();
    name.text = widget.testEachRequest!.name.toString();
    age.text = widget.testEachRequest!.age.toString();
    phone.text = widget.testEachRequest!.mobile.toString();
    address.text = widget.testEachRequest!.address.toString();
    referrer.text = widget.testEachRequest!.referrer.toString();
    servicecharge.text = widget.testEachRequest!.servicecharge.toString();
    totalprice.text = widget.testEachRequest!.totalprice.toString();
    teststatus.text = widget.testEachRequest!.teststatus.toString();

    if (widget.testEachRequest!.delivery_date != null) {
      dateTime_delivery = widget.testEachRequest!.delivery_date;
      delivery_date.text = (DateFormat.yMMMd().format(
          DateTime.fromMillisecondsSinceEpoch(
              widget.testEachRequest!.delivery_date)));
    } else {
      dateTime_delivery = currentTime + 86400000;

      delivery_date.text = (DateFormat.yMMMd()
          .format(DateTime.fromMillisecondsSinceEpoch(currentTime + 86400000)));
    }

    if (teststatus.text.contains("2")) {
      dateTime_delivery = DateTime(DateTime.now().year, DateTime.now().month,
              DateTime.now().day + 1, 20, 0, 0)
          .millisecondsSinceEpoch;

      delivery_date.text = (DateFormat.yMMMd()
          .format(DateTime.fromMillisecondsSinceEpoch(dateTime_delivery)));
    }

    if (widget.testEachRequest!.comments != null)
      comments.text = widget.testEachRequest!.comments;
    else
      comments.text = "";

    if (widget.testEachRequest!.advanced != null)
      advanced.text = widget.testEachRequest!.advanced.toString();
    else
      advanced.text = "0";

    if (widget.testEachRequest!.total_admin_discount != null)
      admin_discount.text =
          widget.testEachRequest!.total_admin_discount.toString();
    else
      admin_discount.text = "0";

    if (widget.testEachRequest!.total_agent_discount != null)
      agent_discount.text =
          widget.testEachRequest!.total_agent_discount.toString();
    else
      agent_discount.text = "0";

    if (widget.testEachRequest!.total_discount != null)
      total_discount.text = widget.testEachRequest!.total_discount.toString();
    else
      total_discount.text = "0";

    if (widget.testEachRequest!.due_amount != null)
      due_amount.text = widget.testEachRequest!.due_amount.toString();
    else
      due_amount.text = totalprice.text.toString();

    if (widget.testEachRequest!.due_recieved_two != null)
      due_recieved_two.text = widget.testEachRequest!.due_recieved_two.toString();
    else{
      due_recieved_two.text = "0";

      setState(() {
        isReadOnlyDueReceivedTwo = false;
      });

    }

    if (widget.testEachRequest!.due_recieved_one != null)
      due_recieved_one.text = widget.testEachRequest!.due_recieved_one.toString();
    else{
      isReadOnlyDueReceivedOne = false;
      setState(() {
        isReadOnlyDueReceivedOne = false;
      });
      due_recieved_one.text = "0";
    }


    if (widget.testEachRequest!.testlist != null) {
      widget.testEachRequest!.testlist!.map((e) {
        testData_updated.add(e);
        testItemListWithSelected[e.id] = true;
      }).toList();
    }

    print(widget.testEachRequest!.image_one.toString() + "avvv");

    if (widget.testEachRequest!.image_one == null)
      image_one.text = "empty";
    else {
      setState(() {
        isFromNetwork1 = true;
      });

      image_one.text = widget.testEachRequest!.image_one.toString();
    }

    if (widget.testEachRequest!.image_two == null)
      image_two.text = "empty";
    else {
      image_two.text = widget.testEachRequest!.image_two.toString();
      setState(() {
        isFromNetwork2 = true;
      });
    }

    setState(() {
      gender = widget.testEachRequest!.gender;
    });
    softdelete.text = widget.testEachRequest!.softdelete.toString();

    lastupdate.text = currentTime.toString();
    dateofcreated.text = (DateFormat('EEE, dd MMM, yyy').format(
            DateTime.fromMillisecondsSinceEpoch(
                widget.testEachRequest!.dateofcreated)))
        .toString();

    setState(() {
      latitude = widget.testEachRequest!.latitude.toString();
      longitude = widget.testEachRequest!.longitude.toString();
    });

    if (widget.testEachRequest!.test_item_cost != null)
      test_item_cost = widget.testEachRequest!.test_item_cost;
    else
      test_item_cost = 0;

    if (widget.testEachRequest!.test_item_discount != null)
      test_item_discount = widget.testEachRequest!.test_item_discount;
    else
      test_item_discount = 0;

    if (widget.testEachRequest!.admin_pathology_discount != null)
      admin_pathology_discount.text =
          widget.testEachRequest!.admin_pathology_discount.toString();
    else
      admin_pathology_discount.text = "0";

    if (widget.testEachRequest!.admin_radiology_discount != null)
      admin_radiology_discount.text =
          widget.testEachRequest!.admin_radiology_discount.toString();
    else
      admin_radiology_discount.text = "0";

    if (widget.testEachRequest!.agent_pathology_discount != null)
      agent_pathology_discount.text =
          widget.testEachRequest!.agent_pathology_discount.toString();
    else
      agent_pathology_discount.text = "0";

    if (widget.testEachRequest!.agent_radiology_discount != null)
      agent_radiology_discount.text =
          widget.testEachRequest!.agent_radiology_discount.toString();
    else
      agent_radiology_discount.text = "0";

    agent_commission.text = "0";
    if (widget.testEachRequest!.agent_commission == null) {
      agent_commission.text = "0";
    } else {
      agent_commission.text =
          widget.testEachRequest!.agent_commission!.toString();
    }

    //new
    if (widget.testEachRequest!.pathology_done == null) {
      pathologyDone = false;
    } else {
      pathologyDone = widget.testEachRequest!.pathology_done;
    }
    if (widget.testEachRequest!.radiology_done == null) {
      radiologyDone = false;
    } else {
      radiologyDone = widget.testEachRequest!.radiology_done;
    }
    if (widget.testEachRequest!.assigning == null) {
      pathologyAssigningPhone = "";
    } else {
      pathologyAssigningPhone = widget.testEachRequest!.assigning;
    }

    if (widget.testEachRequest!.radiology_assigning == null) {
      radiologyAssigningPhone = "";
    } else {
      radiologyAssigningPhone = widget.testEachRequest!.radiology_assigning;
    }

    if (widget.testEachRequest!.assigning_commission == null || widget.testEachRequest!.assigning_commission.toString().isEmpty) {
      assigning_commission.text  = "0";
    } else {
      assigning_commission.text  = widget.testEachRequest!.assigning_commission.toString();
    }
    if (widget.testEachRequest!.radiology_assigning_commission == null || widget.testEachRequest!.radiology_assigning_commission.toString().isEmpty) {
      radiology_assigning_commission.text  = "0";
    } else {
      radiology_assigning_commission.text  = widget.testEachRequest!.radiology_assigning_commission.toString();
    }

    if (widget.testEachRequest!.imageDiscountFile == null)
      image_discount_card.text = "empty";
    else {
      setState(() {
        isFromNetwork_discount = true;
      });
      image_discount_card.text =
          widget.testEachRequest!.imageDiscountFile.toString();
    }

   testItemUpdatedData();
  }

  void _onLoading(isClosed) {
    if (isClosed) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              height: DM.p80,
              padding: EdgeInsets.all(DM.p16),
              child: new Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  new CircularProgressIndicator(
                    color: appTheme,
                  ),
                  SizedBox(
                    width: DM.p10,
                  ),
                  new Text(
                    "Submitting, please wait...",
                    style: TextStyle(color: appTheme),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    if (!isClosed) Navigator.pop(context);
    //pop dialog
  }

  Future<void> uploadImage() async {
    _onLoading(true);

    final SharedPreferences pref = await SharedPreferences.getInstance();

    final path1 = "$storageFiles/${phone.text}/${imageFile1}";
    final path2 = "$storageFiles/${phone.text}/${imageFile2}";
    final path3 = "$storageFiles/${phone.text}/${imageDiscountFile}";

    final ref1 = FirebaseStorage.instance.ref().child(path1);
    final ref2 = FirebaseStorage.instance.ref().child(path2);
    final ref3 = FirebaseStorage.instance.ref().child(path3);

    if (imageFile1 != null) {
      uploadTask1 = ref1.putFile(imageFile1!);
      final snapshot1 = await uploadTask1!.whenComplete(() {});
      urlDownload1 = await snapshot1.ref.getDownloadURL();
    }

    if (imageFile2 != null) {
      uploadTask2 = ref2.putFile(imageFile2!);
      final snapshot2 = await uploadTask2!.whenComplete(() {});
      urlDownload2 = await snapshot2.ref.getDownloadURL();
    }

    if (imageDiscountFile != null) {
      uploadTask3 = ref3.putFile(imageDiscountFile!);
      final snapshot3 = await uploadTask3!.whenComplete(() {});
      urlDownload3 = await snapshot3.ref.getDownloadURL();
    }

    //addImages(urlDownload1, urlDownload2);

    _updateRequest();
    _onLoading(false);
  }

  Future<void> _updateRequest() async {
    int currentTime = DateTime.now().millisecondsSinceEpoch;

    DateTime createdDate = DateTime.fromMillisecondsSinceEpoch(
        widget.testEachRequest?.dateofcreated ?? currentTime);
    String year = createdDate.year.toString();
    String month = getMonthName(createdDate.month);

    String path = "$database_name/testRequest/$year/$month";
    DatabaseReference dbRef = FirebaseDatabase.instance.ref(path);

    admin_discount.text =
        admin_discount.text.isEmpty ? "0" : admin_discount.text;
    agent_discount.text =
        agent_discount.text.isEmpty ? "0" : agent_discount.text;

    if (urlDownload1 != null) image_one.text = urlDownload1!;
    if (urlDownload2 != null) image_two.text = urlDownload2!;
    if (urlDownload3 != null) image_discount_card.text = urlDownload3!;

    if (typeUser == "4") {
      teststatus.text = (pathologyDone && radiologyDone) ? "3" : "8";
    }

    TestDataRequest buildRequest({
      String? due_recieved_one_by,
      String? due_recieved_two_by,
      String? advance_recieved_by,
      String? preparedBy,
      String? lastModifier,
      int? dueReceivedOneDate,
      int? dueReceivedTwoDate,
      int? advancedPaymentDate,
    }) {
      return TestDataRequest(
        id: widget.testEachRequest!.id!,
        name: name.text.toUpperCase(),
        gender: gender,
        mobile: phone.text,
        age: age.text,
        testlist: testData_updated,
        totalprice: totalCost,
        servicecharge: serviceCost,
        address: address.text,
        referrer: referrer.text,
        lastupdate: currentTime,
        dateofcreated: widget.testEachRequest!.dateofcreated,
        softdelete: 0,
        latitude: widget.testEachRequest!.latitude,
        longitude: widget.testEachRequest!.longitude,
        teststatus: int.parse(teststatus.text),
        invoice_call: invoice_call.text,
        type: createReqController.toType[type.text] ?? 0,
        image_one: image_one.text == "empty" ? null : image_one.text,
        image_two: image_two.text == "empty" ? null : image_two.text,
        delivery_date: dateTime_delivery,
        comments: comments.text,
        advanced: int.parse(advanced.text),
        due_amount: int.parse(due_amount.text),
        total_admin_discount: int.parse(admin_discount.text),
        total_agent_discount: int.parse(agent_discount.text),
        test_item_cost: test_item_cost,
        test_item_discount: test_item_discount,
        total_discount: totalDiscount,
        total_payable_imagine_cost: total_payable_imaging,
        total_payable_pathology_cost: total_payable_pathology,
        total_payable: total_payable_item,
        total_unpayable: total_unpayable_item,
        admin_pathology_discount: int.parse(admin_pathology_discount.text),
        admin_radiology_discount: int.parse(admin_radiology_discount.text),
        agent_commission: int.parse(agent_commission.text),
        agent_pathology_discount: int.parse(agent_pathology_discount.text),
        agent_radiology_discount: int.parse(agent_radiology_discount.text),
        area: "",
        is_paid: false,
        total_unpayable_imagine: total_unpayable_imaging,
        total_unpayable_pathology: total_unpayable_pathology,
        payment_date: paymentDate ?? widget.testEachRequest?.payment_date,
        pathology_payment_date: widget.testEachRequest?.pathology_payment_date,
        advance_payment_date: advancedPaymentDate ?? widget.testEachRequest?.advance_payment_date,
        pathology_done: pathologyDone,
        radiology_done: radiologyDone,
        assigning: pathologyAssigningPhone.toString(),
        radiology_assigning: radiologyAssigningPhone.toString(),
        assigning_commission: int.parse(assigning_commission.text),
        radiology_assigning_commission:
            int.parse(radiology_assigning_commission.text),
        imageDiscountFile: image_discount_card.text,
        due_recieved_one_by:
        due_recieved_one_by ?? widget.testEachRequest?.due_recieved_one_by,
        due_recieved_two_by:
            due_recieved_two_by ?? widget.testEachRequest?.due_recieved_two_by,
        advance_recieved_by:
            advance_recieved_by ?? widget.testEachRequest?.advance_recieved_by,
        prepared_by: preparedBy ?? widget.testEachRequest?.prepared_by,
        due_recieved_one: int.tryParse(due_recieved_one.text.trim()) ?? 0,
        due_recieved_two: int.tryParse(due_recieved_two.text.trim()) ?? 0,
        last_modifier: lastModifier ?? widget.testEachRequest?.last_modifier,
        due_recieve_one_date:
        dueReceivedOneDate ?? widget.testEachRequest?.due_recieve_one_date,
        due_recieve_two_date:
            dueReceivedTwoDate ?? widget.testEachRequest?.due_recieve_two_date,
        total_cash_recieve: totalCashRecieve,
      );
    }

    var updateTestRequestItem = buildRequest();
    final loggedUserName = await getLoggedUserName();

    String? preparedBy = widget.testEachRequest!.prepared_by;
    String? lastModifier = widget.testEachRequest!.last_modifier;

    final testStatus = widget.testEachRequest!.teststatus;
    final isCollectingPage = (testStatus <= 6 || testStatus == 8);

    final originalAdvancePaymentDate = widget.testEachRequest!.advance_payment_date ?? 0;
    final originalDueReceivedOneDate =
        widget.testEachRequest!.due_recieve_one_date ?? 0;
    final originalDueReceivedTwoDate =
        widget.testEachRequest!.due_recieve_two_date ?? 0;

    final updatedAdvanced = int.tryParse(advanced.text) ?? 0;
    final updatedDueReceivedOne = int.tryParse(due_recieved_one.text) ?? 0;
    final updatedDueReceivedTwo = int.tryParse(due_recieved_two.text) ?? 0;

    int tempAdvancePaymentDate = originalAdvancePaymentDate;
    int tempDueReceivedOneDate = originalDueReceivedOneDate;
    int tempDueReceivedTwoDate = originalDueReceivedTwoDate;

    String? advanceReceiverName = widget.testEachRequest!.advance_recieved_by;
    String? dueReceiverOneName = widget.testEachRequest!.due_recieved_one_by;
    String? dueReceiverTwoName = widget.testEachRequest!.due_recieved_two_by;
    int? originalAdvance = widget.testEachRequest!.advanced??0;
    int? originalDueOne = widget.testEachRequest!.due_recieved_one??0;
    int? originalDueTwo = widget.testEachRequest!.due_recieved_two??0;
    //int? orignalDueRecieve = int.parse(widget.testEachRequest!.due_recieved)??0;



    final isAdvanceReceiverUntracked =
        (widget.testEachRequest!.advance_payment_date == null ||
                widget.testEachRequest!.advance_payment_date == 0) &&
            updatedAdvanced > 0 && originalAdvance!=updatedAdvanced;

    if (isCollectingPage && isAdvanceReceiverUntracked) {
      tempAdvancePaymentDate = currentTime;
      advanceReceiverName = phoneNumber;
    }

    final isDueOneUntracked =
        (widget.testEachRequest!.due_recieved_one == null ||
            widget.testEachRequest!.due_recieved_one == 0) &&
            updatedDueReceivedOne > 0 && originalDueOne!=updatedDueReceivedOne;

    if (isCollectingPage && isDueOneUntracked) {
      tempDueReceivedOneDate = currentTime;
      dueReceiverOneName = phoneNumber;
    }

    final isDueTwoUntracked =
        (widget.testEachRequest!.due_recieved_two == null ||
            widget.testEachRequest!.due_recieved_two == 0) &&
            updatedDueReceivedTwo > 0 && originalDueTwo!=updatedDueReceivedTwo;

    if (isCollectingPage && isDueTwoUntracked) {
      tempDueReceivedTwoDate = currentTime;
      dueReceiverTwoName = phoneNumber;
    }

    if (widget.testEachRequest!.prepared_by == null ||
        widget.testEachRequest!.prepared_by!.isEmpty) {
      preparedBy = loggedUserName;
    } else if (isTestRequestModified(
        widget.testEachRequest!, updateTestRequestItem)) {
      lastModifier = loggedUserName;
    }
    //
    // if (widget.testEachRequest?.teststatus != 1 &&
    //     (widget.testEachRequest?.teststatus ?? 0) <= 5 ||
    //     widget.testEachRequest?.teststatus == 8) {
    //   dueRecieverName = loggedUserName;
    // }

    updateTestRequestItem = buildRequest(
      due_recieved_one_by: dueReceiverOneName,
      dueReceivedOneDate:tempDueReceivedOneDate ,
      preparedBy: preparedBy,
      lastModifier: lastModifier,
      advance_recieved_by: advanceReceiverName,
      due_recieved_two_by: dueReceiverTwoName,
      dueReceivedTwoDate: tempDueReceivedTwoDate,
      advancedPaymentDate: tempAdvancePaymentDate,
    );

    if (testStatus == 2 || testStatus == 8) {
      InvoicePrint(
          updateTestRequestItem, totalDiscount, due_amount, advanced, tubeCost,assigningMapping);
    }

    await dbRef
        .child(updateTestRequestItem.mobile)
        .child(updateTestRequestItem.id)
        .update(jsonDecode(jsonEncode(updateTestRequestItem.toJson())));

    Get.back();
  }

  bool isTestRequestModified(
      TestDataRequest oldRequest, TestDataRequest newRequest) {
    return oldRequest.name != newRequest.name ||
        oldRequest.gender != newRequest.gender ||
        oldRequest.mobile != newRequest.mobile ||
        oldRequest.age != newRequest.age ||
        oldRequest.testlist != newRequest.testlist ||
        oldRequest.totalprice != newRequest.totalprice ||
        oldRequest.servicecharge != newRequest.servicecharge ||
        oldRequest.address != newRequest.address ||
        oldRequest.referrer != newRequest.referrer ||
        oldRequest.lastupdate != newRequest.lastupdate ||
        oldRequest.softdelete != newRequest.softdelete ||
        oldRequest.latitude != newRequest.latitude ||
        oldRequest.longitude != newRequest.longitude ||
        // teststatus is intentionally skipped
        oldRequest.invoice_call != newRequest.invoice_call ||
        oldRequest.type != newRequest.type ||
        oldRequest.image_one != newRequest.image_one ||
        oldRequest.image_two != newRequest.image_two ||
        oldRequest.delivery_date != newRequest.delivery_date ||
        oldRequest.comments != newRequest.comments ||
        oldRequest.advanced != newRequest.advanced ||
        oldRequest.due_amount != newRequest.due_amount ||
        oldRequest.total_admin_discount != newRequest.total_admin_discount ||
        oldRequest.total_agent_discount != newRequest.total_agent_discount ||
        oldRequest.test_item_cost != newRequest.test_item_cost ||
        oldRequest.test_item_discount != newRequest.test_item_discount ||
        oldRequest.total_discount != newRequest.total_discount ||
        oldRequest.total_payable_imagine_cost !=
            newRequest.total_payable_imagine_cost ||
        oldRequest.total_payable_pathology_cost !=
            newRequest.total_payable_pathology_cost ||
        oldRequest.total_payable != newRequest.total_payable ||
        oldRequest.total_unpayable != newRequest.total_unpayable ||
        oldRequest.admin_pathology_discount !=
            newRequest.admin_pathology_discount ||
        oldRequest.admin_radiology_discount !=
            newRequest.admin_radiology_discount ||
        oldRequest.agent_commission != newRequest.agent_commission ||
        oldRequest.agent_pathology_discount !=
            newRequest.agent_pathology_discount ||
        oldRequest.agent_radiology_discount !=
            newRequest.agent_radiology_discount ||
        oldRequest.area != newRequest.area ||
        oldRequest.is_paid != newRequest.is_paid ||
        oldRequest.total_unpayable_imagine !=
            newRequest.total_unpayable_imagine ||
        oldRequest.total_unpayable_pathology !=
            newRequest.total_unpayable_pathology ||
        oldRequest.payment_date != newRequest.payment_date ||
        oldRequest.advance_payment_date != newRequest.advance_payment_date ||
        oldRequest.pathology_done != newRequest.pathology_done ||
        oldRequest.radiology_done != newRequest.radiology_done ||
        oldRequest.assigning != newRequest.assigning ||
        oldRequest.radiology_assigning != newRequest.radiology_assigning ||
        oldRequest.assigning_commission != newRequest.assigning_commission ||
        oldRequest.radiology_assigning_commission !=
            newRequest.radiology_assigning_commission ||
        oldRequest.imageDiscountFile != newRequest.imageDiscountFile ||
        oldRequest.due_recieved_one != newRequest.due_recieved_one ||
        oldRequest.due_recieved_one_by != newRequest.due_recieved_one_by ||
        oldRequest.due_recieve_one_date != newRequest.due_recieve_one_date ||
        oldRequest.due_recieved_two_by != newRequest.due_recieved_two_by ||
        oldRequest.last_modifier != newRequest.last_modifier ||
        oldRequest.due_recieved_two != newRequest.due_recieved_two ||
        oldRequest.due_recieve_two_date != newRequest.due_recieve_two_date ||
        oldRequest.total_cash_recieve != newRequest.total_cash_recieve;
  }

  Future<void> calculationProcess() async {
    totalTestCost = 0;
    totalCost = 0;
    serviceCost = 0;
    tubeCost = 0;
    totalDiscount = 0;
    totalDueRecievedOne = 0;
    totalDueRecievedTwo = 0;
    test_item_discount = 0;
    total_payable_pathology = 0;
    total_payable_imaging = 0;
    total_unpayable_pathology = 0;
    total_unpayable_imaging = 0;

    total_payable_item = 0;
    total_unpayable_item = 0;

    if (admin_discount.text == null || admin_discount.text.isEmpty) {
      admin_discount.text = "0";
    }
    if (admin_pathology_discount.text == null ||
        admin_pathology_discount.text.isEmpty) {
      admin_pathology_discount.text = "0";
    }
    if (admin_radiology_discount.text == null ||
        admin_radiology_discount.text.isEmpty) {
      admin_radiology_discount.text = "0";
    }

    admin_discount.text = (int.parse(admin_pathology_discount.text) +
            int.parse(admin_radiology_discount.text))
        .toString();

    totalDiscount = totalDiscount + int.parse(admin_discount.text.toString());
    int valueOne = int.tryParse(due_recieved_one.text.toString()) ?? 0;
    int valueTwo = int.tryParse(due_recieved_two.text.toString()) ?? 0;

    totalDueRecievedOne += valueOne;
    totalDueRecievedTwo += valueTwo;

    //agent

    if (agent_discount.text == null || agent_discount.text.isEmpty) {
      agent_discount.text = "0";
    }
    if (agent_pathology_discount.text == null ||
        agent_pathology_discount.text.isEmpty) {
      agent_pathology_discount.text = "0";
    }
    if (agent_radiology_discount.text == null ||
        agent_radiology_discount.text.isEmpty) {
      agent_radiology_discount.text = "0";
    }

    agent_discount.text = (int.parse(agent_pathology_discount.text) +
            int.parse(agent_radiology_discount.text))
        .toString();

    totalDiscount = totalDiscount + int.parse(agent_discount.text.toString());

    //new_start

    //new_end

    testData_updated.map((testItem) {
      totalTestCost = totalTestCost + int.parse(testItem.testprice.toString());

      serviceCost =
          max(serviceCost, int.parse(testItem.servicecharge.toString()));

      test_item_discount =
          test_item_discount + int.parse(testItem.discount.toString());
      tubeCost = tubeCost + int.parse(testItem.testkitprice.toString());
      totalDiscount = totalDiscount + int.parse(testItem.discount.toString());

      if (testItem.is_payable == null) {
        testItem.is_payable = true;
      }

      if (testItem.is_payable) {
        if (testItem.category == 1) {
          total_payable_pathology = total_payable_pathology +
              int.parse(testItem.testprice.toString()) -
              int.parse(testItem.discount.toString());
        } else {
          total_payable_imaging = total_payable_imaging +
              int.parse(testItem.testprice.toString()) -
              int.parse(testItem.discount.toString());
        }
      } else {
        if (testItem.category == 1) {
          total_unpayable_pathology = total_unpayable_pathology +
              int.parse(testItem.testprice.toString()) -
              int.parse(testItem.discount.toString());
        } else {
          total_unpayable_imaging = total_unpayable_imaging +
              int.parse(testItem.testprice.toString()) -
              int.parse(testItem.discount.toString());
        }
      }
    }).toList();

    totalCost = totalTestCost + serviceCost + tubeCost - totalDiscount;

    //totalCost = totalTestCost  + serviceCost - totalDiscount;

    totalprice.text = totalCost.toString();
    servicecharge.text = serviceCost.toString();
    test_item_cost = totalTestCost;
    total_payable_item = total_payable_pathology + total_payable_imaging;
    total_unpayable_item = total_unpayable_pathology + total_unpayable_imaging;

    if (advanced.text.isNotEmpty || due_recieved_two.text.isNotEmpty || due_recieved_one.text.isNotEmpty) {
      due_amount.text = (totalCost -
          (int.tryParse(advanced.text.toString())??0) -
          (int.tryParse(due_recieved_one.text.toString())??0) - (int.tryParse(due_recieved_two.text.toString())??0))
          .toString();
      handleDisbaleDueReecieve();
    }


    if (testData_updated.length == 0) {
      totalDiscount = 0;
      agent_discount.text = "0";
      admin_discount.text = "0";
    }

    total_discount.text = totalDiscount.toString();

    totalCashRecieve = totalDueRecievedOne + totalDueRecievedTwo + (int.tryParse(advanced.text) ?? 0);

    //Collection Man
    print("Admin User List"+ adminUserList.toString());
    assigning_commission.text =getUserCommission(pathologyAssigningPhone.toString(), "PATHOLOGY");
    radiology_assigning_commission.text =getUserCommission(radiologyAssigningPhone.toString(), "RADIOLOGY");

    //Agent
    adminUserList.map((e) {
      if (e.referrer_code != null &&
          e.referrer_code.contains(referrer.text.toString())) {
        var pathology_commision = 0;
        var imagine_commission = 0;

        if (e.pathology_commission != null &&
            !e.pathology_commission.toString().contains("null") &&
            e.pathology_commission != "") {
          pathology_commision = int.parse(e.pathology_commission);
        }

        if (e.imagine_commission != null &&
            !e.imagine_commission.toString().contains("null") &&
            e.imagine_commission != "") {
          imagine_commission = int.parse(e.imagine_commission);
        }

        agent_commission.text =
            ((((total_payable_pathology) * pathology_commision) / 100) +
                    (((total_payable_imaging) * imagine_commission) / 100))
                .toInt()
                .toString();
      }
    }).toList();
  }

  Future<void> removeCalulationProcess(id) async {
    setState(() {
      testData_updated.removeWhere((element) => element.id == id);
      testItemListWithSelected[id] = false;

      totalTestCost = 0;
      totalCost = 0;
      serviceCost = 0;
      tubeCost = 0;
      totalDiscount = 0;
      test_item_discount = 0;
      total_payable_pathology = 0;
      total_payable_imaging = 0;
      total_unpayable_pathology = 0;
      total_unpayable_imaging = 0;

      testData_updated.map((testItem) {
        totalTestCost =
            totalTestCost + int.parse(testItem.testprice.toString());

        serviceCost =
            max(serviceCost, int.parse(testItem.servicecharge.toString()));

        tubeCost = tubeCost + int.parse(testItem.testkitprice.toString());
        totalDiscount = totalDiscount + int.parse(testItem.discount.toString());
        test_item_discount =
            test_item_discount + int.parse(testItem.discount.toString());

        if (testItem.is_payable == null) {
          testItem.is_payable = true;
        }

        if (testItem.is_payable) {
          if (testItem.category == 1) {
            total_payable_pathology = total_payable_pathology +
                int.parse(testItem.testprice.toString()) -
                int.parse(testItem.discount.toString());
          } else {
            total_payable_imaging = total_payable_imaging +
                int.parse(testItem.testprice.toString()) -
                int.parse(testItem.discount.toString());
          }
        } else {
          if (testItem.category == 1) {
            total_unpayable_pathology = total_unpayable_pathology +
                int.parse(testItem.testprice.toString()) -
                int.parse(testItem.discount.toString());
          } else {
            total_unpayable_imaging = total_unpayable_imaging +
                int.parse(testItem.testprice.toString()) -
                int.parse(testItem.discount.toString());
          }
        }
      }).toList();

      totalCost = totalTestCost + serviceCost + tubeCost - totalDiscount;
      // totalCost = totalTestCost  + tubeCost ;
      //totalCost = totalTestCost  + serviceCost - totalDiscount;

      totalprice.text = totalCost.toString();
      //totaltestprice.text = totalTestCost.toString();
      servicecharge.text = serviceCost.toString();
      test_item_cost = totalTestCost;


      if (advanced.text.isNotEmpty || due_recieved_two.text.isNotEmpty || due_recieved_one.text.isNotEmpty) {
        due_amount.text = (totalCost -
            (int.tryParse(advanced.text.toString())??0) -
            (int.tryParse(due_recieved_one.text.toString())??0) - (int.tryParse(due_recieved_two.text.toString())??0))
            .toString();
        handleDisbaleDueReecieve();
      }

      if (testData_updated.length == 0) {
        totalDiscount = 0;
        agent_discount.text = "0";
        admin_discount.text = "0";
      }

      total_discount.text = totalDiscount.toString();

      totalCashRecieve = totalDueRecievedOne + totalDueRecievedTwo + (int.tryParse(advanced.text) ?? 0);


      assigning_commission.text =getUserCommission(pathologyAssigningPhone, "PATHOLOGY");
      radiology_assigning_commission.text =getUserCommission(radiologyAssigningPhone, "RADIOLOGY");


      adminUserList.map((e) {
        var pathology_commision = 0;
        var imagine_commission = 0;

        if (e.pathology_commission != null &&
            !e.pathology_commission.toString().contains("null") &&
            e.pathology_commission != "") {
          pathology_commision = int.parse(e.pathology_commission);
        }

        if (e.imagine_commission != null &&
            !e.imagine_commission.toString().contains("null") &&
            e.imagine_commission != "") {
          imagine_commission = int.parse(e.imagine_commission);
        }

        if (e.referrer_code != null &&
            e.referrer_code.contains(referrer.text.toString())) {
          agent_commission.text =
              ((((total_payable_pathology) * pathology_commision) / 100) +
                      (((total_payable_imaging) * imagine_commission) / 100))
                  .toInt()
                  .toString();
        }
      }).toList();
    });
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

    getAdminUserList();
    if (widget.testEachRequest != null) {
      this.retreiveEachDataRequest();

      _getTestItemList();
    }
    init = true;
    // TODO: implement initState
    super.initState();
  }

  CreateRequestController createReqController =
      Get.put(CreateRequestController());

  @override
  Widget build(BuildContext context) {
    chechkingInternet();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(backgroundColor: appTheme, actions: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: DM.p50, vertical: DM.p10),
          width: DM.screenWidth,
          child: Text(
            "Test Request Form",
            textAlign: TextAlign.left,
            style: TextStyle(color: secondaryColor, fontSize: DM.p30),
          ),
        ),
      ]),
      backgroundColor: secondaryColor,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Container(
            width: DM.screenWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: DM.p10, vertical: DM.p10),
                    decoration: BoxDecoration(
                        color: whiteColor,
                        borderRadius: BorderRadius.circular(DM.p10),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.shade300,
                              blurRadius: DM.p20,
                              spreadRadius: DM.p1,
                              offset: Offset(0, DM.p1))
                        ]),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FormUserInfo(
                          formKey: _formKey,
                          validatorField: validateString,
                          textInputType: TextInputType.name,
                          controller: type,
                          title: "Type",
                          value: "0",
                          activate: false,
                        ),
                        FormUserInfo(
                          formKey: _formKey,
                          validatorField: validateString,
                          textInputType: TextInputType.name,
                          controller: invoice_call,
                          title: "Invoice Number",
                          value: "#12345-100",
                          activate: true,
                        ),
                        FormUserInfo(
                          formKey: _formKey,
                          validatorField: validateString,
                          textInputType: TextInputType.name,
                          controller: name,
                          title: "Name",
                          value: "Write your name",
                          activate: false,
                        ),
                        FormUserInfo(
                          formKey: _formKey,
                          validatorField: validateMobile,
                          textInputType: TextInputType.phone,
                          controller: phone,
                          title: "Contact Number",
                          value: "#0000",
                          activate: false,
                        ),
                        Padding(
                          padding: EdgeInsets.all(DM.p5),
                          child: Row(
                            children: [
                              SizedBox(
                                width: DM.p100,
                                child: Text(
                                  "Gender",
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
                                hint: Text("$gender",
                                    style: TextStyle(color: blackFontColor)),
                                items: <String>[
                                  'Male',
                                  'Female',
                                ].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      "$value",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    gender = newValue!;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        FormUserAge(
                          formKey:  _formKey,
                          ageController: age,
                          // Controller to collect the combined age string
                          initialAge: widget.testEachRequest?.age??"", // The initial value
                        ),
                        Padding(
                          padding: EdgeInsets.all(DM.p5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: DM.p100,
                                child: Text(
                                  "Address",
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
                                  child: TextFormField(
                                    controller: address,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null,
                                    // onTap: (() {
                                    //   showDialog(
                                    //       context: context,
                                    //       builder: (context) {
                                    //         return MyDialogView(
                                    //             myChild: TextDialogueBox(
                                    //                 keyTitle: "Address",
                                    //                 addressText: address));
                                    //       });
                                    // }),
                                    decoration: InputDecoration(
                                        errorStyle: TextStyle(fontSize: DM.p9),
                                        // focusedErrorBorder:
                                        //     OutlineInputBorder(
                                        //         borderSide: BorderSide(
                                        //             width: DM.p1,
                                        //             color:
                                        //                 orangeColor)),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                width: DM.p1, color: appTheme)),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: DM.p1,
                                              color: appTheme), //<-- SEE HERE
                                        ),
                                        filled: true,
                                        fillColor: fullWhiteColor,
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: DM.p10),
                                        border: InputBorder.none,
                                        hintText: "Your Address",
                                        hintStyle: TextStyle(
                                          color: Colors.grey,
                                          fontSize: DM.p14,
                                        )),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(DM.p5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: DM.p100,
                                child: Text(
                                  "Referrer",
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
                                  child: TextFormField(
                                    readOnly: typeUser == "4" ? true : false,
                                    controller: referrer,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null,
                                    onEditingComplete: () {
                                      calculationProcess();
                                    },
                                    decoration: InputDecoration(
                                        errorStyle: TextStyle(fontSize: DM.p9),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                width: DM.p1, color: appTheme)),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: DM.p1,
                                              color: appTheme), //<-- SEE HERE
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: DM.p10),
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
                        ),

                        Padding(
                          padding: EdgeInsets.all(DM.p1),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: DM.p100,
                                child: Text(
                                  "Discount Card\n(যদি থাকে)",
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
                              image_discount_card.text != "empty" ||
                                      imageDiscountFile != null
                                  ? Column(
                                children: [
                                        //MyphotoView for Form
                                  Container(
                                    height: DM.p80,
                                    width: DM.p80,
                                          child: isFromNetwork_discount
                                        ? InkWell(
                                      onTap: () {
                                          showDialog(
                                            context: context,
                                                        builder: (context) {
                                                          return MyDialogView(
                                                              myChild:
                                                                  MyPhotoView(
                                                            image: widget
                                                                .testEachRequest!
                                                                .imageDiscountFile
                                                                .toString(),
                                                            imageType:
                                                                "Network",
                                                          ));
                                                        });
                                      },
                                                  child: Container(
                                      child: Image.network(
                                                      widget.testEachRequest!
                                                          .imageDiscountFile
                                                          .toString()!,
                                        fit: BoxFit.cover,
                                        ),
                                      ),
                                    )
                                              : InkWell(
                                      onTap: () {
                                          showDialog(
                                            context: context,
                                                        builder: (context) {
                                                          return MyDialogView(
                                              myChild: MyPhotoView(
                                                image: imageDiscountFile,
                                                imageType: "File",
                                                          ));
                                                        });
                                      },
                                                  child: Container(
                                      child: Image.file(
                                        imageDiscountFile!,
                                        fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                        typeUser == "7" || phone == superUser
                                            ? IconButton(
                                      color: appTheme,
                                      icon: Icon(
                                        CupertinoIcons.xmark_circle_fill,
                                        size: DM.p30,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          imageDiscountFile = null;
                                          image_discount_card.text = "empty";
                                        });
                                      },
                                              )
                                            : SizedBox(),
                                ],
                              )
                                  : Container(
                                height: DM.p60,
                                width: DM.p80,
                                margin: EdgeInsets.symmetric(horizontal: DM.p15),
                                child: MaterialButton(
                                  onPressed: () async {
                                    showDialog(
                                      context: context,
                                                builder: (context) {
                                                  return Center(
                                        child: Container(
                                          color: whiteColor,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                margin: EdgeInsets.all(DM.p16),
                                                height: DM.p130,
                                                width: DM.p120,
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: appTheme,
                                                                        elevation:
                                                                            0),
                                                                    onPressed:
                                                                        () async {
                                                                      PickedFile?
                                                                          pickedFile =
                                                                          await ImagePicker()
                                                                              .getImage(
                                                      source: ImageSource.gallery,
                                                      maxWidth: 1200,
                                                      maxHeight: 1600,
                                                    );
                                                                      setState(
                                                                          () {
                                                                        if (pickedFile !=
                                                                            null)
                                                                          imageDiscountFile =
                                                                              File(pickedFile!.path);
                                                      });

                                                                      Navigator.pop(
                                                                          context);
                                                  },
                                                  child: Text(
                                                    "Gallery",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              DM.p18),
                                                                    )),
                                                          ),
                                                          Container(
                                                            margin:
                                                                EdgeInsets.all(
                                                                    DM.p16),
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            25)),
                                                            height: DM.p130,
                                                            width: DM.p120,
                                                            child:
                                                                ElevatedButton(
                                                                    style: ElevatedButton.styleFrom(
                                                                        backgroundColor:
                                                                            appTheme,
                                                                        elevation:
                                                                            0),
                                                                    onPressed:
                                                                        () async {
                                                                      PickedFile?
                                                                          pickedFile =
                                                                          await ImagePicker()
                                                                              .getImage(
                                                                        source:
                                                                            ImageSource.camera,
                                                                        maxWidth:
                                                                            1200,
                                                                        maxHeight:
                                                                            1600,
                                                                      );
                                                                      setState(
                                                                          () {
                                                                        if (pickedFile !=
                                                                            null)
                                                                          imageDiscountFile =
                                                                              File(pickedFile!.path);
                                                                      });
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                    child: Text(
                                                                        "Camera",
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                DM.p18))),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                });
                                          },
                                          height: DM.p50,
                                          color: appTheme,
                                          child: Icon(
                                            Icons.camera,
                                            size: DM.p40,
                                            color: whiteColor,
                                          )),
                                    )
                            ],
                          ),
                        ),

                        FormUserInfo(
                          formKey: _formKey,
                          textInputType: TextInputType.name,
                          controller: dateofcreated,
                          title: "Date of created",
                          value: "15 Dec 2014",
                          activate: true,
                        ),

                        Padding(
                          padding: EdgeInsets.all(DM.p5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: DM.p100,
                                    child: Text(
                                      "Images",
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
                                ],
                              ),
                              SizedBox(
                                height: DM.p10,
                              ),
                              widget.testEachRequest!.type == 1
                                  ? Container(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            margin:
                                                EdgeInsets.only(top: DM.p24),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                image_one.text != "empty" ||
                                                        imageFile1 != null
                                                    ? Column(
                                                        children: [
                                                          //MyphotoView for Form
                                                          Container(
                                                            height: DM.p180,
                                                            width: DM.p150,
                                                            child:
                                                                isFromNetwork1
                                                                    ? InkWell(
                                                                        onTap:
                                                                            () {
                                                                          showDialog(
                                                                              context: context,
                                                                              builder: (context) {
                                                                                return MyDialogView(
                                                                                    myChild: MyPhotoView(
                                                                                  image: widget.testEachRequest!.image_one.toString(),
                                                                                  imageType: "Network",
                                                                                ));
                                                                              });
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          child:
                                                                              Image.network(
                                                                            widget.testEachRequest!.image_one.toString()!,
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                        ),
                                                                      )
                                                                    : InkWell(
                                                                        onTap:
                                                                            () {
                                                                          showDialog(
                                                                              context: context,
                                                                              builder: (context) {
                                                                                return MyDialogView(
                                                                                    myChild: MyPhotoView(
                                                                                  image: imageFile1,
                                                                                  imageType: "File",
                                                                                ));
                                                                              });
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          child:
                                                                              Image.file(
                                                                            imageFile1!,
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                        ),
                                                                      ),
                                                          ),
                                                          typeUser == "7" ||
                                                                  phoneNumber ==
                                                                      superUser
                                                              ? IconButton(
                                                                  color:
                                                                      appTheme,
                                                                  icon: Icon(
                                                                    CupertinoIcons
                                                                        .xmark_circle_fill,
                                                                    size:
                                                                        DM.p30,
                                                                  ),
                                                                  onPressed:
                                                                      () {
                                                                    setState(
                                                                        () {
                                                                      imageFile1 =
                                                                          null;
                                                                      image_one
                                                                              .text =
                                                                          "empty";
                                                                    });
                                                                  },
                                                                )
                                                              : SizedBox(),
                                                        ],
                                                      )
                                                    : Container(
                                                        height: DM.p60,
                                                        width: DM.p160,
                                                        margin: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    DM.p5),
                                                        child: ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(DM
                                                                              .p10)),
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      vertical: DM
                                                                          .p20),
                                                              primary:
                                                                  appTheme),
                                                          onPressed: () async {
                                                            showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) {
                                                                  return Center(
                                                                    child:
                                                                        Container(
                                                                      color:
                                                                          whiteColor,
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Container(
                                                                            margin:
                                                                                EdgeInsets.all(DM.p16),
                                                                            height:
                                                                                DM.p130,
                                                                            width:
                                                                                DM.p120,
                                                                            child: ElevatedButton(
                                                                                style: ElevatedButton.styleFrom(backgroundColor: appTheme, elevation: 0),
                                                                                onPressed: () async {
                                                                                  PickedFile? pickedFile = await ImagePicker().getImage(
                                                                                    source: ImageSource.gallery,
                                                                                    maxWidth: 800,
                                                                                    maxHeight: 1200,
                                                                                  );
                                                                                  setState(() {
                                                                                    if (pickedFile != null) {
                                                                                      imageFile1 = File(pickedFile!.path);
                                                                                      isFromNetwork1 = false;
                                                                                    }
                                                                                  });

                                                                                  Navigator.pop(context);
                                                                                },
                                                                                child: Text(
                                                                                  "Gallery",
                                                                                  style: TextStyle(fontSize: DM.p18),
                                                                                )),
                                                                          ),
                                                                          Container(
                                                                            margin:
                                                                                EdgeInsets.all(DM.p16),
                                                                            decoration:
                                                                                BoxDecoration(borderRadius: BorderRadius.circular(25)),
                                                                            height:
                                                                                DM.p130,
                                                                            width:
                                                                                DM.p120,
                                                                            child: ElevatedButton(
                                                                                style: ElevatedButton.styleFrom(backgroundColor: appTheme, elevation: 0),
                                                                                onPressed: () async {
                                                                                  PickedFile? pickedFile = await ImagePicker().getImage(
                                                                                    source: ImageSource.camera,
                                                                                    maxWidth: 800,
                                                                                    maxHeight: 1200,
                                                                                  );
                                                                                  setState(() {
                                                                                    if (pickedFile != null) {
                                                                                      isFromNetwork1 = false;
                                                                                      imageFile1 = File(pickedFile!.path);
                                                                                    }
                                                                                  });
                                                                                  Navigator.pop(context);
                                                                                },
                                                                                child: Text("Camera", style: TextStyle(fontSize: DM.p18))),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  );
                                                                });
                                                          },
                                                          child: Text(
                                                            "Image 1",
                                                            textAlign:
                                                                TextAlign.start,
                                                            style: TextStyle(
                                                                color:
                                                                    fullWhiteColor,
                                                                fontSize:
                                                                    DM.p15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                      ),
                                                Container(
                                                  height: DM.p40,
                                                ),
                                                image_two.text != "empty" ||
                                                        imageFile2 != null
                                                    ? Column(
                                                        children: [
                                                          Container(
                                                              height: DM.p180,
                                                              width: DM.p150,
                                                              child:
                                                                  isFromNetwork2
                                                                      ? InkWell(
                                                                          onTap:
                                                                              () {
                                                                            showDialog(
                                                                                context: context,
                                                                                builder: (context) {
                                                                                  return MyDialogView(
                                                                                      myChild: MyPhotoView(
                                                                                    image: widget.testEachRequest!.image_two.toString(),
                                                                                    imageType: "Network",
                                                                                  ));
                                                                                });
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            child:
                                                                                Image.network(
                                                                              widget.testEachRequest!.image_two.toString()!,
                                                                              fit: BoxFit.cover,
                                                                            ),
                                                                          ),
                                                                        )
                                                                      : InkWell(
                                                                          onTap:
                                                                              () {
                                                                            showDialog(
                                                                                context: context,
                                                                                builder: (context) {
                                                                                  return MyDialogView(
                                                                                      myChild: MyPhotoView(
                                                                                    image: imageFile2,
                                                                                    imageType: "File",
                                                                                  ));
                                                                                });
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            child:
                                                                                Image.file(
                                                                              imageFile2!,
                                                                              fit: BoxFit.cover,
                                                                            ),
                                                                          ),
                                                                        )),
                                                          typeUser == "7" ||
                                                                  phoneNumber ==
                                                                      superUser
                                                              ? IconButton(
                                                                  color:
                                                                      appTheme,
                                                                  icon: Icon(
                                                                    CupertinoIcons
                                                                        .xmark_circle_fill,
                                                                    size:
                                                                        DM.p30,
                                                                  ),
                                                                  onPressed:
                                                                      () {
                                                                    setState(
                                                                        () {
                                                                      imageFile2 =
                                                                          null;
                                                                      image_two
                                                                              .text =
                                                                          "empty";
                                                                    });
                                                                  },
                                                                )
                                                              : SizedBox(),
                                                        ],
                                                      )
                                                    : Container(
                                                        height: DM.p60,
                                                        width: DM.p160,
                                                        margin: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    DM.p5),
                                                        child: ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(DM
                                                                              .p10)),
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      vertical: DM
                                                                          .p20),
                                                              primary:
                                                                  appTheme),
                                                          onPressed: () async {
                                                            showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) {
                                                                  return Center(
                                                                    child:
                                                                        Container(
                                                                      color:
                                                                          whiteColor,
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Container(
                                                                            margin:
                                                                                EdgeInsets.all(DM.p16),
                                                                            height:
                                                                                DM.p130,
                                                                            width:
                                                                                DM.p120,
                                                                            child: ElevatedButton(
                                                                                style: ElevatedButton.styleFrom(backgroundColor: appTheme, elevation: 0),
                                                                                onPressed: () async {
                                                                                  PickedFile? pickedFile = await ImagePicker().getImage(
                                                                                    source: ImageSource.gallery,
                                                                                    maxWidth: 800,
                                                                                    maxHeight: 1200,
                                                                                  );
                                                                                  setState(() {
                                                                                    if (pickedFile != null) {
                                                                                      imageFile2 = File(pickedFile!.path);
                                                                                      isFromNetwork2 = false;
                                                                                    }
                                                                                  });
                                                                                  Navigator.pop(context);
                                                                                },
                                                                                child: Text(
                                                                                  "Gallery",
                                                                                  style: TextStyle(fontSize: DM.p18),
                                                                                )),
                                                                          ),
                                                                          Container(
                                                                            margin:
                                                                                EdgeInsets.all(DM.p16),
                                                                            height:
                                                                                DM.p130,
                                                                            width:
                                                                                DM.p120,
                                                                            child: ElevatedButton(
                                                                                style: ElevatedButton.styleFrom(backgroundColor: appTheme, elevation: 0),
                                                                                onPressed: () async {
                                                                                  PickedFile? pickedFile = await ImagePicker().getImage(
                                                                                    source: ImageSource.camera,
                                                                                    maxWidth: 800,
                                                                                    maxHeight: 1200,
                                                                                  );
                                                                                  setState(() {
                                                                                    if (pickedFile != null) {
                                                                                      imageFile2 = File(pickedFile!.path);
                                                                                      isFromNetwork2 = false;
                                                                                    }
                                                                                  });
                                                                                  Navigator.pop(context);
                                                                                },
                                                                                child: Text("Camera", style: TextStyle(fontSize: DM.p18))),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  );
                                                                });
                                                          },
                                                          child: Text(
                                                            "Image 2",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                color:
                                                                    fullWhiteColor,
                                                                fontSize:
                                                                    DM.p15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                      ),
                                              ],
                                            ),
                                          ),
                                          // Container(
                                          //   margin: EdgeInsets.symmetric(
                                          //       horizontal: DM.p20,
                                          //       vertical: DM.p32),
                                          //   child: Center(
                                          //     child: SizedBox(
                                          //       width: DM.p150,
                                          //       child: MaterialButton(
                                          //         onPressed: () async {
                                          //           if (await chechkingInternet()) {
                                          //             if (imageFile1 != null ||
                                          //                 imageFile2 != null) {
                                          //               uploadImage();
                                          //             } else {
                                          //               Get.snackbar(
                                          //                   margin: EdgeInsets
                                          //                       .symmetric(
                                          //                           horizontal:
                                          //                               DM.p70,
                                          //                           vertical:
                                          //                               DM.p60),
                                          //                   duration: Duration(
                                          //                       milliseconds:
                                          //                           3000),
                                          //                   backgroundColor:
                                          //                       redColor,
                                          //                   colorText:
                                          //                       whiteColor,
                                          //                   "Need prescriptions",
                                          //                   "Failed to submit , add image!");
                                          //             }
                                          //           }
                                          //         },
                                          //         height: DM.p50,
                                          //         shape: const StadiumBorder(),
                                          //         color: orangeColor,
                                          //         child: Text(
                                          //           // "Submit",
                                          //           "সাবমিট",
                                          //           textAlign: TextAlign.center,
                                          //           style: TextStyle(
                                          //               color: fullWhiteColor,
                                          //               fontSize: DM.p15,
                                          //               fontWeight:
                                          //                   FontWeight.bold),
                                          //         ),
                                          //       ),
                                          //     ),
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        image_one.text != "empty" ||
                                                imageFile1 != null
                                            ? Column(
                                                children: [
                                                  //MyphotoView for Form
                                                  Container(
                                                    height: DM.p180,
                                                    width: DM.p150,
                                                    child: isFromNetwork1
                                                        ? InkWell(
                                                            onTap: () {
                                                              showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (context) {
                                                                    return MyDialogView(
                                                                        myChild:
                                                                            MyPhotoView(
                                                                      image: widget
                                                                          .testEachRequest!
                                                                          .image_one
                                                                          .toString(),
                                                                      imageType:
                                                                          "Network",
                                                                    ));
                                                                  });
                                                            },
                                                            child: Container(
                                                              child:
                                                                  Image.network(
                                                                widget
                                                                    .testEachRequest!
                                                                    .image_one
                                                                    .toString()!,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          )
                                                        : InkWell(
                                                            onTap: () {
                                                              showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (context) {
                                                                    return MyDialogView(
                                                                        myChild:
                                                                            MyPhotoView(
                                                                      image:
                                                                          imageFile1,
                                                                      imageType:
                                                                          "File",
                                                                    ));
                                                                  });
                                                            },
                                                            child: Container(
                                                              child: Image.file(
                                                                imageFile1!,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          ),
                                                  ),
                                                  typeUser == "7" ||
                                                          phoneNumber ==
                                                              superUser
                                                      ? IconButton(
                                                          color: appTheme,
                                                          icon: Icon(
                                                            CupertinoIcons
                                                                .xmark_circle_fill,
                                                            size: DM.p30,
                                                          ),
                                                          onPressed: () {
                                                            setState(() {
                                                              imageFile1 = null;
                                                              image_one.text =
                                                                  "empty";
                                                            });
                                                          },
                                                        )
                                                      : SizedBox(),
                                                ],
                                              )
                                            : Container(
                                                height: DM.p60,
                                                width: DM.p160,
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: DM.p5),
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      DM.p10)),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: DM.p20),
                                                      primary: appTheme),
                                                  onPressed: () async {
                                                    showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return Center(
                                                            child: Container(
                                                              color: whiteColor,
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Container(
                                                                    margin: EdgeInsets
                                                                        .all(DM
                                                                            .p16),
                                                                    height:
                                                                        DM.p130,
                                                                    width:
                                                                        DM.p120,
                                                                    child: ElevatedButton(
                                                                        style: ElevatedButton.styleFrom(backgroundColor: appTheme, elevation: 0),
                                                                        onPressed: () async {
                                                                          PickedFile?
                                                                              pickedFile =
                                                                              await ImagePicker().getImage(
                                                                            source:
                                                                                ImageSource.gallery,
                                                                            maxWidth:
                                                                                800,
                                                                            maxHeight:
                                                                                1200,
                                                                          );
                                                                          setState(
                                                                              () {
                                                                            if (pickedFile !=
                                                                                null) {
                                                                              imageFile1 = File(pickedFile!.path);
                                                                              isFromNetwork1 = false;
                                                                            }
                                                                          });

                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                        child: Text(
                                                                          "Gallery",
                                                                          style:
                                                                              TextStyle(fontSize: DM.p18),
                                                                        )),
                                                                  ),
                                                                  Container(
                                                                    margin: EdgeInsets
                                                                        .all(DM
                                                                            .p16),
                                                                    decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(25)),
                                                                    height:
                                                                        DM.p130,
                                                                    width:
                                                                        DM.p120,
                                                                    child: ElevatedButton(
                                                                        style: ElevatedButton.styleFrom(backgroundColor: appTheme, elevation: 0),
                                                                        onPressed: () async {
                                                                          PickedFile?
                                                                              pickedFile =
                                                                              await ImagePicker().getImage(
                                                                            source:
                                                                                ImageSource.camera,
                                                                            maxWidth:
                                                                                800,
                                                                            maxHeight:
                                                                                1200,
                                                                          );
                                                                          setState(
                                                                              () {
                                                                            if (pickedFile !=
                                                                                null) {
                                                                              imageFile1 = File(pickedFile!.path);
                                                                              isFromNetwork1 = false;
                                                                            }
                                                                          });
                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                        child: Text("Camera", style: TextStyle(fontSize: DM.p18))),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        });
                                                  },
                                                  child: Text(
                                                    "Image 1",
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                        color: fullWhiteColor,
                                                        fontSize: DM.p15,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                        SizedBox(
                                          width: DM.p10,
                                        ),
                                        image_two.text != "empty" ||
                                                imageFile2 != null
                                            ? Column(
                                                children: [
                                                  Container(
                                                      height: DM.p180,
                                                      width: DM.p150,
                                                      child: isFromNetwork2
                                                          ? InkWell(
                                                              onTap: () {
                                                                showDialog(
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (context) {
                                                                      return MyDialogView(
                                                                          myChild:
                                                                              MyPhotoView(
                                                                        image: widget
                                                                            .testEachRequest!
                                                                            .image_two
                                                                            .toString(),
                                                                        imageType:
                                                                            "Network",
                                                                      ));
                                                                    });
                                                              },
                                                              child: Container(
                                                                child: Image
                                                                    .network(
                                                                  widget
                                                                      .testEachRequest!
                                                                      .image_two
                                                                      .toString()!,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                            )
                                                          : InkWell(
                                                              onTap: () {
                                                                showDialog(
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (context) {
                                                                      return MyDialogView(
                                                                          myChild:
                                                                              MyPhotoView(
                                                                        image:
                                                                            imageFile2,
                                                                        imageType:
                                                                            "File",
                                                                      ));
                                                                    });
                                                              },
                                                              child: Container(
                                                                child:
                                                                    Image.file(
                                                                  imageFile2!,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                            )),
                                                  typeUser == "7" ||
                                                          phoneNumber ==
                                                              superUser
                                                      ? IconButton(
                                                          color: appTheme,
                                                          icon: Icon(
                                                            CupertinoIcons
                                                                .xmark_circle_fill,
                                                            size: DM.p30,
                                                          ),
                                                          onPressed: () {
                                                            setState(() {
                                                              imageFile2 = null;
                                                              image_two.text =
                                                                  "empty";
                                                            });
                                                          },
                                                        )
                                                      : SizedBox(),
                                                ],
                                              )
                                            : Container(
                                                height: DM.p60,
                                                width: DM.p160,
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: DM.p5),
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      DM.p10)),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: DM.p20),
                                                      primary: appTheme),
                                                  onPressed: () async {
                                                    showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return Center(
                                                            child: Container(
                                                              color: whiteColor,
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Container(
                                                                    margin: EdgeInsets
                                                                        .all(DM
                                                                            .p16),
                                                                    height:
                                                                        DM.p130,
                                                                    width:
                                                                        DM.p120,
                                                                    child: ElevatedButton(
                                                                        style: ElevatedButton.styleFrom(backgroundColor: appTheme, elevation: 0),
                                                                        onPressed: () async {
                                                                          PickedFile?
                                                                              pickedFile =
                                                                              await ImagePicker().getImage(
                                                                            source:
                                                                                ImageSource.gallery,
                                                                            maxWidth:
                                                                                800,
                                                                            maxHeight:
                                                                                1200,
                                                                          );
                                                                          setState(
                                                                              () {
                                                                            if (pickedFile !=
                                                                                null) {
                                                                              imageFile2 = File(pickedFile!.path);
                                                                              isFromNetwork2 = false;
                                                                            }
                                                                          });
                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                        child: Text(
                                                                          "Gallery",
                                                                          style:
                                                                              TextStyle(fontSize: DM.p18),
                                                                        )),
                                                                  ),
                                                                  Container(
                                                                    margin: EdgeInsets
                                                                        .all(DM
                                                                            .p16),
                                                                    height:
                                                                        DM.p130,
                                                                    width:
                                                                        DM.p120,
                                                                    child: ElevatedButton(
                                                                        style: ElevatedButton.styleFrom(backgroundColor: appTheme, elevation: 0),
                                                                        onPressed: () async {
                                                                          PickedFile?
                                                                              pickedFile =
                                                                              await ImagePicker().getImage(
                                                                            source:
                                                                                ImageSource.camera,
                                                                            maxWidth:
                                                                                800,
                                                                            maxHeight:
                                                                                1200,
                                                                          );
                                                                          setState(
                                                                              () {
                                                                            if (pickedFile !=
                                                                                null) {
                                                                              imageFile2 = File(pickedFile!.path);
                                                                              isFromNetwork2 = false;
                                                                            }
                                                                          });
                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                        child: Text("Camera", style: TextStyle(fontSize: DM.p18))),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        });
                                                  },
                                                  child: Text(
                                                    "Image 2",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: fullWhiteColor,
                                                        fontSize: DM.p15,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                      ],
                                    ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(DM.p5),
                              child: Row(
                                children: [
                                  Text(
                                    "Test Item  ",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: DM.p14,
                                        color: Color.fromARGB(255, 26, 1, 1)),
                                  ),
                                  SizedBox(
                                    width: DM.p40,
                                  ),
                                  Text(":"),
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: DM.p20, vertical: DM.p1),
                                    child: MaterialButton(
                                      height: DM.p40,
                                      minWidth: DM.p100,
                                      shape: const StadiumBorder(),
                                      color: appTheme,
                                      onPressed: () async {
                                        if (await chechkingInternet()) {
                                          showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return MyDialogView(
                                                        myChild:
                                                            TestListDialogueAdmin(
                                                      testItemList:
                                                          testItemList,
                                                      testItemWithSelected:
                                                          testItemListWithSelected,
                                                    ));
                                                  })
                                              .then((value) => setState(() {
                                                testItemUpdatedData();
                                          }));
                                        }
                                      },
                                      child: Text(
                                        "Add",
                                        style: TextStyle(
                                            color: fullWhiteColor,
                                            fontSize: DM.p15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: DM.p5, vertical: DM.p3),
                              height: DM.screenHeight * 0.35,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: whiteColor,
                                borderRadius: BorderRadius.circular(DM.p10),
                              ),
                              child: testData_updated.length != 0
                                  ? ListView.builder(
                                      itemCount: testData_updated.length,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: DM.p15),
                                      itemBuilder: (context, index) {
                                        return Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: DM.p1,
                                          ),
                                          margin: EdgeInsets.only(top: DM.p10),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(DM.p10),
                                          ),
                                          child: Container(
                                            margin: EdgeInsets.only(left: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                SizedBox(
                                                  width: DM.p170,
                                                  child: Text(
                                                    testData_updated[index]
                                                            .name +
                                                        " (" +
                                                        testData_updated[index]
                                                            .diagnostic_center
                                                            .toString() +
                                                        ")",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        fontSize: DM.p15,
                                                        color: Color.fromARGB(
                                                            255, 26, 1, 1)),
                                                  ),
                                                ),
                                                Text(
                                                  "Price: ${testData_updated[index].testprice}",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      fontSize: DM.p15,
                                                      color: Color.fromARGB(
                                                          255, 26, 1, 1)),
                                                ),
                                                Container(
                                                  child: IconButton(
                                                    color: appTheme,
                                                    icon: Icon(
                                                      CupertinoIcons
                                                          .xmark_circle_fill,
                                                      size: DM.p30,
                                                    ),
                                                    onPressed: () {
                                                      // createReqController.removeTestData(
                                                      //     createReqController
                                                      //         .testData[index].id,
                                                      //     index);
                                                      setState(() {
                                                        removeCalulationProcess(
                                                            testData_updated[
                                                                    index]
                                                                .id);

                                                        handleFirstTimeInitPage = false;
                                                        handleDisbaleDueReecieve();
                                                      });

                                                      // createReqController
                                                      //     .calulationTestdata();
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  : Container(
                                      margin: EdgeInsets.all(DM.p10),
                                      height: DM.screenHeight * 0.33,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: whiteColor,
                                        borderRadius:
                                            BorderRadius.circular(DM.p10),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "${createReqController.emptyString}",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: DM.p15,
                                              color: Color.fromARGB(
                                                  255, 26, 1, 1)),
                                        ),
                                      ),
                                    ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: DM.p20, vertical: DM.p2),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "(Test + Tube + Collection) = (${totalTestCost}+${tubeCost}+${serviceCost}) =  ${totalTestCost + tubeCost + serviceCost} /-",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: DM.p12,
                                        color: Color.fromARGB(255, 26, 1, 1)),
                                  ),
                                  Text(
                                    "Discount : ${totalDiscount} /-",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: DM.p12,
                                        color: Color.fromARGB(255, 26, 1, 1)),
                                  ),
                                  Divider(
                                    thickness: DM.p1,
                                    color: blackFontColor,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Total Cost: ${totalCost} /-",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: DM.p15,
                                            color:
                                                Color.fromARGB(255, 26, 1, 1)),
                                      ),
                                    ],
                                  ),
                                  Divider(
                                    thickness: DM.p1,
                                    color: blackFontColor,
                                  ),
                                  typeUser == "7" || phoneNumber == superUser
                                      ? Text(
                                          "(Payable Pathology + Payable Radiology) = (${total_payable_pathology}+${total_payable_imaging}) =  ${total_payable_pathology + total_payable_imaging} /-",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: DM.p12,
                                              color: Color.fromARGB(
                                                  255, 26, 1, 1)),
                                        )
                                      : SizedBox(),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.all(DM.p5),
                          child: Row(
                            children: [
                              Text(
                                "Location  ",
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: DM.p14,
                                    color: Color.fromARGB(255, 26, 1, 1)),
                              ),
                              SizedBox(
                                width: DM.p40,
                              ),
                              Text(":"),
                              SizedBox(
                                width: DM.p10,
                              ),
                              InkWell(
                                onTap: () {
                                  openMap(double.parse(latitude),
                                      double.parse(longitude));
                                },
                                child: Text(
                                  "Click to see details",
                                  style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      decorationThickness: DM.p2,
                                      fontWeight: FontWeight.w900,
                                      fontSize: DM.p14,
                                      color: Color.fromARGB(255, 12, 81, 177)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        FormUserInfo(
                          formKey: _formKey,
                          validatorField: validateString,
                          textInputType: TextInputType.number,
                          controller: servicecharge,
                          title: "Collection charge",
                          value: "20",
                          activate: phoneNumber == superUser ? false : true,
                        ),

                        // FormUserInfo(
                        //   formKey: _formKey,
                        //   validatorField: validateString,
                        //   textInputType: TextInputType.name,
                        //   controller: lastupdate,
                        //   title: "Last update",
                        //   value: "50",
                        //   activate: false,
                        // ),

                        FormUserInfo(
                          formKey: _formKey,
                          validatorField: validateString,
                          textInputType: TextInputType.number,
                          controller: totalprice,
                          title: "Total price",
                          value: "0",
                          activate: phoneNumber == superUser ? false : true,
                        ),

                        typeUser == "7" || phoneNumber == superUser
                            ? Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(DM.p5),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: DM.p100,
                                          child: Text(
                                            "Admin Pathology Discount",
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
                                            height: DM.p42,
                                            child: TextFormField(
                                              keyboardType:
                                                  TextInputType.number,
                                              onChanged: (value) {
                                                if (value.length != 0) {
                                                  setState(() {
                                                    calculationProcess();
                                                  });
                                                }
                                              },
                                              controller:
                                                  admin_pathology_discount,
                                              decoration: InputDecoration(
                                                  errorStyle: TextStyle(
                                                      fontSize: DM.p9),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              width: DM.p1,
                                                              color: appTheme)),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        width: DM.p1,
                                                        color:
                                                            appTheme), //<-- SEE HERE
                                                  ),
                                                  filled: true,
                                                  fillColor: fullWhiteColor,
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          horizontal: DM.p10),
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
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(DM.p5),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: DM.p100,
                                          child: Text(
                                            "Admin Radiology Discount",
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
                                            height: DM.p42,
                                            child: TextFormField(
                                              keyboardType:
                                                  TextInputType.number,
                                              onChanged: (value) {
                                                if (value.length != 0) {
                                                  setState(() {
                                                    calculationProcess();
                                                  });
                                                }
                                              },
                                              controller:
                                                  admin_radiology_discount,
                                              decoration: InputDecoration(
                                                  errorStyle: TextStyle(
                                                      fontSize: DM.p9),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              width: DM.p1,
                                                              color: appTheme)),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        width: DM.p1,
                                                        color:
                                                            appTheme), //<-- SEE HERE
                                                  ),
                                                  filled: true,
                                                  fillColor: fullWhiteColor,
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          horizontal: DM.p10),
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
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(DM.p5),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: DM.p100,
                                          child: Text(
                                            "Total Admin Discount",
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
                                            height: DM.p42,
                                            child: TextFormField(
                                              readOnly: true,
                                              keyboardType:
                                                  TextInputType.number,
                                              onChanged: (value) {
                                                if (value.length != 0) {
                                                  setState(() {
                                                    calculationProcess();
                                                  });
                                                }
                                              },
                                              controller: admin_discount,
                                              decoration: InputDecoration(
                                                  errorStyle: TextStyle(
                                                      fontSize: DM.p9),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              width: DM.p1,
                                                              color: appTheme)),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        width: DM.p1,
                                                        color:
                                                            appTheme), //<-- SEE HERE
                                                  ),
                                                  filled: true,
                                                  fillColor: fullWhiteColor,
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          horizontal: DM.p10),
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
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(DM.p5),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: DM.p100,
                                          child: Text(
                                            "Agent Pathology Discount",
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
                                            height: DM.p42,
                                            child: TextFormField(
                                              keyboardType:
                                                  TextInputType.number,
                                              onChanged: (value) {
                                                if (value.length != 0) {
                                                  setState(() {
                                                    calculationProcess();
                                                  });
                                                }
                                              },
                                              controller:
                                                  agent_pathology_discount,
                                              decoration: InputDecoration(
                                                  errorStyle: TextStyle(
                                                      fontSize: DM.p9),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              width: DM.p1,
                                                              color: appTheme)),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        width: DM.p1,
                                                        color:
                                                            appTheme), //<-- SEE HERE
                                                  ),
                                                  filled: true,
                                                  fillColor: fullWhiteColor,
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          horizontal: DM.p10),
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
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(DM.p5),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: DM.p100,
                                          child: Text(
                                            "Agent Radiology Discount",
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
                                            height: DM.p42,
                                            child: TextFormField(
                                              keyboardType:
                                                  TextInputType.number,
                                              onChanged: (value) {
                                                if (value.length != 0) {
                                                  setState(() {
                                                    calculationProcess();
                                                  });
                                                }
                                              },
                                              controller:
                                                  agent_radiology_discount,
                                              decoration: InputDecoration(
                                                  errorStyle: TextStyle(
                                                      fontSize: DM.p9),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              width: DM.p1,
                                                              color: appTheme)),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        width: DM.p1,
                                                        color:
                                                            appTheme), //<-- SEE HERE
                                                  ),
                                                  filled: true,
                                                  fillColor: fullWhiteColor,
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          horizontal: DM.p10),
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
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(DM.p5),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: DM.p100,
                                          child: Text(
                                            "Total Agent Discount",
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
                                            height: DM.p42,
                                            child: TextFormField(
                                              readOnly: true,
                                              keyboardType:
                                                  TextInputType.number,
                                              onChanged: (value) {
                                                if (value.length != 0) {
                                                  setState(() {
                                                    calculationProcess();
                                                  });
                                                }
                                              },
                                              controller: agent_discount,
                                              decoration: InputDecoration(
                                                  errorStyle: TextStyle(
                                                      fontSize: DM.p9),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              width: DM.p1,
                                                              color: appTheme)),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        width: DM.p1,
                                                        color:
                                                            appTheme), //<-- SEE HERE
                                                  ),
                                                  filled: true,
                                                  fillColor: fullWhiteColor,
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          horizontal: DM.p10),
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
                                  ),
                                  FormUserInfo(
                                    formKey: _formKey,
                                    textInputType: TextInputType.number,
                                    controller: agent_commission,
                                    title: "Agent Commission",
                                    value: "0",
                                    activate: true,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(DM.p5),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: DM.p100,
                                          child: Text(
                                            "Next Status",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: DM.p14,
                                                color: Color.fromARGB(
                                                    255, 26, 1, 1)),
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
                                          value: createReqController.status[int.tryParse(teststatus.text) ?? 0],
                                          hint: Text(
                                            createReqController.status[int.tryParse(teststatus.text) ?? 0] ?? "Select status",
                                            style: TextStyle(color: blackFontColor),
                                          ),
                                          items: (typeUser == "4" && phoneNumber != superUser
                                              ? ["PENDING", "RECIEVED"]
                                              : [
                                            "PENDING",
                                            "RECIEVED",
                                            "PRECOLLECTED",
                                            "COLLECTED",
                                            "READY",
                                            "R.RECIEVED",
                                            "DELIVERED",
                                            "CANCEL"
                                          ])
                                              .map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(
                                                value,
                                                style: TextStyle(color: blackFontColor),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (newValue) {
                                            if (newValue != null) {
                                              setState(() {
                                                teststatus.text = createReqController.toStatus[newValue]!.toString();
                                              });
                                            }
                                          },
                                        )

                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : SizedBox(),
                        Padding(
                          padding: EdgeInsets.all(DM.p5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: DM.p100,
                                child: Text(
                                  "Delivery Date",
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
                                  height: DM.p42,
                                  child: InkWell(
                                    onTap: () async {
                                      print("ADNANN");
                                      final DateTime? picked =
                                          await showDatePicker(
                                              context: context,
                                              initialDate: DateTime
                                                  .fromMillisecondsSinceEpoch(
                                                      dateTime_delivery),
                                              initialDatePickerMode:
                                                  DatePickerMode.day,
                                              firstDate:
                                                  DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                          1669831200000),
                                              lastDate: DateTime
                                                  .fromMillisecondsSinceEpoch(
                                                      1922292000000));
                                      if (picked != null)
                                        setState(() {
                                          delivery_date.text =
                                              DateFormat.yMMMd().format(picked);
                                          print(picked.millisecondsSinceEpoch);

                                          dateTime_delivery =
                                              picked.millisecondsSinceEpoch;
                                        });
                                    },
                                    child: IgnorePointer(
                                      child: TextFormField(
                                        controller: delivery_date,
                                        decoration: InputDecoration(
                                            errorStyle:
                                                TextStyle(fontSize: DM.p9),
                                            // focusedErrorBorder:
                                            //     OutlineInputBorder(
                                            //         borderSide: BorderSide(
                                            //             width: DM.p1,
                                            //             color:
                                            //                 orangeColor)),
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    width: DM.p1,
                                                    color: appTheme)),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  width: DM.p1,
                                                  color:
                                                      appTheme), //<-- SEE HERE
                                            ),
                                            filled: true,
                                            fillColor: fullWhiteColor,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: DM.p10),
                                            border: InputBorder.none,
                                            hintText: "Ex:Chittagong",
                                            hintStyle: TextStyle(
                                              color: Colors.grey,
                                              fontSize: DM.p14,
                                            )),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        FormUserInfo(
                          formKey: _formKey,
                          textInputType: TextInputType.name,
                          controller: comments,
                          title: "Comments",
                          value: "Write your comments",
                          activate: false,
                        ),

                        Padding(
                          padding: EdgeInsets.all(DM.p5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: DM.p100,
                                child: Text(
                                  "Advanced",
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
                                  height: DM.p42,
                                  child: TextFormField(
                                    readOnly: ((widget.testEachRequest?.advanced ?? 0) > 0)  &&  phoneNumber != superUser,
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      setState(() {
                                        calculationProcess();
                                      });
                                    },
                                    controller: advanced,
                                    decoration: InputDecoration(
                                        errorStyle: TextStyle(fontSize: DM.p9),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                width: DM.p1, color: appTheme)),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: DM.p1,
                                              color: appTheme), //<-- SEE HERE
                                        ),
                                        filled: true,
                                        fillColor: fullWhiteColor,
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: DM.p10),
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
                        ),
                        widget.testEachRequest?.teststatus <= 6 ||
                            widget.testEachRequest?.teststatus == 8
                            ? Padding(
                          padding: EdgeInsets.all(DM.p5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: DM.p100,
                                child: Text(
                                  "Due Received One",
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
                                  height: DM.p42,
                                  child: TextFormField(
                                    readOnly:isReadOnlyDueReceivedOne && phoneNumber != superUser,
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                   setState(() {
                                     calculationProcess();
                                   });
                                    },
                                    controller: due_recieved_one,
                                    decoration: InputDecoration(
                                        errorStyle:
                                        TextStyle(fontSize: DM.p9),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                width: DM.p1,
                                                color: appTheme)),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: DM.p1,
                                              color:
                                              appTheme), //<-- SEE HERE
                                        ),
                                        filled: true,
                                        fillColor: fullWhiteColor,
                                        contentPadding:
                                        EdgeInsets.symmetric(
                                            horizontal: DM.p10),
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

                            widget.testEachRequest?.teststatus <= 6 ||
                                widget.testEachRequest?.teststatus == 8
                            ? Padding(
                          padding: EdgeInsets.all(DM.p5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: DM.p100,
                                child: Text(
                                  "Due Received Two",
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
                                  height: DM.p42,
                                  child: TextFormField(
                                    readOnly:isReadOnlyDueReceivedTwo && phoneNumber != superUser,
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      setState(() {
                                        calculationProcess();
                                      });
                                    },
                                    controller: due_recieved_two,
                                    decoration: InputDecoration(
                                        errorStyle:
                                        TextStyle(fontSize: DM.p9),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                width: DM.p1,
                                                color: appTheme)),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: DM.p1,
                                              color:
                                              appTheme), //<-- SEE HERE
                                        ),
                                        filled: true,
                                        fillColor: fullWhiteColor,
                                        contentPadding:
                                        EdgeInsets.symmetric(
                                            horizontal: DM.p10),
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
                          padding: EdgeInsets.all(DM.p5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: DM.p100,
                                child: Text(
                                  "Due Amount",
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
                                  height: DM.p42,
                                  child: TextFormField(
                                    readOnly: phoneNumber == superUser ? false : true,
                                    keyboardType: TextInputType.number,
                                    controller: due_amount,
                                    decoration: InputDecoration(
                                        errorStyle:
                                        TextStyle(fontSize: DM.p9),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                width: DM.p1,
                                                color: appTheme)),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: DM.p1,
                                              color:
                                              appTheme), //<-- SEE HERE
                                        ),
                                        filled: true,
                                        fillColor: fullWhiteColor,
                                        contentPadding:
                                        EdgeInsets.symmetric(
                                            horizontal: DM.p10),
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
                        ),

                        // FormUserInfo(
                        //   formKey: _formKey,
                        //   textInputType: TextInputType.name,
                        //   controller: due_amount,
                        //   title: "Due Amount",
                        //   value: "${totalCost -
                        //       (int.tryParse(advanced.text) ?? 0) -
                        //       (int.tryParse(due_recieved_one.text) ?? 0) -
                        //       (int.tryParse(due_recieved_two.text) ?? 0)}",
                        //
                        //   activate: phoneNumber == superUser ? false : true,
                        // ),

                        FormUserInfo(
                          formKey: _formKey,
                          textInputType: TextInputType.number,
                          controller: total_discount,
                          title: "Total Discount",
                          value: "0",
                          activate: phoneNumber == superUser ? false : true,
                        ),
                        // FormUserInfo(
                        //   formKey: _formKey,
                        //   textInputType: TextInputType.number,
                        //   controller: softdelete,
                        //   title: "Soft delete",
                        //   value: "0",
                        //   activate: false,
                        // ),

                        widget.testEachRequest!.assigning == phoneNumber ||
                                phoneNumber == superUser ||
                                typeUser == "7" ||
                                typeUser == "3"
                            ? Padding(
                                padding: EdgeInsets.all(DM.p5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: DM.p100,
                                      child: Text(
                                        "Pathology Assigning Commission",
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
                                        height: DM.p42,
                                        child: TextFormField(
                                          readOnly: true,
                                          keyboardType: TextInputType.number,
                                          onChanged: (value) {},
                                          controller: assigning_commission,
                                          decoration: InputDecoration(
                                              errorStyle:
                                                  TextStyle(fontSize: DM.p9),
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      width: DM.p1,
                                                      color: appTheme)),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    width: DM.p1,
                                                    color:
                                                        appTheme), //<-- SEE HERE
                                              ),
                                              filled: true,
                                              fillColor: fullWhiteColor,
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: DM.p10),
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
                        widget.testEachRequest!.radiology_assigning ==
                                    phoneNumber ||
                                phoneNumber == superUser ||
                                typeUser == "7" ||
                                typeUser == "3"
                            ? Padding(
                                padding: EdgeInsets.all(DM.p5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: DM.p100,
                                      child: Text(
                                        "Radiology Assigning Commission",
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
                                        height: DM.p42,
                                        child: TextFormField(
                                          readOnly: true,
                                          keyboardType: TextInputType.number,
                                          onChanged: (value) {},
                                          controller:
                                              radiology_assigning_commission,
                                          decoration: InputDecoration(
                                              errorStyle:
                                                  TextStyle(fontSize: DM.p9),
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      width: DM.p1,
                                                      color: appTheme)),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    width: DM.p1,
                                                    color:
                                                        appTheme), //<-- SEE HERE
                                              ),
                                              filled: true,
                                              fillColor: fullWhiteColor,
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: DM.p10),
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
                        typeUser == "4" && phoneNumber != superUser
                            ? SizedBox()
                            : Padding(
                                padding: EdgeInsets.all(DM.p5),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: DM.p100,
                                      child: Text(
                                        "Pathology Assigning",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: DM.p14,
                                            color:
                                                Color.fromARGB(255, 26, 1, 1)),
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
                                        "${assigningMapping[pathologyAssigningPhone]}",
                                        style: TextStyle(color: blackFontColor),
                                      ),
                                      items: collectionUserList.map((
                                        AdminUserModel value,
                                      ) {
                                        return DropdownMenuItem<String>(
                                          value: value.phone,
                                          child: Text(
                                            "${value.name}",
                                            style: TextStyle(
                                                color: blackFontColor),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (newValue) {
                                        setState(() {
                                          if (widget.testEachRequest!
                                                  .pathology_done !=
                                              true) {
                                            pathologyAssigningPhone = newValue!;
                                            assigning_commission.text = getUserCommission(newValue,"PATHOLOGY");
                                          }
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),

                        typeUser == "4" && phoneNumber != superUser
                            ? SizedBox()
                            : Padding(
                                padding: EdgeInsets.all(DM.p5),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: DM.p100,
                                      child: Text(
                                        "Radiology Assigning",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: DM.p14,
                                            color:
                                                Color.fromARGB(255, 26, 1, 1)),
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
                                        "${assigningMapping[radiologyAssigningPhone]}",
                                        style: TextStyle(color: blackFontColor),
                                      ),
                                      items: collectionUserList.map((
                                        AdminUserModel value,
                                      ) {
                                        return DropdownMenuItem<String>(
                                          value: value.phone,
                                          child: Text(
                                            "${value.name}",
                                            style: TextStyle(
                                                color: blackFontColor),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (newValue) {
                                        setState(() {
                                          if (widget.testEachRequest!
                                                  .radiology_done !=
                                              true) {
                                            radiologyAssigningPhone = newValue!;
                                            radiology_assigning_commission.text = getUserCommission(newValue,"RADIOLOGY");
                                          }
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),

                        widget.testEachRequest!.assigning == phoneNumber ||
                                typeUser == "3" ||
                                typeUser == "7" ||
                                phoneNumber == superUser
                            ? Padding(
                                padding: EdgeInsets.all(DM.p5),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: DM.p100,
                                      child: Text(
                                        "Pathology Collected",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: DM.p14,
                                            color:
                                                Color.fromARGB(255, 26, 1, 1)),
                                      ),
                                    ),
                                    SizedBox(
                                      width: DM.p5,
                                    ),
                                    Text(":"),
                                    SizedBox(
                                      width: DM.p10,
                                    ),
                                    Checkbox(
                                      value: pathologyDone,
                                      onChanged: (value) {
                                        final isSuperUser = phoneNumber == superUser;
                                        if (isSuperUser) {
                                          setState(() {
                                            pathologyDone = !pathologyDone;
                                          });
                                        } else if (typeUser == "4") {
                                          if (widget.testEachRequest?.pathology_done != true) {
                                            setState(() {
                                              pathologyDone = !pathologyDone;
                                            });
                                          }
                                        }
                                      },
                                    )
                                  ],
                                ),
                              )
                            : SizedBox(),
                        widget.testEachRequest!.radiology_assigning ==
                                    phoneNumber ||
                                typeUser == "3" ||
                                typeUser == "7" ||
                                phoneNumber == superUser
                            ? Padding(
                                padding: EdgeInsets.all(DM.p5),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: DM.p100,
                                      child: Text(
                                        "Radiology Collected",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: DM.p14,
                                            color:
                                                Color.fromARGB(255, 26, 1, 1)),
                                      ),
                                    ),
                                    SizedBox(
                                      width: DM.p5,
                                    ),
                                    Text(":"),
                                    SizedBox(
                                      width: DM.p10,
                                    ),
                                    Checkbox(
                                      value: radiologyDone,
                                      onChanged: (value) {
                                        final isSuperUser = phoneNumber == superUser;
                                        if (isSuperUser) {
                                          setState(() {
                                            radiologyDone = !radiologyDone;
                                          });
                                        } else if (typeUser == "4") {
                                          if (widget.testEachRequest?.radiology_done != true) {
                                            setState(() {
                                              radiologyDone = !radiologyDone;
                                            });
                                          }
                                        }
                                      },
                                    )

                                  ],
                                ),
                              )
                            : SizedBox(),
                      ],
                    )),

                // #text_field

                // #signup_button

                Container(
                  margin:
                      EdgeInsets.symmetric(horizontal: DM.p20, vertical: DM.p1),
                  child: MaterialButton(
                    onPressed: () async {
                      if (_formKey.currentState?.validate() == true) {
                        if (await chechkingInternet()) {
                          if (widget.testEachRequest!.teststatus == 2 ||
                              widget.testEachRequest!.teststatus == 8) {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return MyDialogView(
                                    myChild: Padding(
                                      padding: EdgeInsets.all(DM.p8),
                                      child: Stack(
                                        children: [
                                          Container(
                                              color: secondaryColor,
                                              height: DM.screenHeight * 0.8,
                                              width: DM.screenWidth * 0.9,
                                              padding: EdgeInsets.all(DM.p15),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Confirmation",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        fontSize: DM.p25,
                                                        color: Color.fromARGB(
                                                            255, 26, 1, 1)),
                                                  ),
                                                  Text(
                                                    "Name: ${name.text}",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: DM.p15,
                                                        color: Color.fromARGB(
                                                            255, 26, 1, 1)),
                                                  ),
                                                  Text(
                                                    "Phone: ${phone.text}",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: DM.p15,
                                                        color: Color.fromARGB(
                                                            255, 26, 1, 1)),
                                                  ),
                                                  Text(
                                                    "Address: ${address.text}",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: DM.p15,
                                                        color: Color.fromARGB(
                                                            255, 26, 1, 1)),
                                                  ),
                                                  Text(
                                                    "Referrer: ${referrer.text}",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: DM.p15,
                                                        color: Color.fromARGB(
                                                            255, 26, 1, 1)),
                                                  ),
                                                  Text(
                                                    "Delivery Date: ${delivery_date.text} 8:00 PM",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: DM.p15,
                                                        color: Color.fromARGB(
                                                            255, 26, 1, 1)),
                                                  ),
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        "Test List",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: DM.p20,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    26,
                                                                    1,
                                                                    1)),
                                                      ),
                                                      Divider(
                                                        thickness: DM.p1,
                                                        color: blackFontColor,
                                                        indent: DM.screenWidth *
                                                            0.2,
                                                        endIndent:
                                                            DM.screenWidth *
                                                                0.2,
                                                      ),
                                                      Card(
                                                          child: Container(
                                                        height:
                                                            DM.screenHeight *
                                                                0.30,
                                                        child: ListView.builder(
                                                          itemCount:
                                                              testData_updated
                                                                  .length,
                                                          itemBuilder:
                                                              (context, index) {
                                                            return Container(
                                                              color: whiteColor,
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal: DM
                                                                          .p10,
                                                                      vertical:
                                                                          DM.p5),
                                                              margin: EdgeInsets
                                                                  .symmetric(
                                                                      vertical:
                                                                          DM.p10),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Expanded(
                                                                    child:
                                                                        SizedBox(
                                                                      width: DM
                                                                          .p130,
                                                                      child:
                                                                          Text(
                                                                        testData_updated[index].name +
                                                                            " (${testData_updated[index].diagnostic_center})",
                                                                        style: TextStyle(
                                                                            fontWeight: FontWeight
                                                                                .w900,
                                                                            fontSize: DM
                                                                                .p12,
                                                                            color: Color.fromARGB(
                                                                                255,
                                                                                26,
                                                                                1,
                                                                                1)),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    "Price: " +
                                                                        (testData_updated[index].testprice)
                                                                            .toString(),
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w900,
                                                                        fontSize: DM
                                                                            .p12,
                                                                        color: Color.fromARGB(
                                                                            255,
                                                                            26,
                                                                            1,
                                                                            1)),
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      )),
                                                    ],
                                                  ),
                                                  Text(
                                                    "(Test + Tube + Collection) = (${totalTestCost}+${tubeCost}+${serviceCost} ) =  ${totalTestCost + tubeCost + serviceCost} /-",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        fontSize: DM.p12,
                                                        color: Color.fromARGB(
                                                            255, 26, 1, 1)),
                                                  ),
                                                  Text(
                                                    "Discount : ${totalDiscount} /-",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        fontSize: DM.p13,
                                                        color: Color.fromARGB(
                                                            255, 26, 1, 1)),
                                                  ),
                                                  Divider(
                                                    thickness: DM.p1,
                                                    color: blackFontColor,
                                                    endIndent: DM.p100,
                                                  ),
                                                  Text(
                                                    "Total Cost: ${totalCost} /-",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        fontSize: DM.p18,
                                                        color: Color.fromARGB(
                                                            255, 26, 1, 1)),
                                                  ),
                                                  Text(
                                                    "Advanced: ${advanced.text} /-",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: DM.p14,
                                                        color: Color.fromARGB(
                                                            255, 26, 1, 1)),
                                                  ),
                                                  Text(
                                                    "Due Amount: ${due_amount.text} /-",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: DM.p14,
                                                        color: Color.fromARGB(
                                                            255, 26, 1, 1)),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      MaterialButton(
                                                        onPressed: () {
                                                          Get.back();
                                                        },
                                                        height: DM.p45,
                                                        minWidth: DM.p120,
                                                        shape:
                                                            const StadiumBorder(),
                                                        color: redColor,
                                                        child: Text(
                                                          "Cancel",
                                                          style: TextStyle(
                                                              color:
                                                                  fullWhiteColor,
                                                              fontSize: DM.p15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                      MaterialButton(
                                                        onPressed: () async {
                                                          if (await chechkingInternet()) {
                                                            uploadImage();

                                                            Get.back();
                                                          }
                                                        },
                                                        height: DM.p45,
                                                        minWidth: DM.p120,
                                                        shape:
                                                            const StadiumBorder(),
                                                        color: appTheme,
                                                        child: Text(
                                                          "Confirm",
                                                          style: TextStyle(
                                                              color:
                                                                  fullWhiteColor,
                                                              fontSize: DM.p15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              )),
                                          Positioned(
                                              right: DM.p10,
                                              top: DM.p10,
                                              child: IconButton(
                                                icon:
                                                    Icon(CupertinoIcons.xmark),
                                                onPressed: () {
                                                  Get.back();
                                                },
                                              ))
                                        ],
                                      ),
                                    ),
                                  );
                                });
                          } else {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return Scaffold(
                                    backgroundColor: Colors.transparent,
                                    body: Center(
                                      child: Container(
                                          margin: EdgeInsets.all(DM.p10),
                                          height: DM.p200,
                                          color: secondaryColor,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(16),
                                                margin: EdgeInsets.all(16),
                                                child: Text(
                                                  createReqController.status[
                                                              int.parse(
                                                                  teststatus
                                                                      .text)] ==
                                                          "PRECOLLECTED"
                                                      ? "Are you want to submit to ${createReqController.status[3]}?"
                                                      : "Are you want to submit to ${createReqController.status[int.parse(teststatus.text)]}?",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: DM.p20,
                                                      color: Color.fromARGB(
                                                          255, 26, 1, 1)),
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            horizontal: DM.p20,
                                                            vertical: DM.p10),
                                                    child: MaterialButton(
                                                      onPressed: () {
                                                        Get.back();
                                                      },
                                                      height: DM.p40,
                                                      minWidth: DM.p120,
                                                      shape:
                                                          const StadiumBorder(),
                                                      color: appTheme,
                                                      child: Text(
                                                        "Cancel",
                                                        style: TextStyle(
                                                            color:
                                                                fullWhiteColor,
                                                            fontSize: DM.p15,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            horizontal: DM.p20,
                                                            vertical: DM.p10),
                                                    child: MaterialButton(
                                                      onPressed: () async {
                                                        if (_formKey
                                                                .currentState
                                                                ?.validate() ==
                                                            true) {
                                                          if (await chechkingInternet()) {
                                                            Get.back();
                                                            uploadImage();

                                                            //cr_controller.filter_testItemList.removeAt(index);
                                                          }
                                                        }
                                                      },
                                                      height: DM.p40,
                                                      minWidth: DM.p120,
                                                      shape:
                                                          const StadiumBorder(),
                                                      color: appTheme,
                                                      child: Text(
                                                        "Yes",
                                                        style: TextStyle(
                                                            color:
                                                                fullWhiteColor,
                                                            fontSize: DM.p15,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ],
                                          )),
                                    ),
                                  );
                                });
                          }
                        }
                      } else {
                        Get.snackbar(
                            duration: Duration(milliseconds: 2000),
                            icon: Icon(Icons.error),
                            margin: EdgeInsets.symmetric(
                                horizontal: DM.p70, vertical: DM.p60),
                            backgroundColor: Color.fromARGB(255, 202, 0, 0),
                            colorText: whiteColor,
                            "Error!",
                            "Please add info properly!");
                      }
                    },
                    height: DM.p40,
                    minWidth: DM.p120,
                    shape: const StadiumBorder(),
                    color: appTheme,
                    child: Text(
                      "Confirm",
                      style: TextStyle(
                          color: fullWhiteColor,
                          fontSize: DM.p15,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                )

                // #buttons(facebook & github)
              ],
            ),
          ),
        ),
      ),
    );
  }

  void handleDisbaleDueReecieve() {
    final req = widget.testEachRequest;
    bool isDueAmountZero = (req?.due_amount ?? 0) == 0 && (int.tryParse(due_amount.text)??0) == 0;


    if(!handleFirstTimeInitPage){
      isReadOnlyDueReceivedOne = isDueAmountZero;
      if(!isReadOnlyDueReceivedOne){
        if ((req?.due_recieved_one ?? 0) > 0 &&
            (req?.due_recieved_two ?? 0) > 0 &&
            req?.due_recieve_one_date != null &&
            req?.due_recieve_two_date != null) {

          if((req?.due_recieve_one_date ?? 0) == (req?.due_recieve_two_date ?? 0)){
            isReadOnlyDueReceivedOne = true;
          }else{
            isReadOnlyDueReceivedOne =
                (req?.due_recieve_one_date ?? 0) < (req?.due_recieve_two_date ?? 0);
          }
        }
        else {
          if ((req?.due_recieved_one ?? 0) != 0){
            isReadOnlyDueReceivedOne = true;
          }
          else{
            isReadOnlyDueReceivedOne =  false;
          }
        }
      }

      isReadOnlyDueReceivedTwo =isDueAmountZero;
      if(!isReadOnlyDueReceivedTwo){
        if ((req?.due_recieved_one ?? 0) > 0 &&
            (req?.due_recieved_two ?? 0) > 0 &&
            req?.due_recieve_one_date != null &&
            req?.due_recieve_two_date != null) {
          isReadOnlyDueReceivedTwo =
              (req?.due_recieve_two_date ?? 0) < (req?.due_recieve_one_date ?? 0);
        } else {
          if ((req?.due_recieved_two ?? 0) != 0){
            isReadOnlyDueReceivedTwo = true;
          }
          else{
            isReadOnlyDueReceivedTwo = false;
          }
        }
      }
      handleFirstTimeInitPage = true;
    }
    // Update the readOnly values based on the logic
  }

  void testItemUpdatedData() {
    if (init == false) {
      testData_updated.clear();

      testItemList.map((e) {
        if (testItemListWithSelected[e.id] == true) {
          testData_updated.add(e);
          testItemListWithSelected[e.id] = true;
        }
      }).toList();
    }
    init = false;
    calculationProcess();
    handleFirstTimeInitPage = false;
    handleDisbaleDueReecieve();
  }

  String getUserCommission(dynamic phone, dynamic assigningType) {
    AdminUserModel? matchedUser;
    try {
      matchedUser = adminUserList.firstWhere((e) => e.phone.toString() == phone.toString(),
      );
    } catch (e) {
      return '0';
    }

    switch (assigningType.toString().toUpperCase()) {
      case 'PATHOLOGY':
        final commissionStr = matchedUser.pathology_commission?.toString() ?? '0';
        final commission = double.tryParse(commissionStr) ?? 0.0;
        return  (((total_payable_pathology * commission) / 100)).toInt().toString();

      case 'RADIOLOGY':
        final commissionStr = matchedUser.imagine_commission?.toString() ?? '0';
        final commission = double.tryParse(commissionStr) ?? 0.0;
        return (((total_payable_imaging * commission) / 100)).toInt().toString();;

      default:
        return '';
    }
  }


}

  class FormUserInfo extends StatelessWidget {
  dynamic title;
  dynamic value;
  dynamic activate;
  dynamic formKey;
  dynamic validatorField;

  var controller = new TextEditingController();
  var textInputType;

  FormUserInfo({
    Key? key,
    required this.formKey,
    required this.title,
    required this.value,
    required this.activate,
    required this.controller,
    required this.textInputType,
    this.validatorField,
  }) : super(
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(DM.p5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: DM.p100,
            child: Text(
              title,
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
          Flexible(
            child: Container(
              child: TextFormField(
                validator: validatorField,
                onChanged: ((value) {
                  if (!formKey.currentState?.validate())
                    formKey.currentState?.validate();
                }),
                keyboardType: textInputType,
                maxLines: null,
                controller: controller,
                readOnly: activate,
                decoration: InputDecoration(
                    errorStyle: TextStyle(fontSize: DM.p9),
                    disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: DM.p1, color: appTheme)),
                    // focusedErrorBorder: OutlineInputBorder(
                    //     borderSide:
                    //         BorderSide(width: DM.p1, color: orangeColor)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: DM.p1, color: appTheme)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: DM.p1, color: appTheme), //<-- SEE HERE
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(horizontal: DM.p10),
                    border: InputBorder.none,
                    hintText: value,
                    hintStyle: TextStyle(
                      color: activate ? blackFontColor : Colors.grey,
                      fontSize: DM.p14,
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String? validateMobile(String? value) {
  if (value?.length != 11 && value?.length != 12)
    return 'Mobile Number must be of 11 and 12 digits';
  else
    return null;
}

String? validateString(String? value) {
  if (value?.length == 0)
    return 'Please fill this form';
  else
    return null;
}

Future<void> InvoicePrint(TestDataRequest testDataRequest, totalDiscount,
    due_amount, advanced, tubeCost,assigningMapping) async {
  final date = DateTime.now().millisecondsSinceEpoch;

  final invoice = Invoice(
      customer: Customer(
          id: testDataRequest.id,
          invoice_id: testDataRequest.invoice_call,
          name: testDataRequest.name,
          address: testDataRequest.address,
          gender: testDataRequest.gender,
          referrer: testDataRequest.referrer,
          age: testDataRequest.age,
          date: date,
          totalAmount: testDataRequest.totalprice,
          advance: advanced.text.toString(),
          dueRecieveOne: testDataRequest.due_recieved_one,
          dueRecieveTwo: testDataRequest.due_recieved_two,
          dueAmount: due_amount.text.toString(),
          totalDiscount: totalDiscount,
          testItems: testDataRequest.testlist,
          collection_charge: testDataRequest.servicecharge,
          tube_cost: tubeCost,
          deliveryDate: testDataRequest.delivery_date,
          reciever_name: assigningMapping[testDataRequest.due_recieved_two_by],
          last_modifier: testDataRequest.last_modifier,
          prepared_by: testDataRequest.prepared_by,
          totalCashRecieved: testDataRequest.total_cash_recieve),
      info: InvoiceInfo(
        date: DateTime.now(),
        description: 'My description...',
        number: '${DateTime.now().year}-9999',
      ),
      items: List.generate(
          testDataRequest.testlist!.length,
          (index) => InvoiceItem(
              testName: testDataRequest.testlist![index].name +
                  " (${testDataRequest.testlist![index].diagnostic_center})",
              testPrice: testDataRequest.testlist![index].testprice,
              serialNumber: index + 1)));

  final pdfFile = await PdfInvoiceApi.generate(invoice);
  final pdfFile2 = await PdfInvoiceApiNoCustomer.generate(invoice);

  PdfApi.openFile(pdfFile);
  PdfApi.openFile(pdfFile2);
}
