import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthcare_homelab/db/databse_model.dart';

class CreateRequest_controller extends GetxController {
  RxString address = "".obs;
  RxString referredAddress = "".obs;

  RxString testKey = "".obs;
  var testData = <TestData>[].obs;

  RxDouble totalTestCost = 0.0.obs;
  RxDouble totalCost = 0.0.obs;
  RxDouble serviceCost = 100.0.obs;

  //method

  void getTotal(testData) {
    totalTestCost.value = totalTestCost.value + testData.testprice;
    totalCost.value = totalTestCost.value + serviceCost.value;
  }

  void updateData(index) {
    totalTestCost.value = totalTestCost.value - testData[index].testprice;
    testData.removeAt(index);

    totalCost.value = totalTestCost.value + serviceCost.value;
    if (totalTestCost.value == 0.0) {
      serviceCost.value = 0;
      totalCost.value = 0;
    }
  }

  void removeTestData() {
    testData.removeWhere((element) => element.id == testKey.value.toString());
  }
}
