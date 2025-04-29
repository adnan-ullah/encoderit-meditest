import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthcare_homelab/presentation/pages/Login_info.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../constants/app_info.dart';
import '../../../constants/colors.dart';
import '../../../db/models/CostModel.dart';
import '../../../responsives/dimensions.dart';
import '../../../state_programming/CostController.dart';
import 'AdminUserData.dart';

class CostDataCreate extends StatefulWidget {
  const CostDataCreate({super.key});

  @override
  _CostDataCreateState createState() => _CostDataCreateState();
}

class _CostDataCreateState extends State<CostDataCreate> {
  final _formKey = GlobalKey<FormState>();
  final costController = Get.put(CostController());
  final voucherNo = TextEditingController();
  final totalAmount = TextEditingController();
  final remarks = TextEditingController();
  String? category;
  DateTime? postingDate = DateTime.now();
  DateTime? voucherDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    costController.fetchCategories();
  }

  Future<void> insertNewCostItem() async {
    final dbRef = FirebaseDatabase.instance.ref(database_name);
    final newCostItem = CostModel(
      id: const Uuid().v4(),
      postingDate: postingDate!.toIso8601String(),
      category: category!,
      voucherNo: voucherNo.text,
      voucherDate: voucherDate!.toIso8601String(),
      totalAmount: totalAmount.text,
      remarks: remarks.text,
    );
    await dbRef
        .child("costModel")
        .child(newCostItem.id)
        .set(newCostItem.toJson());
  }

  Future<void> selectDate(BuildContext context, bool isPostingDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isPostingDate ? postingDate! : voucherDate!,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null)
      setState(
          () => isPostingDate ? postingDate = picked : voucherDate = picked);
  }

  void showAddCategoryDialog() {
    final dialogFormKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final typeController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add New Category"),
        content: SingleChildScrollView(
          child: Form(
            key: dialogFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FormUserInfo(
                  formKey: dialogFormKey,
                  validatorField: validateString,
                  textInputType: TextInputType.text,
                  controller: nameController,
                  title: "Category Name",
                  value: "Enter category name",
                  activate: false,
                ),
                FormUserInfo(
                  formKey: dialogFormKey,
                  validatorField: validateString,
                  textInputType: TextInputType.text,
                  controller: typeController,
                  title: "Category Type",
                  value: "Enter category type",
                  activate: false,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: appTheme)),
          ),
          TextButton(
            onPressed: () async {
              if (dialogFormKey.currentState!.validate()) {
                await costController.addCategory(
                    nameController.text, typeController.text);
                Navigator.pop(context);
                setState(() => category = nameController.text);
              }
            },
            child: Text("Submit", style: TextStyle(color: appTheme)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: appTheme,
        actions: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: DM.p50, vertical: DM.p10),
            width: DM.screenWidth,
            child: Text(
              "Cost Item Form",
              textAlign: TextAlign.left,
              style: TextStyle(color: secondaryColor, fontSize: DM.p30),
            ),
          ),
        ],
      ),
      backgroundColor: secondaryColor,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: SizedBox(
            width: DM.screenWidth,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(DM.p15),
                  margin: EdgeInsets.symmetric(
                      horizontal: DM.p15, vertical: DM.p30),
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(DM.p10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: DM.p20,
                        spreadRadius: DM.p1,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      FormUserInfo(
                        formKey: _formKey,
                        validatorField: validateString,
                        textInputType: TextInputType.text,
                        controller: voucherNo,
                        title: "Voucher No",
                        value: "Enter voucher number",
                        activate: false,
                      ),
                      FormUserInfo(
                        formKey: _formKey,
                        validatorField: validateNumber,
                        textInputType: TextInputType.number,
                        controller: totalAmount,
                        title: "Total Amount",
                        value: "Enter amount",
                        activate: false,
                      ),
                      FormUserInfo(
                        formKey: _formKey,
                        validatorField: validateString,
                        textInputType: TextInputType.text,
                        controller: remarks,
                        title: "Remarks",
                        value: "Enter remarks",
                        activate: false,
                      ),
                      Padding(
                        padding: EdgeInsets.all(DM.p1),
                        child: Row(
                          children: [
                            SizedBox(
                              width: DM.p100,
                              child: Text(
                                "Category",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: DM.p14,
                                  color: const Color.fromARGB(255, 26, 1, 1),
                                ),
                              ),
                            ),
                            SizedBox(width: DM.p5),
                            const Text(":"),
                            SizedBox(width: DM.p10),
                            Expanded(
                              child: Obx(() => DropdownButton<String>(
                                    value: category,
                                    hint: Text("Select Category",
                                        style:
                                            TextStyle(color: blackFontColor)),
                                    items: costController.categoryName
                                        .map((value) => DropdownMenuItem(
                                              value: value,
                                              child: Text(value,
                                                  style: TextStyle(
                                                      color: blackFontColor)),
                                            ))
                                        .toList(),
                                    onChanged: (newValue) =>
                                        setState(() => category = newValue!),
                                  )),
                            ),
                            IconButton(
                              icon: Icon(Icons.add, color: appTheme),
                              onPressed: showAddCategoryDialog,
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
                                "Posting Date",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: DM.p14,
                                  color: const Color.fromARGB(255, 26, 1, 1),
                                ),
                              ),
                            ),
                            SizedBox(width: DM.p5),
                            const Text(":"),
                            SizedBox(width: DM.p10),
                            GestureDetector(
                              onTap: () => selectDate(context, true),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: DM.p10, vertical: DM.p8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: appTheme),
                                  borderRadius: BorderRadius.circular(DM.p5),
                                ),
                                child: Text(
                                  DateFormat('yyyy-MM-dd').format(postingDate!),
                                  style: TextStyle(fontSize: DM.p14),
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
                                "Voucher Date",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: DM.p14,
                                  color: const Color.fromARGB(255, 26, 1, 1),
                                ),
                              ),
                            ),
                            SizedBox(width: DM.p5),
                            const Text(":"),
                            SizedBox(width: DM.p10),
                            GestureDetector(
                              onTap: () => selectDate(context, false),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: DM.p10, vertical: DM.p8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: appTheme),
                                  borderRadius: BorderRadius.circular(DM.p5),
                                ),
                                child: Text(
                                  DateFormat('yyyy-MM-dd').format(voucherDate!),
                                  style: TextStyle(fontSize: DM.p14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: DM.p20, vertical: DM.p35),
                  child: MaterialButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate() &&
                          category != null) {
                        if (await chechkingInternet()) {
                          await insertNewCostItem();
                          Get.back();
                        }
                      } else {
                        Get.snackbar(
                          duration: const Duration(milliseconds: 2000),
                          icon: const Icon(Icons.error),
                          margin: EdgeInsets.symmetric(
                              horizontal: DM.p70, vertical: DM.p60),
                          backgroundColor: const Color.fromARGB(255, 202, 0, 0),
                          colorText: whiteColor,
                          "Error!",
                          "Please fill all fields correctly!",
                        );
                      }
                    },
                    height: DM.p40,
                    minWidth: DM.p120,
                    shape: const StadiumBorder(),
                    color: appTheme,
                    child: Text(
                      "Submit",
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
        ),
      ),
    );
  }
}

String? validateMobile(String? value) =>
    value?.length != 11 ? 'Mobile Number must be of 11 digits' : null;

String? validateString(String? value) =>
    value?.isEmpty ?? true ? 'Please fill this form' : null;

String? validateNumber(String? value) =>
    value?.isEmpty ?? true || double.tryParse(value!) == null
        ? 'Please fill numbers only'
        : null;
