import 'package:flutter/material.dart';

import '../../../constants/colors.dart';
import '../../../responsives/dimensions.dart';

class FormUserAge extends StatefulWidget {
  final TextEditingController ageController;
  final bool readOnly;
  final String initialAge; // Add this to pass the initial age string

  const FormUserAge({
    Key? key,
    required this.ageController,
    this.readOnly = false,
    required this.initialAge, // Receive the initial age string
  }) : super(key: key);

  @override
  State<FormUserAge> createState() => _FormUserAgeState();
}

class _FormUserAgeState extends State<FormUserAge> {
  final TextEditingController _yearsController = TextEditingController();
  final TextEditingController _monthsController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _yearsController.addListener(_updateAgeString);
    _monthsController.addListener(_updateAgeString);
    _daysController.addListener(_updateAgeString);

    // Split the initial age string into years, months, and days
    _populateAgeFields(widget.initialAge);
  }

  void _populateAgeFields(String age) {
    // Split age by space to get the year, month, and day
    final ageParts = age.split(' ');

    for (var part in ageParts) {
      if (part.contains('y')) {
        _yearsController.text = part.replaceAll('y', '');
      } else if (part.contains('m')) {
        _monthsController.text = part.replaceAll('m', '');
      } else if (part.contains('d')) {
        _daysController.text = part.replaceAll('d', '');
      }
    }
  }

  void _updateAgeString() {
    final years = _yearsController.text.trim();
    final months = _monthsController.text.trim();
    final days = _daysController.text.trim();

    String ageString = "";

    if (years.isNotEmpty) {
      ageString += "${years}y ";
    }
    if (months.isNotEmpty) {
      ageString += "${months}m ";
    }
    if (days.isNotEmpty) {
      ageString += "${days}d";
    }

    widget.ageController.text = ageString.trim();
  }

  @override
  void dispose() {
    _yearsController.dispose();
    _monthsController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  String? _validateNumber(String? value) {
    if (value == null || value.isEmpty) return "Required";
    final number = int.tryParse(value);
    if (number == null) return "Invalid";
    if (number < 0) return "Can't be negative";
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(DM.p5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Age",
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: DM.p14,
                color: blackFontColor),
          ),
          SizedBox(width: DM.p80),
          Text(":"),
          SizedBox(width: DM.p10),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: TextFormField(
                    controller: _yearsController,
                    readOnly: widget.readOnly,
                    validator: _validateNumber,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      errorStyle: TextStyle(fontSize: DM.p14),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 1, color: orangeColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 1, color: orangeColor),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      border: InputBorder.none,
                      hintText: "Years",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: DM.p14),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Flexible(
                  child: TextFormField(
                    controller: _monthsController,
                    readOnly: widget.readOnly,
                    validator: _validateNumber,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      errorStyle: TextStyle(fontSize: DM.p14),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 1, color: orangeColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 1, color: orangeColor),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      border: InputBorder.none,
                      hintText: "Months",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: DM.p14),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Flexible(
                  child: TextFormField(
                    controller: _daysController,
                    readOnly: widget.readOnly,
                    validator: _validateNumber,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      errorStyle: TextStyle(fontSize: DM.p14),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 1, color: orangeColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 1, color: orangeColor),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      border: InputBorder.none,
                      hintText: "Days",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: DM.p14),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
