import 'package:flutter/material.dart';

import '../../../constants/colors.dart';
import '../../../responsives/dimensions.dart';

class FormUserAge extends StatefulWidget {
  final TextEditingController ageController;
  final bool readOnly;
  final String initialAge;
  final GlobalKey<FormState> formKey;
  final bool isAdmin;

  FormUserAge({
    Key? key,
    required this.formKey,
    required this.ageController,
    this.readOnly = false,
    required this.initialAge,
    this.isAdmin = false,
  }) : super(key: key);

  @override
  State<FormUserAge> createState() => _FormUserAgeState();
}

class _FormUserAgeState extends State<FormUserAge> {
  final TextEditingController _yearsController = TextEditingController();
  final TextEditingController _monthsController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _yearsController.addListener(_onChanged);
    _monthsController.addListener(_onChanged);
    _daysController.addListener(_onChanged);

    _populateAgeFields(widget.initialAge);
    _validateInputs(); // Initial validation
  }

  void _populateAgeFields(String age) {
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

  void _onChanged() {
    setState(() {
      _updateAgeString();
      _validateInputs();
      widget.formKey.currentState?.validate();
    });
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

  bool _anyFieldFilled() {
    return _yearsController.text.trim().isNotEmpty ||
        _monthsController.text.trim().isNotEmpty ||
        _daysController.text.trim().isNotEmpty;
  }

  String? _validateInputs() {
    final monthsText = _monthsController.text.trim();
    final daysText = _daysController.text.trim();

    if (!_anyFieldFilled()) {
      _errorMessage = "At least one field is required";
      return _errorMessage;
    }

    if (monthsText.isNotEmpty) {
      final months = int.tryParse(monthsText);
      if (months == null || months < 0 || months > 12) {
        _errorMessage = "Months must be between 0 and 12";
        return _errorMessage;
      }
    }

    if (daysText.isNotEmpty) {
      final days = int.tryParse(daysText);
      if (days == null || days < 0 || days > 31) {
        _errorMessage = "Days must be between 0 and 31";
        return _errorMessage;
      }
    }

    _errorMessage = null;
    return null;
  }

  @override
  void dispose() {
    _yearsController.dispose();
    _monthsController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(DM.p5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.isAdmin ? "Age" : "Age (বয়স)",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: DM.p14,
                  color: blackFontColor,
                ),
              ),
              SizedBox(width: widget.isAdmin ? DM.p80 : DM.p35),
              const Text(":"),
              SizedBox(width: DM.p10),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: TextFormField(
                        controller: _yearsController,
                        readOnly: widget.readOnly,
                        keyboardType: TextInputType.number,
                        // no validation on years
                        decoration: InputDecoration(
                          errorStyle: const TextStyle(height: 0),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 1, color: appTheme),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 1, color: appTheme),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10),
                          border: InputBorder.none,
                          hintText: "Years",
                          hintStyle: TextStyle(color: Colors.grey, fontSize: DM.p14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: TextFormField(
                        controller: _monthsController,
                        readOnly: widget.readOnly,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          return _validateInputs() == null ? null : '';
                        },
                        decoration: InputDecoration(
                          errorStyle: const TextStyle(height: 0),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 1, color: appTheme),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 1, color: appTheme),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10),
                          border: InputBorder.none,
                          hintText: "Months",
                          hintStyle:
                          TextStyle(color: Colors.grey, fontSize: DM.p14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: TextFormField(
                        controller: _daysController,
                        readOnly: widget.readOnly,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          return _validateInputs() == null ? null : '';
                        },
                        decoration: InputDecoration(
                          errorStyle: const TextStyle(height: 0),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 1, color: appTheme),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 1, color: appTheme),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10),
                          border: InputBorder.none,
                          hintText: "Days",
                          hintStyle:
                          TextStyle(color: Colors.grey, fontSize: DM.p14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_errorMessage != null)
            Padding(
              padding: EdgeInsets.only(left: DM.p130, top: DM.p5),
              child: Text(
                _errorMessage!,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: DM.p9,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
