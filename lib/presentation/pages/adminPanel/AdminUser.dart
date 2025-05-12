import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthcare_homelab/constants/api.dart';
import 'package:healthcare_homelab/constants/colors.dart';
import 'package:healthcare_homelab/presentation/pages/adminPanel/AdminUserData.dart';

import '../../../constants/app_info.dart';
import '../../../db/models/AdminUserModel.dart';
import '../../../responsives/dimensions.dart';

class AdminUserController extends GetxController {
  var adminUsers = <AdminUserModel>[].obs;
  var filteredUsers = <AdminUserModel>[].obs;
  var isLoading = false.obs;
  var isClear = false.obs;
  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchAdminUsers();
  }

  void fetchAdminUsers() async {
    try {
      isLoading.value = true;
      final dbRef = FirebaseDatabase.instance.ref("$adminUserApi/");
      FirebaseDatabase.instance.setPersistenceEnabled(true);
      dbRef.keepSynced(true);

      dbRef.onValue.listen((event) {
        adminUsers.clear();
        filteredUsers.clear();
        for (DataSnapshot ds in event.snapshot.children) {
          final data = AdminUserModel.fromJson(json.decode(jsonEncode(ds.value)));
          adminUsers.add(data);
          filteredUsers.add(data);
        }
        isLoading.value = false;
      });
    } catch (e) {
      Get.snackbar("Error", "Failed to load admin users: $e",
          backgroundColor: redColor, colorText: fullWhiteColor);
      isLoading.value = false;
    }
  }

  void filterUsers(String value) {
    if (value.isNotEmpty) {
      isClear.value = true;
      final lowerValue = value.toLowerCase();
      filteredUsers.assignAll(
        adminUsers.where((user) =>
        (user.phone != null && user.phone!.toLowerCase().contains(lowerValue)) ||
            (user.surname != null && user.surname!.toLowerCase().contains(lowerValue))
        ).toList(),
      );
    } else {
      isClear.value = false;
      filteredUsers.assignAll(adminUsers);
    }
  }



  Future<void> removeUser(String phoneNumber) async {
    try {
      final dbRef = FirebaseDatabase.instance.ref("$adminUserApi/$phoneNumber");
      await dbRef.remove();
      Get.snackbar("Success", "User deleted successfully",
          backgroundColor: appTheme, colorText: fullWhiteColor);
    } catch (e) {
      Get.snackbar("Error", "Failed to delete user: $e",
          backgroundColor: redColor, colorText: fullWhiteColor);
    }
  }
}

class AdminUser extends StatelessWidget {
  AdminUser({super.key});

  final controller = Get.put(AdminUserController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        backgroundColor: appTheme,
        actions: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: DM.p50, vertical: DM.p10),
            width: DM.screenWidth,
            child: Text(
              "Admin User",
              textAlign: TextAlign.left,
              style: TextStyle(color: secondaryColor, fontSize: DM.p30),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(DM.p8),
          child: Column(
            children: [
              Container(
                color: secondaryColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(vertical: DM.p10),
                      child: Text(
                        "Admin User List",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: DM.p25,
                          color: Color.fromARGB(255, 26, 1, 1),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(DM.p10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Obx(
                                () => Flexible(
                              child: Container(
                                height: DM.p45,
                                child: TextFormField(
                                  keyboardType: TextInputType.text,
                                  controller: controller.searchController,
                                  onChanged: controller.filterUsers,
                                  decoration: InputDecoration(
                                    suffixIcon: controller.isClear.value
                                        ? IconButton(
                                      icon: Icon(Icons.clear,
                                          color: appTheme),
                                      onPressed: () {
                                        controller.searchController
                                            .clear();
                                        controller.filterUsers("");
                                      },
                                    )
                                        : Icon(Icons.search, color: appTheme),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.circular(DM.p40),
                                      borderSide:
                                      BorderSide(width: DM.p1, color: appTheme),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.circular(DM.p40),
                                      borderSide:
                                      BorderSide(width: DM.p1, color: appTheme),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: InputBorder.none,
                                    hintText: "Search",
                                    hintStyle: TextStyle(
                                      color: Colors.grey,
                                      fontSize: DM.p14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Obx(
                          () => controller.isLoading.value
                          ? _buildLoadingDialog()
                          : controller.filteredUsers.isNotEmpty
                          ? Container(
                        height: DM.screenHeight * 0.65,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            Card(
                              child: Container(
                                height: DM.screenHeight * 0.65,
                                width: DM.screenWidth * 1.2,
                                child: ListView.builder(
                                  itemCount:
                                  controller.filteredUsers.length,
                                  itemBuilder: (context, index) {
                                    final user =
                                    controller.filteredUsers[index];
                                    return _buildUserItem(
                                        context, user);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                          : Container(
                        height: DM.screenHeight * 0.60,
                        margin: EdgeInsets.symmetric(vertical: DM.p16),
                        color: whiteColor,
                        child: Center(
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
                    Container(
                      margin: EdgeInsets.symmetric(vertical: DM.p10),
                      child: MaterialButton(
                        onPressed: () {
                          Get.to(() => AdminUserData())!
                              .then((value) => controller.fetchAdminUsers());
                        },
                        height: DM.p45,
                        minWidth: DM.p130,
                        shape: const StadiumBorder(),
                        color: appTheme,
                        child: Text(
                          "Create User",
                          style: TextStyle(
                            color: fullWhiteColor,
                            fontSize: DM.p15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingDialog() {
    return Dialog(
      child: Container(
        height: DM.p120,
        padding: EdgeInsets.all(DM.p16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: appTheme),
            SizedBox(width: DM.p10),
            Text(
              "Loading, please wait...",
              style: TextStyle(color: appTheme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserItem(BuildContext context, AdminUserModel user) {
    return Container(
      color: whiteColor,
      padding: EdgeInsets.symmetric(horizontal: DM.p10, vertical: DM.p10),
      margin: EdgeInsets.symmetric(vertical: DM.p5),
      child: Row(
        children: [
          SizedBox(
            width: DM.p150,
            child: Text(
              " ${user.surname}_${user.phone.substring(8)}_${user.short_address}",
              overflow: TextOverflow.visible,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: DM.p12,
                color: Color.fromARGB(255, 26, 1, 1),
              ),
            ),
          ),
          SizedBox(
            width: DM.p60,
            child: Text(
              "Active: ${user.active}",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: DM.p12,
                color: Color.fromARGB(255, 26, 1, 1),
              ),
            ),
          ),
          SizedBox(
            width: DM.p50,
            child: Text(
              "Type: ${user.type}",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: DM.p12,
                color: Color.fromARGB(255, 26, 1, 1),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: DM.p10),
            child: Row(
              children: [
                SizedBox(
                  height: DM.p45,
                  width: DM.p70,
                  child: MaterialButton(
                    onPressed: () {
                      Get.to(() => AdminUserData(adminUser: user))!
                          .then((value) => controller.fetchAdminUsers());
                    },
                    shape: const StadiumBorder(),
                    color: appTheme,
                    child: Text(
                      "Update",
                      style: TextStyle(
                        color: fullWhiteColor,
                        fontSize: DM.p10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  color: appTheme,
                  icon: Icon(
                    CupertinoIcons.delete,
                    size: DM.p25,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => Scaffold(
                        backgroundColor: Colors.transparent,
                        body: Center(
                          child: Container(
                            margin: EdgeInsets.all(DM.p10),
                            height: DM.p250,
                            color: secondaryColor,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(16),
                                  margin: EdgeInsets.all(16),
                                  child: Text(
                                    "Do you want to delete test item \"${user.phone}\"?",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: DM.p20,
                                      color: Color.fromARGB(255, 26, 1, 1),
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.symmetric(
                                          horizontal: DM.p20, vertical: DM.p10),
                                      child: MaterialButton(
                                        onPressed: () => Get.back(),
                                        height: DM.p40,
                                        minWidth: DM.p120,
                                        shape: const StadiumBorder(),
                                        color: appTheme,
                                        child: Text(
                                          "Cancel",
                                          style: TextStyle(
                                            color: fullWhiteColor,
                                            fontSize: DM.p15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.symmetric(
                                          horizontal: DM.p20, vertical: DM.p10),
                                      child: MaterialButton(
                                        onPressed: () async {
                                          await controller.removeUser(user.phone);
                                          Get.back();
                                        },
                                        height: DM.p40,
                                        minWidth: DM.p120,
                                        shape: const StadiumBorder(),
                                        color: appTheme,
                                        child: Text(
                                          "Delete",
                                          style: TextStyle(
                                            color: fullWhiteColor,
                                            fontSize: DM.p15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}