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
  final Map<String, List<String>> _itemPaths = {};
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
    _searchController.dispose();
    super.dispose();
  }

  Future<void> getTestItemList() async {
    if (_isLoading) return;
    _setLoading(true);

    try {
      final snapshot =
          await FirebaseDatabase.instance.ref(testModelRootApi).get();
      final Map<String, TestData> latestById = {};
      final Map<String, List<String>> pathsById = {};

      // Structure: testModel/{year}/{month}/{testId}
      for (final year in snapshot.children) {
        for (final month in year.children) {
          for (final itemSnapshot in month.children) {
            try {
              final data = Map<String, dynamic>.from(
                jsonDecode(jsonEncode(itemSnapshot.value)),
              );
              data['id'] ??= itemSnapshot.key;
              final item = TestData.fromJson(data);
              final id = item.id?.toString();
              if (id == null || id.isEmpty) continue;

              final path =
                  '$testModelRootApi/${year.key}/${month.key}/${itemSnapshot.key}';
              pathsById.putIfAbsent(id, () => []).add(path);

              final existing = latestById[id];
              if (existing == null ||
                  _timestampOf(item.lastupdate) >=
                      _timestampOf(existing.lastupdate)) {
                latestById[id] = item;
              }
            } catch (_) {
              // Ignore a malformed item without hiding the remaining catalog.
            }
          }
        }
      }

      final items = latestById.values.toList()
        ..sort((a, b) => a.name
            .toString()
            .toLowerCase()
            .compareTo(b.name.toString().toLowerCase()));

      if (!mounted) return;
      setState(() {
        _itemPaths
          ..clear()
          ..addAll(pathsById);
        _testItemsListAdmin
          ..clear()
          ..addAll(items);
        _applyFilter(_searchController.text);
      });
    } catch (_) {
      if (mounted) {
        Get.snackbar(
          'Unable to load test items',
          'Please check the connection and try again.',
          backgroundColor: redColor,
          colorText: whiteColor,
        );
      }
    } finally {
      if (mounted) _setLoading(false);
    }
  }

  Future<void> removeFromFirebase(String testItemId) async {
    try {
      final paths = _itemPaths[testItemId] ?? const <String>[];
      if (paths.isEmpty) return;
      await Future.wait(
        paths.map((path) => FirebaseDatabase.instance.ref(path).remove()),
      );

      if (mounted) {
        setState(() {
          _itemPaths.remove(testItemId);
          _testItemsListAdmin.removeWhere((item) => item.id == testItemId);
          _applyFilter(_searchController.text);
        });
      }
    } catch (e) {
      print("Error in removeFromFirebase: $e");
    }
  }

  int _timestampOf(dynamic value) =>
      int.tryParse(value?.toString() ?? '') ?? 0;

  void _applyFilter(String value) {
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
  }

  void filterTestItem(String value) {
    setState(() {
      _applyFilter(value);
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
                                                TestDataCreate(
                                                  testItem: item,
                                                  sourcePaths: _itemPaths[
                                                          item.id.toString()] ??
                                                      const <String>[],
                                                ))
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
