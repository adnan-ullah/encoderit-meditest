import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthcare_homelab/constants/colors.dart';
import 'package:healthcare_homelab/presentation/pages/adminPanel/AdminUser.dart';
import 'package:healthcare_homelab/presentation/pages/adminPanel/CostDataCreate.dart';
import 'package:healthcare_homelab/presentation/pages/adminPanel/StatusRequestList.dart';
import 'package:healthcare_homelab/presentation/pages/adminPanel/TestItemList.dart';
import 'package:healthcare_homelab/presentation/widgets/projectsWidget/AdminSuperReport.dart';
import 'package:healthcare_homelab/presentation/widgets/projectsWidget/AgentReportList.dart';
import 'package:healthcare_homelab/presentation/widgets/projectsWidget/CollectionReportList.dart';
import 'package:healthcare_homelab/state_programming/Create_Request_Controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/app_info.dart';
import '../../../responsives/dimensions.dart';

class AdminHome extends StatefulWidget {
  final String check_type;
  final String check_number;
  const AdminHome({super.key, required this.check_type, required this.check_number});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final CreateRequest_controller cr_controller = Get.put(CreateRequest_controller());
  bool isLoading = false;
  String? type;
  String? phone;

  @override
  void initState() {
    super.initState();
    getTypeData();
  }

  Future<void> getTypeData() async {
    final ref = await SharedPreferences.getInstance();
    setState(() {
      type = ref.getString("type");
      phone = ref.getString("phoneNumber");
    });
  }

  void _showLoadingDialog(bool isClosed) {
    if (isClosed && !isLoading) {
      setState(() => isLoading = true);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Dialog(
          child: Container(
            height: DM.p120,
            padding: EdgeInsets.all(DM.p16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: orangeColor),
                SizedBox(width: DM.p10),
                Text("Loading, please wait...", style: TextStyle(color: orangeColor)),
              ],
            ),
          ),
        ),
      );
    } else if (!isClosed && isLoading) {
      setState(() => isLoading = false);
      Navigator.pop(context);
    }
  }

  Widget _buildButton(String title, VoidCallback onPressed, {double width = 0.4}) {
    return Container(
      height: DM.p180,
      width: DM.screenWidth * width,
      margin: EdgeInsets.symmetric(vertical: DM.p25, horizontal: DM.p10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: DM.p30, vertical: DM.p20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DM.p10)),
          backgroundColor: orangeColor,
        ),
        onPressed: onPressed,
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(color: fullWhiteColor, fontSize: DM.p15, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSuperUser = widget.check_number == superUser;
    final isAdmin = isSuperUser || widget.check_type == "7";
    final isAgent = widget.check_type == "1" || widget.check_type == "3" || widget.check_type == "4";
    final isReportUser = widget.check_type == "2";

    return Scaffold(
      backgroundColor: creamColor,
      appBar: AppBar(
        backgroundColor: orangeColor,
        title: Text(
          isAdmin || phone == superUser ? "Admin" : "Agent",
          style: TextStyle(color: creamColor, fontSize: DM.p30),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(DM.p8),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (isAdmin || isAgent)
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isAdmin)
                          _buildButton("Test Item", () async {
                            final ref = await SharedPreferences.getInstance();
                            if (ref.getString("phoneNumber") == superUser || ref.getString("type") == "7") {
                              Get.to(() => TestItemList());
                            }
                          }),
                        _buildButton("Test Request", () {
                          if (widget.check_type == "3") {
                            Get.to(() => StatusRequestList(
                              statusIndices: [1, 2, 8, 3, 4, 5, 6, 7],
                              isButtonList: [false, false, false, true, true, true, false, false],
                            ));
                          } else if (widget.check_type == "4") {
                            Get.to(() => StatusRequestList(
                              statusIndices: [2, 8, 3],
                              isButtonList: [false, false, false],
                            ));
                          } else {
                            Get.to(() => StatusRequestList(
                              statusIndices: [1, 2, 8, 3, 4, 5, 6, 7],
                              isButtonList: [false, false, false, true, true, true, false, false],
                            ));
                          }
                        }),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isSuperUser)
                          _buildButton("Admin User", () async {
                            final ref = await SharedPreferences.getInstance();
                            if (ref.getString("phoneNumber") == superUser) {
                              Get.to(() => AdminUser());
                            }
                          }),
                        if (isSuperUser || widget.check_type == "4")
                          _buildButton("Report", () async {
                            final ref = await SharedPreferences.getInstance();
                            if (ref.getString("phoneNumber") == superUser) {
                              Get.to(() => AdminSuperReport());
                            } else if (widget.check_type == "4") {
                              Get.to(() => CollectionReportList());
                            }
                          }),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isAdmin)
                          _buildButton("Agent Report", () async {
                            final ref = await SharedPreferences.getInstance();
                            if (ref.getString("phoneNumber") == superUser || ref.getString("type") == "7") {
                              Get.to(() => AgentReportList());
                            }
                          }),
                        if (isSuperUser)
                          _buildButton("Cost", () async {
                            final ref = await SharedPreferences.getInstance();
                            if (ref.getString("phoneNumber") == superUser || ref.getString("type") == "7") {
                              Get.to(() => CostDataCreate());
                            }
                          }),
                      ],
                    ),
                  ],
                )
              else if (isReportUser)
                _buildButton("Daily Report", () => Get.to(() => AgentReportList())),
            ],
          ),
        ),
      ),
    );
  }
}