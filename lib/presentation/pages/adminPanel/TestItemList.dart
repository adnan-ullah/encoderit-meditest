import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthcare_homelab/constants/api.dart';
import 'package:healthcare_homelab/constants/colors.dart';
import 'package:healthcare_homelab/db/models/TestData.dart';
import 'package:healthcare_homelab/presentation/pages/adminPanel/TestData.dart';
import 'package:healthcare_homelab/responsives/dimensions.dart';

class TestItemList extends StatefulWidget {
  const TestItemList({super.key});

  @override
  State<TestItemList> createState() => _TestItemListState();
}

class _TestItemListState extends State<TestItemList> {
  final List<TestData> _testItemsListAdmin = [];
  final List<TestData> _filterTestItemsList = [];
  final List<DatabaseReference> _refs = []; // For listener cleanup
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  bool _isSearchClear = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => getTestItemList());
    _searchController.addListener(() => filterTestItem(_searchController.text));
  }

  @override
  void dispose() {
    for (var ref in _refs) {
      ref.onDisconnect();
    }
    _searchController.dispose();
    super.dispose();
  }

  Future<void> getTestItemList() async {
    if (_isLoading) return;
    _setLoading(true);

    List<String> monthPaths = getLastYearTestDataPaths();
    setState(() {
      _testItemsListAdmin.clear();
      _filterTestItemsList.clear();
    });

    for (String path in monthPaths) {
      DatabaseReference dbRef = FirebaseDatabase.instance.ref(path);
      _refs.add(dbRef);

      dbRef.onValue.listen((event) {
        List<TestData> tempData = [];

        if (event.snapshot.exists) {
          for (DataSnapshot ds in event.snapshot.children) {
            try {
              Map<String, dynamic> json = jsonDecode(jsonEncode(ds.value));
              json['id'] = ds.key; // Ensure id is set
              TestData testData = TestData.fromJson(json);
              if (!tempData.any((item) => item.id == testData.id)) {
                tempData.add(testData);
              }
            } catch (e) {
              print("Error parsing data for path $path: $e");
            }
          }
        }

        if (mounted) {
          setState(() {
            _testItemsListAdmin.removeWhere(
                (item) => tempData.any((newItem) => newItem.id == item.id));
            _testItemsListAdmin.addAll(tempData);
            filterTestItem(_searchController.text);
          });
        }
      }, onError: (error) {
        print("Firebase error for path $path: $error");
        if (mounted) _setLoading(false);
      });
    }

    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) _setLoading(false);
  }

  Future<void> removeFromFirebase(String testItemId) async {
    try {
      List<String> paths = getLastYearTestDataPaths();
      bool removed = false;

      for (String path in paths) {
        DatabaseReference dbRef =
            FirebaseDatabase.instance.ref("$path/$testItemId");
        final snapshot = await dbRef.get();
        print("Checking path: $path/$testItemId, Exists: ${snapshot.exists}");

        if (snapshot.exists) {
          await dbRef.remove();
          print("Removed $testItemId from $path");
          removed = true;
        }
      }

      if (!removed) {
        print("No item with ID $testItemId found in any path");
      } else {
        // Trigger UI refresh
        if (mounted)
          setState(() {
            _testItemsListAdmin.removeWhere((item) => item.id == testItemId);
            filterTestItem(_searchController.text);
          });
      }
    } catch (e) {
      print("Error in removeFromFirebase: $e");
    }
  }

  void filterTestItem(String value) {
    setState(() {
      _filterTestItemsList.clear();
      if (value.isEmpty) {
        _isSearchClear = false;
        _filterTestItemsList.addAll(_testItemsListAdmin);
      } else {
        _isSearchClear = true;
        _filterTestItemsList.addAll(
          _testItemsListAdmin.where((element) =>
              element.name.toLowerCase().contains(value.toLowerCase())),
        );
      }
    });
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    setState(() => _isLoading = value);
    if (value) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
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
        ),
      );
    } else if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        backgroundColor: appTheme,
        title: Text(
          "Admin",
          style: TextStyle(color: secondaryColor, fontSize: DM.p30),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(DM.p8),
          child: Column(
            children: [
              Text(
                "Test Item List",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: DM.p25,
                  color: const Color.fromARGB(255, 26, 1, 1),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(DM.p10),
                child: TextFormField(
                  controller: _searchController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    suffixIcon: _isSearchClear
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : const Icon(Icons.search),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(DM.p40),
                      borderSide: BorderSide(width: DM.p1, color: appTheme),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(DM.p40),
                      borderSide: BorderSide(width: DM.p1, color: appTheme),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Search",
                    hintStyle: TextStyle(color: Colors.grey, fontSize: DM.p14),
                  ),
                ),
              ),
              _filterTestItemsList.isNotEmpty
                  ? Card(
                      child: SizedBox(
                        height: DM.screenHeight * 0.65,
                        child: ListView.builder(
                          itemCount: _filterTestItemsList.length,
                          itemBuilder: (context, index) {
                            final item = _filterTestItemsList[index];
                            return Container(
                              color: whiteColor,
                              padding: EdgeInsets.symmetric(
                                  horizontal: DM.p10, vertical: DM.p10),
                              margin: EdgeInsets.symmetric(vertical: DM.p5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: DM.p130,
                                    child: Text(
                                      "${item.name} (${item.diagnostic_center})",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: DM.p12,
                                        color: Color.fromARGB(255, 26, 1, 1),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: DM.p70,
                                    child: Text(
                                      "Price: ${item.testprice}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: DM.p12,
                                        color: Color.fromARGB(255, 26, 1, 1),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      MaterialButton(
                                        onPressed: () => Get.to(() =>
                                                TestDataCreate(testItem: item))
                                            ?.then((_) => getTestItemList()),
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
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        color: appTheme,
                                        icon: Icon(CupertinoIcons.delete,
                                            size: DM.p25),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              backgroundColor: secondaryColor,
                                              title: Text(
                                                "Delete ${item.name} (${item.diagnostic_center})?",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: DM.p20,
                                                  color: Color.fromARGB(
                                                      255, 26, 1, 1),
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Get.back(),
                                                  child: Text("Cancel",
                                                      style: TextStyle(
                                                          color: appTheme)),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    await removeFromFirebase(
                                                        item.id);
                                                    Get.back();
                                                  },
                                                  child: Text("Delete",
                                                      style: TextStyle(
                                                          color: appTheme)),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
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
              MaterialButton(
                onPressed: () => Get.to(() => TestDataCreate())
                    ?.then((_) => getTestItemList()),
                height: DM.p45,
                minWidth: DM.p130,
                shape: const StadiumBorder(),
                color: appTheme,
                child: Text(
                  "Add Item",
                  style: TextStyle(
                    color: fullWhiteColor,
                    fontSize: DM.p15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
