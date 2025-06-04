import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../constants/colors.dart';
import '../../../db/models/TestDataRequest.dart';

class DateFilterWithUtils extends StatefulWidget {
  final int initialStartDate;
  final int initialEndDate;
  final ValueChanged<int> onStartDateChanged;
  final ValueChanged<int> onEndDateChanged;

  const DateFilterWithUtils({
    super.key,
    required this.initialStartDate,
    required this.initialEndDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
  });

  static bool isDateInRangeInCash(
      TestDataRequest request,
      dynamic payDate,
      int startDate,
      int endDate
      ) {
    final int? pay = payDate is int ? payDate : int.tryParse(payDate.toString());

    if (pay != null && pay != 0 && startDate <= pay && pay <= endDate) {
      return true;
    }
    return false;
  }


  static bool isDateInRange(TestDataRequest request, int startDate, int endDate, bool considerDate) {
    final dates = [
      request.advance_payment_date,
      request.due_recieve_one_date,
      request.due_recieve_two_date,
    ];

    final hasMatchInPriorityDates = dates.any((date) =>
    date != null && date != 0 && startDate <= date && date <= endDate);

    if (hasMatchInPriorityDates) {
      return true;
    }
    if (considerDate) {
      final created = request.dateofcreated;
      return created != null && created != 0 && startDate <= created && created <= endDate;
    }
    return false;
  }

  static int parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static int getMatchedPaymentSumInRange(TestDataRequest data, int startDate, int endDate) {
    int sum = 0;

    final advDate = parseToInt(data.advance_payment_date);
    final advAmount = parseToInt(data.advanced);

    final dueOneDate = parseToInt(data.due_recieve_one_date);
    final dueOneAmount = parseToInt(data.due_recieved_one);

    final dueTwoDate = parseToInt(data.due_recieve_two_date);
    final dueTwoAmount = parseToInt(data.due_recieved_two);

    if (advDate >= startDate && advDate <= endDate) {
      sum += advAmount;
    }
    if (dueOneDate >= startDate && dueOneDate <= endDate) {
      sum += dueOneAmount;
    }
    if (dueTwoDate >= startDate && dueTwoDate <= endDate) {
      sum += dueTwoAmount;
    }

    return sum;
  }




  static int getDefaultStartDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1, 0, 0, 1).millisecondsSinceEpoch;
  }

  static int getDefaultEndDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 23, 59, 59).millisecondsSinceEpoch;
  }

  static DateTime toDateTime(int milliseconds) {
    return DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: false);
  }

  @override
  State<DateFilterWithUtils> createState() => _DateFilterWithUtilsState();
}

class _DateFilterWithUtilsState extends State<DateFilterWithUtils> {
  late int startDate;
  late int endDate;

  @override
  void initState() {
    super.initState();
    startDate = widget.initialStartDate;
    endDate = widget.initialEndDate;
  }

  Future<void> _pickStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateFilterWithUtils.toDateTime(startDate),
      firstDate: DateTime(2022, 11),
      lastDate: DateTime(2030, 7),
    );
    if (picked != null) {
      setState(() {
        startDate = DateTime(picked.year, picked.month, picked.day, 0, 0, 1).millisecondsSinceEpoch;
        widget.onStartDateChanged(startDate);
      });
    }
  }

  Future<void> _pickEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateFilterWithUtils.toDateTime(endDate),
      firstDate: DateTime(2022, 11),
      lastDate: DateTime(2030, 7),
    );
    if (picked != null) {
      setState(() {
        endDate = DateTime(picked.year, picked.month, picked.day, 23, 59, 59).millisecondsSinceEpoch;
        widget.onEndDateChanged(endDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Container(
              height: 60.0,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:appTheme,
                  elevation: 0,
                ),
                onPressed: () => _pickStartDate(context),
                child: Text(
                  "First: ${DateFormat.yMMMd().format(DateFilterWithUtils.toDateTime(startDate))}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(width: 15.0),
          Flexible(
            child: Container(
              height: 60.0,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: appTheme,
                  elevation: 0,
                ),
                onPressed: () => _pickEndDate(context),
                child: Text(
                  "Last: ${DateFormat.yMMMd().format(DateFilterWithUtils.toDateTime(endDate))}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}