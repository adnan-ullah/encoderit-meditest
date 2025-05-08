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
import 'package:healthcare_homelab/state_programming/CreateRequestController.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/app_info.dart';
import '../../../responsives/dimensions.dart';
import '../../widgets/projectsWidget/ShareHolderReport.dart';

class AdminHome extends StatefulWidget {
  final String check_type;
  final String check_number;
  const AdminHome({super.key, required this.check_type, required this.check_number});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final CreateRequestController cr_controller = Get.put(CreateRequestController());
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
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DM.p12)),
          child: Container(
            height: DM.p100,
            padding: EdgeInsets.all(DM.p16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: appTheme),
                SizedBox(width: DM.p16),
                Text(
                  "Loading...",
                  style: TextStyle(
                    color: appTheme,
                    fontSize: DM.p16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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

  Widget _buildButton({
    required String title,
    required VoidCallback onPressed,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        margin: EdgeInsets.all(DM.p10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(DM.p12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: DM.p8,
              spreadRadius: DM.p1,
              offset: Offset(0, DM.p2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: DM.p36,
              color: appTheme,
            ),
            SizedBox(height: DM.p12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: blackFontColor,
                fontSize: DM.p16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
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
    final isShareHolder = widget.check_type == "8";

    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA), // Light health-themed background
      appBar: AppBar(
        backgroundColor: appTheme,
        elevation: 2,
        title: Text(
          isAdmin || phone == superUser ? "Admin Dashboard" : "Agent Dashboard",
          style: TextStyle(
            color: fullWhiteColor,
            fontSize: DM.p24,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(DM.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisSpacing: DM.p16,
                mainAxisSpacing: DM.p16,
                childAspectRatio: 1.0,
                children: [
                  if (isAdmin)
                    _buildButton(
                      title: "Test Item",
                      icon: Icons.science,
                      onPressed: () async {
                        final ref = await SharedPreferences.getInstance();
                        if (ref.getString("phoneNumber") == superUser || ref.getString("type") == "7") {
                          Get.to(() => TestItemList());
                        }
                      },
                    ),
                  if (isAdmin || isAgent)
                    _buildButton(
                      title: "Test Request",
                      icon: Icons.assignment,
                      onPressed: () {
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
                      },
                    ),
                  if (isSuperUser)
                    _buildButton(
                      title: "Admin User",
                      icon: Icons.admin_panel_settings,
                      onPressed: () async {
                        final ref = await SharedPreferences.getInstance();
                        if (ref.getString("phoneNumber") == superUser) {
                          Get.to(() => AdminUser());
                        }
                      },
                    ),
                  if (isSuperUser || widget.check_type == "4")
                    _buildButton(
                      title: "Report",
                      icon: Icons.bar_chart,
                      onPressed: () async {
                        final ref = await SharedPreferences.getInstance();
                        if (ref.getString("phoneNumber") == superUser) {
                          Get.to(() => AdminSuperReport());
                        } else if (widget.check_type == "4") {
                          Get.to(() => CollectionReportList());
                        }
                      },
                    ),
                  if (isShareHolder)
                    _buildButton(
                      title: "Shareholder Report",
                      icon: Icons.people,
                      onPressed: () async {
                        final ref = await SharedPreferences.getInstance();
                        if (ref.getString("phoneNumber") == superUser || ref.getString("type") == "8") {
                          Get.to(() => ShareholderReportList());
                        }
                      },
                    ),
                  if (isAdmin)
                    _buildButton(
                      title: "Agent Report",
                      icon: Icons.people,
                      onPressed: () async {
                        final ref = await SharedPreferences.getInstance();
                        if (ref.getString("phoneNumber") == superUser || ref.getString("type") == "7") {
                          Get.to(() => AgentReportList());
                        }
                      },
                    ),
                  if (isSuperUser)
                    _buildButton(
                      title: "Cost",
                      icon: Icons.monetization_on,
                      onPressed: () async {
                        final ref = await SharedPreferences.getInstance();
                        if (ref.getString("phoneNumber") == superUser || ref.getString("type") == "7") {
                          Get.to(() => CostDataCreate());
                        }
                      },
                    ),
                  if (isReportUser)
                    _buildButton(
                      title: "Daily Report",
                      icon: Icons.today,
                      onPressed: () => Get.to(() => AgentReportList()),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}