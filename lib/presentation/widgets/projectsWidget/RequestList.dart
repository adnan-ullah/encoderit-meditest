import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthcare_homelab/constants/colors.dart';
import 'package:healthcare_homelab/db/databse_model.dart';
import 'package:healthcare_homelab/presentation/pages/Create_Request.dart';
import 'package:healthcare_homelab/state_programming/Create_Request_Controller.dart';

import '../../../responsives/dimensions.dart';

class RequestList extends StatefulWidget {
  RequestList({super.key});

  @override
  State<RequestList> createState() => _RequestListState();
}

class _RequestListState extends State<RequestList> {
  late DatabaseReference _dbref_testRequest;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _dbref_testRequest = FirebaseDatabase.instance.ref("meditest/testRequest");
  }

  Future<void> deleteFromStore(id) async {
    await _dbref_testRequest.child(id.toString()).remove();
  }

  CreateRequest_controller createRequest_controller =
      Get.put(CreateRequest_controller());

  @override
  Widget build(BuildContext context) {
    Future<void> addTestData() async {
      DatabaseReference _dbref_testModel;
      _dbref_testModel = FirebaseDatabase.instance.ref("meditest/testModel/");

      _dbref_testModel.onValue.listen((event) {
        final newTestItem = event.snapshot
            .child(createRequest_controller.testKey.value.toString())
            .value;

        TestData testData =
            TestData.fromJson(json.decode(jsonEncode(newTestItem)));

        createRequest_controller.testData.add(testData);
        //createRequest_controller.getTotal(testData);
      });
    }

    return Padding(
      padding: EdgeInsets.all(DM.p8),
      child: Stack(
        children: [
          Container(
              color: creamColor,
              height: DM.screenHeight * 0.8,
              width: DM.screenWidth * 0.9,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Request list",
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 25,
                        color: Color.fromARGB(255, 26, 1, 1)),
                  ),
                  Padding(
                      padding: EdgeInsets.all(DM.p8),
                      child: Container(
                        child: Container(
                          height: DM.screenHeight * 0.60,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Invoice Call",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: DM.p14,
                                        color: Color.fromARGB(255, 26, 1, 1)),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(right: DM.p50),
                                    child: Text(
                                      "Status",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: DM.p14,
                                          color: Color.fromARGB(255, 26, 1, 1)),
                                    ),
                                  ),
                                  Text(
                                    "Date",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: DM.p14,
                                        color: Color.fromARGB(255, 26, 1, 1)),
                                  )
                                ],
                              ),
                              Divider(
                                thickness: DM.p2,
                                color: Colors.black,
                              ),
                              SizedBox(
                                height: DM.screenHeight * 0.5,
                                child: FirebaseAnimatedList(
                                  query: _dbref_testRequest,
                                  itemBuilder:
                                      (context, snapshot, animation, index) {
                                    return Container(
                                      color: Color.fromARGB(255, 255, 237, 237),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: DM.p5, vertical: DM.p10),
                                      margin: EdgeInsets.symmetric(
                                          vertical: DM.p10),
                                      height: DM.p50,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            child: Text(
                                              snapshot
                                                  .child("invoice_call")
                                                  .value
                                                  .toString(),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: DM.p12,
                                                  color: Color.fromARGB(
                                                      255, 26, 1, 1)),
                                            ),
                                          ),
                                          Text(
                                            snapshot
                                                .child("status")
                                                .value
                                                .toString(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontSize: DM.p12,
                                                color: Color.fromARGB(
                                                    255, 26, 1, 1)),
                                          ),
                                          Text(
                                            snapshot
                                                .child("dateofcreated")
                                                .value
                                                .toString(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontSize: DM.p12,
                                                color: Color.fromARGB(
                                                    255, 26, 1, 1)),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                ],
              )),
        ],
      ),
    );
  }
}


//radious
//backgrounddd
//testmodellist design ,lime bg
//submit dialogue , serveice cost , tootal cost, test list
//splash 
//testlist duplicate 
//price-discount  + testkitprice - discount ()

//phone-> id-> populate
//submit button fix
// add multiple then submit (testlist)