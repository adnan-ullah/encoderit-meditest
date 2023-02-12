import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:healthcare_homelab/animations/Custom_Dialog.dart';
import 'package:healthcare_homelab/presentation/pages/Create_Request.dart';
import 'package:healthcare_homelab/presentation/pages/HomeScreen.dart';
import 'package:healthcare_homelab/presentation/widgets/projectsWidget/ConfirmationList.dart';
import 'package:healthcare_homelab/presentation/widgets/projectsWidget/Notifications/GenerateNotification.dart';
import 'package:healthcare_homelab/presentation/widgets/projectsWidget/TestListDialogueBox.dart';
import 'package:healthcare_homelab/presentation/widgets/projectsWidget/TextBoxDialogBox.dart';
import 'package:healthcare_homelab/presentation/widgets/minorWidgets/smallDialogBox.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../constants/app_info.dart';
import '../../constants/colors.dart';
import '../../db/databse_model.dart';
import '../../responsives/dimensions.dart';
import '../../state_programming/Create_Request_Controller.dart';
import '../../state_programming/getController.dart';
import '../widgets/projectsWidget/Notifications/NotificationServices.dart';
import 'Login_info.dart';

class CreateRequest extends StatefulWidget {
  // static const String id = "sign_up_page";

  const CreateRequest({Key? key}) : super(key: key);

  @override
  _CreateRequestState createState() => _CreateRequestState();
}

class _CreateRequestState extends State<CreateRequest> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? latitude;
  String? longitude;
  CreateRequest_controller createRequest_controller =
      Get.put(CreateRequest_controller());
  void getGPS() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied');
      } else if (permission == LocationPermission.deniedForever) {
        print("'Location permissions are permanently denied");
      } else {
        bool servicestatus = await Geolocator.isLocationServiceEnabled();
        if (servicestatus) {
          Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high);
          setState(() {
            longitude = position.longitude.toString();
            latitude = position.latitude.toString();
          });

          print("YEAHHHHH!!!");
        } else {
          print("WRONG");
        }
      }
    } else {
      bool servicestatus = await Geolocator.isLocationServiceEnabled();
      if (servicestatus) {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);

        longitude = position.longitude.toString();
        latitude = position.latitude.toString();

        print("YEAHHHHH!!!");
      } else {
        print("GPS Location reallllly granted.");
      }
      print("GPS Location permission granted.");
    }
  }

  @override
  void initState() {
    createReqController.totalTestCost.value = 0;
    createReqController.totalCost.value = 0;
    createReqController.serviceCost.value = 0;
    createReqController.totalDiscount.value = 0;
    createReqController.tubeCost.value = 0;

    getSharedData();

    //populate testItemList
    getTestItemList();

    setState(() {
      getGPS();
    });
    // TODO: implement initState
    super.initState();
  }

  final addressText = TextEditingController();
  final referredAddressText = TextEditingController();

  var name = new TextEditingController();
  var age = TextEditingController();
  var phone = TextEditingController();

  //form variables:
  var testCost = 0;
  var totalCost = 0;
  var serviceCost = 0;
  var tubeCost = 0;
  var totalDiscount = 0;
  var newRequestData;



  String? gender = "Male";
  File? imageDiscountFile;
  UploadTask? uploadTask3;
  var urlDownload3;

  CreateRequest_controller createReqController =
      Get.put(CreateRequest_controller());

  Future<void> getSharedData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    phone.text = prefs.getString("phoneNumber").toString();
    referredAddressText.text = prefs.getString("referrer_code").toString();
  }

  Future<void> uploadImage() async {


    final SharedPreferences pref = await SharedPreferences.getInstance();


    final path3 = "files/${phone.text}/${imageDiscountFile}";


    final ref3 = FirebaseStorage.instance.ref().child(path3);






    if (imageDiscountFile != null) {
      uploadTask3 = ref3.putFile(imageDiscountFile!);
      final snapshot3 = await uploadTask3!.whenComplete(() {});
      urlDownload3 = await snapshot3.ref.getDownloadURL();
    }



    addTestRequest();

    Get.back();
    Get.back();
    Get.back();

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
                    color: orangeColor,
                  ),
                  SizedBox(
                    width: DM.p10,
                  ),
                  new Text(
                    "Submitting, please wait...",
                    style: TextStyle(color: orangeColor),
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


  void initialTestRequest() {

    int currentTime = DateTime.now().millisecondsSinceEpoch;
    setState(() {
      newRequestData = TestDataRequest(
          id: ((Random().nextInt(900000) + 100000).toString()),
          name: name.text!,
          gender: gender,
          mobile: phone.text,
          age: age.text,
          testlist: createReqController.testData,
          totalprice: createReqController.totalCost.value,
          servicecharge: createReqController.serviceCost.value,
          address: addressText.text,
          referrer: referredAddressText.text,
          lastupdate: currentTime,
          dateofcreated: currentTime,
          softdelete: 0,
          latitude: latitude,
          longitude: longitude,
          teststatus: 1,
          invoice_call: phone.text.substring(7) +
              "-" +
              (Random().nextInt(900000) + 100000).toString(),
          type: 1,
          image_one: null,
          image_two: null,
          comments: null,
          delivery_date: null,
          total_payable_imagine_cost: 0,
          total_payable_pathology_cost: 0,
          total_payable: 0,
          total_unpayable: 0,
          admin_pathology_discount: 0,
          admin_radiology_discount: 0,
          agent_commission: 0,
          agent_pathology_discount: 0,
          agent_radiology_discount: 0,
          area: "",
          assigning: "",
          assigning_commission: 0,
          advanced: 0,
          due_amount: 0,
          test_item_cost: createReqController.totalTestCost.value,
          test_item_discount: 0,
          total_admin_discount: 0,
          total_agent_discount: 0,
          total_discount: createReqController.totalDiscount.value,
          is_paid: false,
          total_unpayable_imagine: 0,
          total_unpayable_pathology: 0, payment_date: 0,
          imageDiscountFile: urlDownload3
      );
    });
  }

  Future<void> UpdateTestRequest() async {
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    // DateTime currentTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    // String currentTime = DateFormat('dd-MMM-yyy').format(tsdate);

    late DatabaseReference _dbref_testReqModel;
    _dbref_testReqModel = FirebaseDatabase.instance.ref("$database_name/");

    newRequestData = TestDataRequest(
        id: ((Random().nextInt(900000) + 100000).toString()),
        name: name.text,
        gender: gender,
        mobile: phone.text,
        age: age.text,
        testlist: createReqController.testData,
        totalprice: createReqController.totalCost.value,
        servicecharge: createReqController.serviceCost.value,
        address: addressText.text,
        referrer: referredAddressText.text,
        lastupdate: currentTime,
        dateofcreated: currentTime,
        softdelete: 0,
        latitude: latitude,
        longitude: longitude,
        teststatus: 1,
        invoice_call: phone.text.substring(7) +
            "-" +
            (Random().nextInt(900000) + 100000).toString(),
        type: 1,
        image_one: null,
        image_two: null,
        total_payable_imagine_cost: 0,
        total_payable_pathology_cost: 0,
        total_payable: 0,
        total_unpayable: 0,
        admin_pathology_discount: 0,
        admin_radiology_discount: 0,
        agent_commission: 0,
        agent_pathology_discount: 0,
        agent_radiology_discount: 0,
        area: "",
        assigning: "",
        assigning_commission: 0,
        advanced: 0,
        comments: "",
        delivery_date: null,
        due_amount: 0,
        test_item_cost: createReqController.totalTestCost.value,
        test_item_discount: 0,
        total_admin_discount: 0,
        total_agent_discount: 0,
        total_discount: createReqController.totalDiscount.value,
        is_paid: false,
        total_unpayable_imagine: 0,
        total_unpayable_pathology: 0, payment_date: 0);

    if (newRequestData != null) {
      await _dbref_testReqModel
          .child("testRequest")
          .update({newRequestData.mobile.toString(): "125412"});

      Get.snackbar(
          margin: EdgeInsets.symmetric(horizontal: DM.p70, vertical: DM.p60),
          duration: Duration(milliseconds: 2000),
          backgroundColor: Colors.yellow,
          colorText: whiteColor,
          "Update",
          "Data Update  , successfully!");
    } else {
      Get.snackbar(
          duration: Duration(milliseconds: 2000),
          margin: EdgeInsets.symmetric(horizontal: DM.p70, vertical: DM.p60),
          backgroundColor: redColor,
          colorText: whiteColor,
          "Request already exist",
          "Failed to added!");
    }
  }

  Future<void> addTestRequest() async {

    int currentTime = DateTime.now().millisecondsSinceEpoch;
    // DateTime currentTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    // String currentTime = DateFormat('dd-MMM-yyy').format(tsdate);



    late DatabaseReference _dbref_testReqModel;
    _dbref_testReqModel = FirebaseDatabase.instance.ref("$database_name/");

    newRequestData = TestDataRequest(
      id: ((Random().nextInt(900000) + 100000).toString()),
      name: name.text,
      gender: gender,
      mobile: phone.text,
      age: age.text,
      testlist: createReqController.testData,
      totalprice: createReqController.totalCost.value,
      servicecharge: createReqController.serviceCost.value,
      address: addressText.text,
      referrer: referredAddressText.text,
      lastupdate: currentTime,
      dateofcreated: currentTime,
      softdelete: 0,
      latitude: latitude,
      longitude: longitude,
      teststatus: 1,
      invoice_call: phone.text.substring(7) +
          "-" +
          (Random().nextInt(900000) + 100000).toString(),
      type: 1,
      image_one: null,
      image_two: null,
      comments: "",
      delivery_date: null,
      admin_pathology_discount: 0,
      admin_radiology_discount: 0,
      advanced: 0,
      agent_commission: 0,
      agent_pathology_discount: 0,
      agent_radiology_discount: 0,
      area: "",
      assigning: "",
      assigning_commission: 0,
      due_amount: 0,
      total_payable_imagine_cost: 0,
      total_payable_pathology_cost: 0,
      test_item_cost: createReqController.totalTestCost.value,
      test_item_discount:0 ,
      total_admin_discount: 0,
      total_agent_discount: 0,
      total_discount: createReqController.totalDiscount.value,
      total_payable: 0,
      total_unpayable: 0,
      is_paid: false,
      total_unpayable_pathology: 0,
      total_unpayable_imagine: 0, payment_date: 0,
        imageDiscountFile: urlDownload3
    );

    // DatabaseEvent ds = await _dbref_testReqModel
    //     .child("testRequest/${newRequestData.mobile.toString()}")
    //     .once();
    //checking duplicate child && add data
    if (newRequestData != null) {
      await _dbref_testReqModel
          .child("testRequest")
          .child(newRequestData.mobile.toString())
          .child(newRequestData.id)
          .set(newRequestData.toJson());


      Get.snackbar(
          margin: EdgeInsets.symmetric(horizontal: DM.p70, vertical: DM.p120),
          duration: Duration(milliseconds: 2000),
          backgroundColor: limeBGColor,
          colorText: whiteColor,
          "Added",
          "Data added , successfully!");
    } else {
      Get.snackbar(
          margin: EdgeInsets.symmetric(horizontal: DM.p70, vertical: DM.p120),
          duration: Duration(milliseconds: 2000),
          backgroundColor: redColor,
          colorText: whiteColor,
          "Request already exist",
          "Failed to added!");
    }
  }

  @override
  Widget build(BuildContext context) {
    chechkingInternet();
    void removeCalulationProcess(id) {
      createReqController.testData.removeWhere((element) => element.id == id);
      setState(() {
        createReqController.testData.map((testItem) {
          testCost = testCost + int.parse(testItem.testprice.toString());
          serviceCost =
              max(serviceCost, int.parse(testItem.servicecharge.toString()));

          tubeCost = tubeCost + int.parse(testItem.testkitprice.toString());
          totalDiscount =
              totalDiscount + int.parse(testItem.discount.toString());
        }).toList();

        totalCost = testCost + serviceCost + tubeCost - totalDiscount;

        createReqController.testItemListWithSelected[id] =
            !createReqController.testItemListWithSelected[id]!;

        createReqController.totalCost.value = totalCost;
        createReqController.totalTestCost.value = testCost;
        createReqController.serviceCost.value = serviceCost;
        createReqController.totalDiscount.value = totalDiscount;
        createReqController.tubeCost.value = tubeCost;

        testCost = 0;
        totalCost = 0;
        serviceCost = 0;
        tubeCost = 0;

        totalDiscount = 0;
      });
    }



    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(backgroundColor: orangeColor, actions: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: DM.p50, vertical: DM.p10),
          width: DM.screenWidth,
          child: Text(
            "Requisition form",
            textAlign: TextAlign.left,
            style: TextStyle(
                color: creamColor,
                fontWeight: FontWeight.bold,
                fontSize: DM.p25),
          ),
        ),
      ]),
      backgroundColor: creamColor,
      body: Form(
        key: _formKey,
        child: Container(
          height: DM.screenHeight,
          width: DM.screenWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: DM.screenWidth,
                    child: Column(
                      children: [
                        SizedBox(
                          height: DM.p4,
                        ),
                        Container(
                            padding: EdgeInsets.all(DM.p5),
                            margin: EdgeInsets.symmetric(horizontal: DM.p15),
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FormUserInfo(
                                  formKey: _formKey,
                                  validatorField: validateName,
                                  textInputType: TextInputType.name,
                                  controller: name,
                                  title: "Patient Name (রোগীর নাম)",
                                  // title: "Patient Name",
                                  value: "Write Your Name",
                                  activate: false,
                                ),
                                Padding(
                                  padding: EdgeInsets.all(DM.p1),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: DM.p100,
                                        child: Text(
                                          "Age (বয়স)",
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
                                            controller: age,
                                            keyboardType: TextInputType.name,
                                            // inputFormatters: <
                                            //     TextInputFormatter>[
                                            //   FilteringTextInputFormatter
                                            //       .digitsOnly
                                            // ],
                                            maxLines: null,
                                            // onTap: (() {
                                            //   showDialog(
                                            //       context: context,
                                            //       builder: (context) {
                                            //         return MyDialogView(
                                            //             myChild: TextDialogueBox(
                                            //                 keyTitle:
                                            //                     "Referrer Info",
                                            //                 addressText:
                                            //                     referredAddressText));
                                            //       });
                                            // }),
                                            decoration: InputDecoration(
                                                errorStyle:
                                                    TextStyle(fontSize: DM.p9),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            width: DM.p1,
                                                            color:
                                                                orangeColor)),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      width: DM.p1,
                                                      color:
                                                          orangeColor), //<-- SEE HERE
                                                ),
                                                filled: true,
                                                fillColor: Colors.white,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: DM.p10),
                                                border: InputBorder.none,
                                                hintText: "Write Your Age",
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
                                    children: [
                                      SizedBox(
                                        width: DM.p100,
                                        child: Text(
                                          "Gender",
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
                                        hint: Text(
                                          "$gender",
                                          style:
                                              TextStyle(color: blackFontColor),
                                        ),
                                        items: <String>[
                                          'Male',
                                          'Female',
                                        ].map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(
                                              "$value",
                                              style: TextStyle(
                                                  color: blackFontColor),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (newValue) {
                                          setState(() {
                                            gender = newValue;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              
                                Padding(
                                  padding: EdgeInsets.all(DM.p1),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                            controller: addressText,
                                            keyboardType:
                                                TextInputType.multiline,
                                            maxLines: null,
                                            // onTap: (() {
                                            //   showDialog(
                                            //       context: context,
                                            //       builder: (context) {
                                            //         return MyDialogView(
                                            //             myChild: TextDialogueBox(
                                            //                 keyTitle: "Address",
                                            //                 addressText:
                                            //                     addressText));
                                            //       });
                                            // }),
                                            decoration: InputDecoration(
                                                errorStyle:
                                                    TextStyle(fontSize: DM.p9),
                                                // focusedErrorBorder:
                                                //     OutlineInputBorder(
                                                //         borderSide: BorderSide(
                                                //             width: DM.p1,
                                                //             color:
                                                //                 orangeColor)),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            width: DM.p1,
                                                            color:
                                                                orangeColor)),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      width: DM.p1,
                                                      color:
                                                          orangeColor), //<-- SEE HERE
                                                ),
                                                filled: true,
                                                fillColor: fullWhiteColor,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
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
                                  padding: EdgeInsets.all(DM.p1),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                            controller: referredAddressText,
                                            keyboardType:
                                                TextInputType.multiline,
                                            maxLines: null,
                                            // onTap: (() {
                                            //   showDialog(
                                            //       context: context,
                                            //       builder: (context) {
                                            //         return MyDialogView(
                                            //             myChild: TextDialogueBox(
                                            //                 keyTitle:
                                            //                     "Referrer Info",
                                            //                 addressText:
                                            //                     referredAddressText));
                                            //       });
                                            // }),
                                            decoration: InputDecoration(
                                                errorStyle:
                                                    TextStyle(fontSize: DM.p9),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            width: DM.p1,
                                                            color:
                                                                orangeColor)),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      width: DM.p1,
                                                      color:
                                                          orangeColor), //<-- SEE HERE
                                                ),
                                                filled: true,
                                                fillColor: Colors.white,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: DM.p10),
                                                border: InputBorder.none,
                                                hintText: "Name of Doctor",
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
                                  padding: EdgeInsets.symmetric(horizontal: DM.p1 , vertical: DM.p10),
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

                                      Container(child:
                                      imageDiscountFile == null
                                          ? Container(
                                        height: DM.p60,
                                        width: DM.p80,
                                        margin: EdgeInsets.symmetric(
                                            horizontal: DM.p15),
                                        child: MaterialButton(
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
                                                              margin:
                                                              EdgeInsets.all(
                                                                  DM.p16),
                                                              height: DM.p130,
                                                              width: DM.p120,
                                                              child:
                                                              ElevatedButton(
                                                                  style: ElevatedButton.styleFrom(
                                                                      backgroundColor:
                                                                      orangeColor,
                                                                      elevation:
                                                                      0),
                                                                  onPressed:
                                                                      () async {
                                                                    PickedFile?
                                                                    pickedFile =
                                                                    await ImagePicker()
                                                                        .getImage(
                                                                      source:
                                                                      ImageSource.gallery,
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
                                                                      orangeColor,
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
                                            color: orangeColor,
                                            child: Icon(Icons.camera , size: DM.p40, color: whiteColor,)
                                        ),
                                      )
                                          : Column(
                                        children: [
                                          Container(
                                            height: DM.p60,
                                            width: DM.p80,
                                            child: Image.file(
                                              imageDiscountFile as File,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          IconButton(
                                            color: orangeColor,
                                            icon: Icon(
                                              CupertinoIcons.xmark_circle_fill,
                                              size: DM.p30,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                imageDiscountFile = null;
                                              });
                                            },
                                          ),
                                        ],
                                      ),)
                                    ],
                                  ),
                                ),

                                Padding(
                                  padding: EdgeInsets.all(DM.p1),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: DM.p100,
                                        child: Text(
                                          "Contact Number",
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
                                            autofocus: false,
                                            keyboardType: TextInputType.phone,
                                            controller: phone,
                                            validator: validateMobile,
                                            decoration: InputDecoration(
                                                errorStyle:
                                                    TextStyle(fontSize: DM.p9),
                                                // focusedErrorBorder:
                                                //     OutlineInputBorder(
                                                //         borderSide: BorderSide(
                                                //             width: DM.p1,
                                                //             color:
                                                //                 orangeColor)),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            width: DM.p1,
                                                            color:
                                                                orangeColor)),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      width: DM.p1,
                                                      color:
                                                          orangeColor), //<-- SEE HERE
                                                ),
                                                filled: true,
                                                fillColor: Colors.white,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: DM.p10),
                                                border: InputBorder.none,
                                                hintText: "Ex: 01888888888",
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
                              ],
                            )),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: DM.p120,
                              child: MaterialButton(
                                onPressed: () async {
                                  if (await chechkingInternet()) {
                                    createReqController.testData.map((element) {
                                      createRequest_controller
                                              .testItemListWithSelected[
                                          element.id] = true;
                                    }).toList();

                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return MyDialogView(
                                            myChild: TestItemDialogueBox(
                                              keyTitle: "Referred Address",
                                            ),
                                          );
                                        });
                                  }
                                },
                                height: DM.p40,
                                shape: const StadiumBorder(),
                                color: orangeColor,
                                child: Text(
                                  "Add test",
                                  style: TextStyle(
                                      color: fullWhiteColor,
                                      fontSize: DM.p15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // #text_field
                        Obx(
                          () => Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: DM.p10, vertical: DM.p3),
                            height: DM.screenHeight * 0.35,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: whiteColor,
                              borderRadius: BorderRadius.circular(DM.p10),
                            ),
                            child: createReqController.testData.length != 0
                                ? ListView.builder(
                                    itemCount:
                                        createReqController.testData.length,
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
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(
                                                width: DM.p170,
                                                child: Text(
                                                  createReqController
                                                          .testData[index]
                                                          .name +
                                                      " (${createReqController.testData[index].diagnostic_center})",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      fontSize: DM.p15,
                                                      color: Color.fromARGB(
                                                          255, 26, 1, 1)),
                                                ),
                                              ),
                                              Text(
                                                "Price: ${createReqController.testData[index].testprice}",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: DM.p15,
                                                    color: Color.fromARGB(
                                                        255, 26, 1, 1)),
                                              ),
                                              Container(
                                                child: IconButton(
                                                  color: orangeColor,
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
                                                    removeCalulationProcess(
                                                        createReqController
                                                            .testData[index]
                                                            .id);
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
                                            color:
                                                Color.fromARGB(255, 26, 1, 1)),
                                      ),
                                    ),
                                  ),
                          ),
                        ),

                        // #signup_button

                        Obx(
                          () => Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: DM.p20, vertical: DM.p2),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "(Test + Tube + Collection) = (${createReqController.totalTestCost.value}+${createReqController.tubeCost.value}+${createReqController.serviceCost.value}) =  ${createReqController.totalTestCost.value + createReqController.tubeCost.value + createReqController.serviceCost.value} /-",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: DM.p12,
                                      color: Color.fromARGB(255, 26, 1, 1)),
                                ),
                                Text(
                                  "Discount : ${createReqController.totalDiscount.value} /-",
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
                                      "Total Cost: ${createReqController.totalCost.value} /-",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: DM.p15,
                                          color: Color.fromARGB(255, 26, 1, 1)),
                                    ),
                                    MaterialButton(
                                      onPressed: () async {
                                        if (_formKey.currentState?.validate() ==
                                            true) {
                                          if (await chechkingInternet()) {
                                            if (createReqController.testData !=
                                                    null &&
                                                createReqController
                                                        .testData.length >
                                                    0) {
                                              initialTestRequest();
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return MyDialogView(
                                                      myChild: ConfirmationList(
                                                        uploadImage: uploadImage,
                                                          newRequestData:
                                                              newRequestData,
                                                          ),
                                                    );
                                                  });
                                            } else {
                                              Get.snackbar(
                                                  margin: EdgeInsets.symmetric(
                                                      horizontal: DM.p70,
                                                      vertical: DM.p60),
                                                  duration: Duration(
                                                      milliseconds: 2000),
                                                  backgroundColor: redColor,
                                                  colorText: whiteColor,
                                                  "No Test Item",
                                                  "No test selected.");
                                            }
                                          }
                                        }
                                      },
                                      height: DM.p40,
                                      minWidth: DM.p120,
                                      shape: const StadiumBorder(),
                                      color: orangeColor,
                                      child: Text(
                                        // "Submit",
                                        "সাবমিট",
                                        style: TextStyle(
                                            color: fullWhiteColor,
                                            fontSize: DM.p15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        // #buttons(facebook & github)
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
  FormUserInfo(
      {Key? key,
      required this.formKey,
      required this.title,
      required this.value,
      required this.activate,
      required this.controller,
      required this.textInputType,
      required this.validatorField})
      : super(
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(DM.p1),
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
                keyboardType: TextInputType.multiline,
                maxLines: null,
                controller: controller,
                readOnly: activate,
                decoration: InputDecoration(
                    errorStyle: TextStyle(fontSize: DM.p9),
                    disabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(width: DM.p1, color: orangeColor)),
                    focusedErrorBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(width: DM.p1, color: orangeColor)),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(width: DM.p1, color: orangeColor)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: DM.p1, color: orangeColor), //<-- SEE HERE
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(horizontal: DM.p10),
                    border: InputBorder.none,
                    hintText: value,
                    hintStyle: TextStyle(
                      color: Colors.grey,
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

String? validateName(String? value) {
  if (value?.length == 0)
    return 'Please fill this form';
  else
    return null;
}

String? validateAge(String? value) {
  if (value?.length == 0)
    return 'Please fill this form';
  else
    return null;
}

Future<void> getTestItemList() async {
  CreateRequest_controller createRequest_controller =
      Get.put(CreateRequest_controller());
  late DatabaseReference _dbref_testModel;
  _dbref_testModel = FirebaseDatabase.instance.ref("$database_name/testModel/");
  FirebaseDatabase.instance.setPersistenceEnabled(true);
  _dbref_testModel.keepSynced(true);

  createRequest_controller.testItemList.clear();

  createRequest_controller.testItemListWithSelected.clear();
  _dbref_testModel.onValue.listen((event) {
    for (DataSnapshot ds in event.snapshot.children) {
      TestData testData = TestData.fromJson(json.decode(jsonEncode(ds.value)));

      createRequest_controller.testItemList.add(testData);
      createRequest_controller.testItemListWithSelected[testData.id] = false;
      //false -> add button
      //true -> remove button

      print(testData.name);
    }
  });
}

Future<void> getAdminNotification(phone, type, context) async {
  late DatabaseReference DbrefTestModel;
  DbrefTestModel = FirebaseDatabase.instance.ref("$database_name/admin_user/");
  FirebaseDatabase.instance.setPersistenceEnabled(true);
  DbrefTestModel.keepSynced(true);

  DbrefTestModel.onValue.listen((event) async {
    for (DataSnapshot ds in event.snapshot.children) {
      AdminUserModel testData =
          AdminUserModel.fromJson(json.decode(jsonEncode(ds.value)));

      if (testData.phone == phone) {
        if (type == "1" || type == "7" || phone == "$superUser") {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          createPlantFoodNotification();
          showNotification(context);
        }
      }
    }
  });
}
