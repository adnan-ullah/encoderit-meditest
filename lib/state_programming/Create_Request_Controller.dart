import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthcare_homelab/db/databse_model.dart';

import '../constants/colors.dart';

class CreateRequest_controller extends GetxController {
  RxString address = "".obs;
  RxString referredAddress = "".obs;

  RxString testKey = "".obs;
  var testData = <TestData>[].obs;
  var testItemList = <TestData>[].obs;
  var filter_testItemList = <TestData>[].obs;


    var testRequestList = <TestData>[].obs;
  var filter_testRequestList = <TestData>[].obs;


  Rx<Icon> searchBox = Icon(Icons.search,color: orangeColor,).obs;
  Rx<Icon> clearBox = Icon(Icons.clear, color: orangeColor,).obs;
  
  //var testItemListWithSelected = <Map<String, bool>>[].obs;

  final Map<String, bool> testItemListWithSelected = {};

  RxInt totalTestCost = 0.obs;
  RxInt totalCost = 0.obs;
  RxInt serviceCost = 0.obs;
  RxInt tubeCost = 0.obs;
  RxInt totalDiscount = 0.obs;
  RxString emptyString = "No item selected, please add test".obs;

  //method

  // void getTotal(testData) {
  //   totalTestCost.value = totalTestCost.value + testData.testprice;
  //   totalCost.value = totalTestCost.value + serviceCost.value;
  // }

  // void updateData(index) {
  //   totalTestCost.value = totalTestCost.value - testData[index].testprice;
  //   testData.removeAt(index);

  //   totalCost.value = totalTestCost.value + serviceCost.value;
  //   if (totalTestCost.value == 0.0) {
  //     serviceCost.value = 0;
  //     totalCost.value = 0;
  //   }
  // }

  // void removeTestData(id, index) {
  //   totalTestCost.value = totalTestCost.value -
  //       (testData[index].testprice +
  //           testData[index].testkitprice -
  //           testData[index].discount);

  //   totalCost.value = totalCost.value - totalTestCost.value - serviceCost.value;

  //   testData.removeWhere((element) => element.id == id);
  //   if (testData.isEmpty) serviceCost.value = 0.0;
  //   testItemListWithSelected[id] = !testItemListWithSelected[id]!;
  // }

  // void calulationTestdata() {
  //   testData.map((testItem) {
  //     if(testItemListWithSelected[testItem.id]!=true)
  //     {
  //         totalTestCost.value = totalTestCost.value +
  //         testItem.testprice +
  //         testItem.testkitprice -
  //         testItem.discount;

  //     serviceCost.value =
  //         max(serviceCost.value, testItem.servicecharge.toDouble());
  //     }

  //   }).toList();

  //   totalCost.value = totalTestCost.value + serviceCost.value;
  // }
}
