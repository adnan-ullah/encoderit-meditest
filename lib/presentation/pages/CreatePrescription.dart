import 'dart:io';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:healthcare_homelab/constants/api.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/image_picker_compat.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/colors.dart';
import '../../db/models/TestDataRequest.dart';
import '../../responsives/dimensions.dart';
import '../../state_programming/CreateRequestController.dart';
import 'LoginScreen.dart';

class CreatePrescription extends StatefulWidget {
  const CreatePrescription({Key? key}) : super(key: key);

  @override
  _CreatePrescriptionState createState() => _CreatePrescriptionState();
}

class _CreatePrescriptionState extends State<CreatePrescription> {
  CreateRequestController createReqController =
      Get.put(CreateRequestController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var phone = TextEditingController();
  var referrer = TextEditingController();
  File? imageFile1, imageFile2, imageDiscountFile;

  var status;

  Future<void> getPhoneNumber() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    phone.text = pref.getString("phoneNumber").toString();
    referrer.text = pref.getString("referrer_code").toString();
  }

  UploadTask? uploadTask1, uploadTask2, uploadTask3;

  Future<void> addImages(urlDownload1, urlDownload2, urlDownload3) async {
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    TestDataRequest newRequestData = TestDataRequest(
        id: ((Random().nextInt(900000) + 100000).toString()),
        name: "",
        gender: "",
        mobile: phone.text,
        age: "",
        testlist: [],
        totalprice: 0,
        servicecharge: 0,
        address: "",
        referrer: referrer.text,
        lastupdate: currentTime,
        dateofcreated: currentTime,
        softdelete: 0,
        latitude: position.latitude,
        longitude: position.longitude,
        teststatus: 1,
        invoice_call: phone.text.substring(7) +
            "-" +
            (Random().nextInt(900000) + 100000).toString(),
        type: 2,
        image_one: urlDownload1,
        image_two: urlDownload2,
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
        // Use new commissions map instead of legacy fields
        commissionsByType: {},
        advanced: 0,
        comments: "",
        delivery_date: null,
        due_amount: 0,
        test_item_cost: 0,
        test_item_discount: 0,
        total_admin_discount: 0,
        total_agent_discount: 0,
        total_discount: 0,
        is_paid: false,
        total_unpayable_imagine: 0,
        total_unpayable_pathology: 0,
        payment_date: 0,
        imageDiscountFile: urlDownload3)!;

    late DatabaseReference _dbref_testReqModel;
    _dbref_testReqModel = FirebaseDatabase.instance.ref("$testRequestApi/");

    if (newRequestData != null) {
      await _dbref_testReqModel
          .child(newRequestData.mobile.toString())
          .child(newRequestData.id)
          .set(newRequestData.toJson());

      //  _onLoading(true);
      Get.snackbar(
          margin: EdgeInsets.symmetric(horizontal: DM.p70, vertical: DM.p60),
          duration: Duration(milliseconds: 2000),
          backgroundColor: limeBGColor,
          colorText: whiteColor,
          "Added",
          "Data added , successfully!");
    } else {
      //_onLoading(true);
      Get.snackbar(
          margin: EdgeInsets.symmetric(horizontal: DM.p70, vertical: DM.p60),
          duration: Duration(milliseconds: 2000),
          backgroundColor: redColor,
          colorText: whiteColor,
          "Request already exist",
          "Failed to added!");
    }
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
    final phonePath = phone.text;

    final path1 = "$storageFiles/$phonePath/${imageFile1?.path.split('/').last}";
    final path2 = "$storageFiles/$phonePath/${imageFile2?.path.split('/').last}";
    final path3 = "$storageFiles/$phonePath/${imageDiscountFile?.path.split('/').last}";

    final ref1 = imageFile1 != null ? FirebaseStorage.instance.ref().child(path1) : null;
    final ref2 = imageFile2 != null ? FirebaseStorage.instance.ref().child(path2) : null;
    final ref3 = imageDiscountFile != null ? FirebaseStorage.instance.ref().child(path3) : null;

    Future<String?> uploadFile(File? file, Reference? ref) async {
      if (file == null || ref == null) return null;
      final task = ref.putFile(file);
      final snapshot = await task.whenComplete(() {});
      return await snapshot.ref.getDownloadURL();
    }

    final results = await Future.wait([
      uploadFile(imageFile1, ref1),
      uploadFile(imageFile2, ref2),
      uploadFile(imageDiscountFile, ref3),
    ]);

    final urlDownload1 = results[0];
    final urlDownload2 = results[1];
    final urlDownload3 = results[2];

    addImages(urlDownload1, urlDownload2, urlDownload3);
    Get.back();
    _onLoading(false);
  }

  Future<void> getLocation_Camera() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    } else {
      if (permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      } else {
        bool servicestatus = await Geolocator.isLocationServiceEnabled();

        if (!servicestatus) {
          servicestatus = await Geolocator.openLocationSettings();
        } else {
          if (!servicestatus) {
            servicestatus = await Geolocator.openLocationSettings();
          } else {
            status = await Permission.camera.status;
            print(status);

            if (await Permission.camera.request().isGranted) {
              status = await Permission.camera.status;
            } else {
              status = Permission.camera.request().isGranted;
            }
          }
        }
      }
    }
  }

  @override
  void initState() {
    getLocation_Camera();
    getPhoneNumber();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    getLocation_Camera();
    return Scaffold(
      appBar: AppBar(backgroundColor: appTheme, actions: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: DM.p50, vertical: DM.p10),
          width: DM.screenWidth,
          child: Text(
            "Prescription Form",
            textAlign: TextAlign.left,
            style: TextStyle(
                color: secondaryColor,
                fontWeight: FontWeight.bold,
                fontSize: DM.p25),
          ),
        ),
      ]),
      backgroundColor: secondaryColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Container(
             // height: DM.screenHeight,
              width: DM.screenWidth,
              child: Column(
              children: [
                Container(
                    width: DM.screenWidth,
                    child: Column(
                      children: [
                        Center(
                          child: Container(
                            margin: EdgeInsets.all(DM.p20),
                            child: Column(
                              children: [
                                Text(
                                  "Enter your phone number & prescription photo",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: DM.p30,
                                      color: appTheme),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(DM.p12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: DM.p100,
                                    child: Text(
                                      "Contact\nNumber",
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
                                        keyboardType: TextInputType.phone,
                                        controller: phone,
                                        validator: validateMobile,
                                        onChanged: ((value) {
                                          _formKey.currentState?.validate();
                                        }),
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
                                            fillColor: Colors.white,
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
                            Padding(
                              padding: EdgeInsets.all(DM.p12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: DM.p100,
                                    child: Text(
                                      "Agent\n(যদি থাকে)",
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
                                        keyboardType: TextInputType.phone,
                                        controller: referrer,
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
                                            fillColor: Colors.white,
                                            border: InputBorder.none,
                                            hintText: "Agent",
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
                              padding: EdgeInsets.symmetric(horizontal: DM.p12),
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
                                  Container(
                                    child: imageDiscountFile == null
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
                                                                  margin: EdgeInsets
                                                                      .all(DM
                                                                          .p16),
                                                                  height:
                                                                      DM.p130,
                                                                  width:
                                                                      DM.p120,
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
                                                                                await ImagePicker().getImage(
                                                                              source: ImageSource.gallery,
                                                                              maxWidth: 1200,
                                                                              maxHeight: 1600,
                                                                            );
                                                                            setState(() {
                                                                              if (pickedFile != null)
                                                                                imageDiscountFile = File(pickedFile!.path);
                                                                            });

                                                                            Navigator.pop(context);
                                                                          },
                                                                          child:
                                                                              Text(
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
                                                                          BorderRadius.circular(
                                                                              25)),
                                                                  height:
                                                                      DM.p130,
                                                                  width:
                                                                      DM.p120,
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
                                                                                await ImagePicker().getImage(
                                                                              source: ImageSource.camera,
                                                                              maxWidth: 1200,
                                                                              maxHeight: 1600,
                                                                            );
                                                                            setState(() {
                                                                              if (pickedFile != null)
                                                                                imageDiscountFile = File(pickedFile!.path);
                                                                            });
                                                                            Navigator.pop(context);
                                                                          },
                                                                          child: Text(
                                                                              "Camera",
                                                                              style: TextStyle(fontSize: DM.p18))),
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
                                                color: appTheme,
                                                icon: Icon(
                                                  CupertinoIcons
                                                      .xmark_circle_fill,
                                                  size: DM.p30,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    imageDiscountFile = null;
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.only(top: DM.p5),
                          child: Padding(
                            padding: EdgeInsets.all(DM.p10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                imageFile1 == null
                                    ? Container(
                                        height: DM.p180,
                                        width: DM.p150,
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
                                                                          imageFile1 =
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
                                                                          imageFile1 =
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
                                          child: Text(
                                            "1\n প্রেসক্রিপশনের ছবি সংযুক্ত করুন ",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: fullWhiteColor,
                                                fontSize: DM.p15,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      )
                                    : Column(
                                        children: [
                                          Container(
                                            height: DM.p180,
                                            width: DM.p150,
                                            child: Image.file(
                                              imageFile1 as File,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          IconButton(
                                            color: appTheme,
                                            icon: Icon(
                                              CupertinoIcons.xmark_circle_fill,
                                              size: DM.p30,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                imageFile1 = null;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                Container(
                                  height: DM.p40,
                                ),
                                imageFile2 == null
                                    ? Container(
                                        height: DM.p180,
                                        width: DM.p150,
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
                                                                          imageFile2 =
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
                                                                          imageFile2 =
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
                                          child: Text(
                                            "2\n প্রেসক্রিপশনের ছবি সংযুক্ত করুন ",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: fullWhiteColor,
                                                fontSize: DM.p15,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      )
                                    : Column(
                                        children: [
                                          Container(
                                            height: DM.p180,
                                            width: DM.p150,
                                            child: Image.file(
                                              imageFile2!,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          IconButton(
                                            color: appTheme,
                                            icon: Icon(
                                              CupertinoIcons.xmark_circle_fill,
                                              size: DM.p30,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                imageFile2 = null;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: DM.p20, vertical: DM.p32),
                          child: Center(
                            child: SizedBox(
                              width: DM.p150,
                              child: MaterialButton(
                                onPressed: () async {
                                  if (await chechkingInternet()) {
                                    if (imageFile1 != null ||
                                        imageFile2 != null) {
                                      print("Adnan");
                                      print(imageFile2);
                                      uploadImage();
                                    } else {
                                      Get.snackbar(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: DM.p70,
                                              vertical: DM.p60),
                                          duration:
                                              Duration(milliseconds: 3000),
                                          backgroundColor: redColor,
                                          colorText: whiteColor,
                                          "Need prescriptions",
                                          "Failed to submit , add image!");
                                    }
                                  }
                                },
                                height: DM.p50,
                                shape: const StadiumBorder(),
                                color: appTheme,
                                child: Text(
                                  // "Submit",
                                  "সাবমিট",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: fullWhiteColor,
                                      fontSize: DM.p15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: MediaQuery.of(context).padding.bottom + DM.p8)
                        // #buttons(facebook & github)
                      ],
                    ),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }

  Future<void> savePhone(phoneNumber) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('phoneNumber', phoneNumber);
  }
}

String? validateMobile(String? value) {
  if (value?.length != 11 && value?.length != 12)
    return 'Mobile Number must be of 11 to 12 digits';
  else
    return null;
}
