import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthcare_homelab/presentation/pages/LoginScreen.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../constants/api.dart';
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
  DateTime postingDate = DateTime.now();
  DateTime? voucherDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    costController.fetchCategories();
  }

  Future<void> insertNewCostItem() async {
    final dbRef = FirebaseDatabase.instance.ref("$costApi/");
    final newCostItem = CostModel(
      id: const Uuid().v4(),
      postingDate: postingDate.toIso8601String(),
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

  Future<void> selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: voucherDate!,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) setState(() => voucherDate = picked);
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
        title: Text(
          "Cost Item Form",
          style: TextStyle(color: secondaryColor, fontSize: DM.p24),
        ),
        centerTitle: true,
      ),
      backgroundColor: secondaryColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: DM.p20, vertical: DM.p20),
        child: Form(
          key: _formKey,
          child: Container(
            width: DM.screenWidth,
            padding: EdgeInsets.all(DM.p20),
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(DM.p12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: DM.p15,
                  spreadRadius: DM.p2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFormField(
                  title: "Voucher No",
                  controller: voucherNo,
                  validator: validateString,
                  hint: "Enter voucher number",
                  inputType: TextInputType.text,
                ),
                SizedBox(height: DM.p15),
                _buildDateField(
                  title: "Voucher Date",
                  date: voucherDate!,
                  onTap: () => selectDate(context),
                ),
                SizedBox(height: DM.p15),
                _buildFormField(
                  title: "Total Amount",
                  controller: totalAmount,
                  validator: validateNumber,
                  hint: "Enter amount",
                  inputType: TextInputType.number,
                ),
                SizedBox(height: DM.p15),
                _buildCategoryField(),
                SizedBox(height: DM.p15),
                _buildNonEditableDateField(
                  title: "Posting Date",
                  date: postingDate,
                ),
                SizedBox(height: DM.p15),
                _buildFormField(
                  title: "Remarks",
                  controller: remarks,
                  validator: validateString,
                  hint: "Enter remarks",
                  inputType: TextInputType.text,
                ),
                SizedBox(height: DM.p30),
                Center(
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
                          icon:  Icon(Icons.error, color: whiteColor),
                          margin: EdgeInsets.symmetric(
                              horizontal: DM.p20, vertical: DM.p20),
                          backgroundColor: Colors.redAccent,
                          colorText: whiteColor,
                          "Error",
                          "Please fill all fields correctly",
                        );
                      }
                    },
                    height: DM.p50,
                    minWidth: DM.screenWidth * 0.4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DM.p12),
                    ),
                    color: appTheme,
                    child: Text(
                      "Submit",
                      style: TextStyle(
                        color: fullWhiteColor,
                        fontSize: DM.p16,
                        fontWeight: FontWeight.w600,
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

  Widget _buildFormField({
    required String title,
    required TextEditingController controller,
    required String? Function(String?) validator,
    required String hint,
    required TextInputType inputType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: DM.p16,
            color: blackFontColor,
          ),
        ),
        SizedBox(height: DM.p8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: inputType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade500),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding:
            EdgeInsets.symmetric(horizontal: DM.p15, vertical: DM.p12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DM.p8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DM.p8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DM.p8),
              borderSide: BorderSide(color: appTheme, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Category",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: DM.p16,
            color: blackFontColor,
          ),
        ),
        SizedBox(height: DM.p8),
        Row(
          children: [
            Expanded(
              child: Obx(() => Container(
                padding: EdgeInsets.symmetric(horizontal: DM.p15),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(DM.p8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButton<String>(
                  value: category,
                  hint: Text("Select Category",
                      style: TextStyle(color: Colors.grey.shade500)),
                  items: costController.categoryName
                      .map((value) => DropdownMenuItem(
                    value: value,
                    child: Text(value,
                        style: TextStyle(color: blackFontColor)),
                  ))
                      .toList(),
                  onChanged: (newValue) =>
                      setState(() => category = newValue!),
                  isExpanded: true,
                  underline: SizedBox(),
                ),
              )),
            ),
            SizedBox(width: DM.p10),
            MaterialButton(
              onPressed: showAddCategoryDialog,
              minWidth: DM.p50,
              height: DM.p50,
              color: appTheme,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DM.p8),
              ),
              child: Icon(Icons.add, color: fullWhiteColor),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String title,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: DM.p16,
            color: blackFontColor,
          ),
        ),
        SizedBox(height: DM.p8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: DM.p15, vertical: DM.p12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(DM.p8),
            ),
            child: Text(
              DateFormat('yyyy-MM-dd').format(date),
              style: TextStyle(fontSize: DM.p16, color: blackFontColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNonEditableDateField({
    required String title,
    required DateTime date,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: DM.p16,
            color: blackFontColor,
          ),
        ),
        SizedBox(height: DM.p8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: DM.p15, vertical: DM.p12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(DM.p8),
          ),
          child: Text(
            DateFormat('yyyy-MM-dd').format(date),
            style: TextStyle(fontSize: DM.p16, color: blackFontColor),
          ),
        ),
      ],
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