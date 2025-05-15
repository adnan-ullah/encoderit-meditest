import 'package:flutter/material.dart';

import '../../../constants/colors.dart';
import '../../../responsives/dimensions.dart';

class FormUserAge extends StatefulWidget {
  final TextEditingController ageController;
  final bool readOnly;
  final String initialAge;
  dynamic formKey;

  FormUserAge({
    Key? key,
    required this.formKey,
    required this.ageController,
    this.readOnly = false,
    required this.initialAge,
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
    _yearsController.addListener(_updateAgeString);
    _monthsController.addListener(_updateAgeString);
    _daysController.addListener(_updateAgeString);

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
    _validateInputs(); // Real-time validation
  }

  bool _anyFieldFilled() {
    return _yearsController.text.trim().isNotEmpty ||
        _monthsController.text.trim().isNotEmpty ||
        _daysController.text.trim().isNotEmpty;
  }

  String? _validateInputs() {
    final years = _yearsController.text.trim();
    final months = _monthsController.text.trim();
    final days = _daysController.text.trim();

    if (!_anyFieldFilled()) {
      setState(() {
        _errorMessage = "At least one field is required";
      });
      return _errorMessage;
    }

    if (years.isNotEmpty) {
      final number = int.tryParse(years);
      if (number == null) {
        setState(() {
          _errorMessage = "Years must be a valid number";
        });
        return _errorMessage;
      }
      if (number < 0) {
        setState(() {
          _errorMessage = "Years cannot be negative";
        });
        return _errorMessage;
      }
    }

    if (months.isNotEmpty) {
      final number = int.tryParse(months);
      if (number == null) {
        setState(() {
          _errorMessage = "Months must be a valid number";
        });
        return _errorMessage;
      }
      if (number < 0) {
        setState(() {
          _errorMessage = "Months cannot be negative";
        });
        return _errorMessage;
      }
    }

    if (days.isNotEmpty) {
      final number = int.tryParse(days);
      if (number == null) {
        setState(() {
          _errorMessage = "Days must be a valid number";
        });
        return _errorMessage;
      }
      if (number < 0) {
        setState(() {
          _errorMessage = "Days cannot be negative";
        });
        return _errorMessage;
      }
    }

    setState(() {
      _errorMessage = null; // Clear error if valid
    });
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

    final errorMessage = _validateInputs();
    if (errorMessage != null) {
      setState(() {
        _errorMessage = errorMessage;
      });
    }

    return Padding(
      padding: EdgeInsets.all(DM.p5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Age",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: DM.p14,
                  color: blackFontColor,
                ),
              ),
              SizedBox(width: DM.p80),
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
                    validator: (value) {
                      final result = _validateInputs();
                      return result == null ? null : '';
                    },
                        onChanged: ((value) {
                          if (!widget.formKey.currentState?.validate()) {
                            widget.formKey.currentState?.validate();
                          }
                        }),
                        decoration: InputDecoration(
                          errorStyle: const TextStyle(height: 0), // Hide field error
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 1, color: appTheme),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 1, color: appTheme),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
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
                        onChanged: ((value) {
                          if (!widget.formKey.currentState?.validate()) {
                            widget.formKey.currentState?.validate();
                          }
                        }),
                        keyboardType: TextInputType.number,
                          validator: (value) {
                            final result = _validateInputs();
                            return result == null ? null : '';
                          },
                        decoration: InputDecoration(
                          errorStyle: const TextStyle(height: 0), // Hide field error
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 1, color: appTheme),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 1, color: appTheme),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                          border: InputBorder.none,
                          hintText: "Months",
                          hintStyle: TextStyle(color: Colors.grey, fontSize: DM.p14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: TextFormField(
                        controller: _daysController,
                        readOnly: widget.readOnly,
                        onChanged: ((value) {
                          if (!widget.formKey.currentState?.validate()) {
                            widget.formKey.currentState?.validate();
                          }
                        }),
                        keyboardType: TextInputType.number,
                          validator: (value) {
                            final result = _validateInputs();
                            return result == null ? null : '';
                          },
                        decoration: InputDecoration(
                          errorStyle: const TextStyle(height: 0), // Hide field error
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 1, color: appTheme),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 1, color: appTheme),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                          border: InputBorder.none,
                          hintText: "Days",
                          hintStyle: TextStyle(color: Colors.grey, fontSize: DM.p14),
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