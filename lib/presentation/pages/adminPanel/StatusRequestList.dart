import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthcare_homelab/constants/api.dart';
import 'package:healthcare_homelab/constants/colors.dart';
import 'package:healthcare_homelab/presentation/widgets/projectsWidget/Notifications/GenerateNotification.dart';
import 'package:healthcare_homelab/presentation/widgets/projectsWidget/Notifications/NotificationServices.dart';
import 'package:healthcare_homelab/state_programming/CreateRequestController.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants/app_info.dart';
import '../../../responsives/dimensions.dart';
import '../../widgets/projectsWidget/RequestListTabView.dart';

class StatusRequestList extends StatefulWidget {
  final List<int> statusIndices;
  final List<bool> isButtonList;

  StatusRequestList({
    super.key,
    required this.statusIndices,
    required this.isButtonList,
  }) : assert(statusIndices.length == isButtonList.length, 'Lists must have the same length');

  @override
  State<StatusRequestList> createState() => _StatusRequestListState();
}

FirebaseMessaging messaging = FirebaseMessaging.instance;

class _StatusRequestListState extends State<StatusRequestList> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late TabController tabController;
  CreateRequestController cr_controller = Get.put(CreateRequestController());
  var isLoading = true;
  dynamic status2;
  late DatabaseReference _dbref_testReqModel;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    populateAllRequest();
    tabController = TabController(
      length: widget.statusIndices.length,
      vsync: this,
      initialIndex: 0,
    );

    setState(() {
      _selectedIndex = tabController.index;
    });

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    status2?.cancel();
    tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onLoading(bool isClosed) {
    if (isClosed) {
      setState(() {
        isLoading = true;
      });
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
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
          );
        },
      );
    } else if (!isClosed && isLoading) {
      setState(() {
        isLoading = false;
      });
      Navigator.pop(context);
    }
  }

  Future<void> _getNotification(BuildContext context) async {
    List<String> lastThreeMonthsPaths = getLastThreeMonthTestRequestPaths();

    for (String path in lastThreeMonthsPaths) {
      DatabaseReference dbref = FirebaseDatabase.instance.ref(path);

      dbref.onChildAdded.listen((event) async {
        SharedPreferences refs = await SharedPreferences.getInstance();
        var phoneNumber = refs.getString("phoneNumber");
        var type_admin = refs.getString("type");
        getAdminNotification(phoneNumber, type_admin, context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _getNotification(context);

    return Scaffold(
      resizeToAvoidBottomInset: true, // Allow resizing when keyboard appears
      backgroundColor: secondaryColor,
      appBar: AppBar(
        backgroundColor: appTheme,
        actions: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: DM.p50, vertical: DM.p10),
            width: DM.screenWidth,
            child: Text(
              "Report Status",
              textAlign: TextAlign.left,
              style: TextStyle(color: secondaryColor, fontSize: DM.p30),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(DM.p5),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(DM.p8),
                child: Container(
                  height: DM.p40,
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(DM.p10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: DM.p8,
                        offset: Offset(0, DM.p2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Search by Invoice ID or Name',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: DM.p14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(DM.p10),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: whiteColor,
                      prefixIcon: Icon(
                        Icons.search,
                        size: DM.p20,
                        color: _searchFocusNode.hasFocus ? appTheme : Colors.grey.shade600,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: DM.p8, horizontal: DM.p12),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                        icon: Icon(Icons.clear, size: DM.p20, color: Colors.grey.shade600),
                        onPressed: () {
                          _searchController.clear();
                          _searchFocusNode.unfocus();
                        },
                      )
                          : null,
                    ),
                    style: TextStyle(fontSize: DM.p14, color: blackFontColor),
                    onTap: () {
                      setState(() {}); // Trigger rebuild to update focus state
                    },
                  ),
                ),
              ),
              Container(
                height: DM.p40,
                child: TabBar(
                  isScrollable: true,
                  controller: tabController,
                  tabs: widget.statusIndices.map((index) {
                    return Tab(
                      child: Text(
                        "${cr_controller.status[index] ?? ''}",
                        style: TextStyle(
                          color: blackFontColor,
                          fontSize: DM.p11,
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: true,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: tabController,
                  children: widget.statusIndices.asMap().entries.map((entry) {
                    int idx = entry.key;
                    int statusIndex = entry.value;
                    return RequestListTabView(
                      statusKey: cr_controller.status[statusIndex] ?? '',
                      isButton: widget.isButtonList[idx],
                      searchQuery: _searchQuery,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> populateAllRequest() async {
  CreateRequestController createRequestController = Get.put(CreateRequestController());
  FirebaseDatabase.instance.setPersistenceEnabled(true);

  createRequestController.testItemList.clear();
  createRequestController.testItemListWithSelected.clear();

  List<String> lastThreeMonthsPaths = getLastThreeMonthTestRequestPaths();

  for (String path in lastThreeMonthsPaths) {
    DatabaseReference dbrefTestRequest = FirebaseDatabase.instance.ref(path);
    dbrefTestRequest.keepSynced(true);

    dbrefTestRequest.onValue.listen((event) {
      if (event.snapshot.exists) {
        print("Data from $path: ${event.snapshot.value}");
      }
    });
  }
}

Future<void> getAdminNotification(String? phone, String? type, BuildContext context) async {
  if (type == "1" || type == "7" || phone == "$superUser") {
    createPlantFoodNotification();
    showNotification(context);
  }
}

List<String> getLastThreeMonthTestRequestPaths() {
  List<String> paths = [];
  DateTime now = DateTime.now();
  for (int i = 0; i < 3; i++) {
    DateTime date = DateTime(now.year, now.month - i, 1);
    String year = date.year.toString();
    String month = const ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'][date.month - 1];
    paths.add("$database_name/testRequest/$year/$month");
  }
  return paths;
}