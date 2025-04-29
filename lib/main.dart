import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:healthcare_homelab/constants/colors.dart';
import 'package:healthcare_homelab/db/databse_model.dart';
import 'package:healthcare_homelab/presentation/pages/Create_Prescription.dart';
import 'package:healthcare_homelab/presentation/pages/Create_Request.dart';
import 'package:healthcare_homelab/presentation/pages/HomeScreen.dart';
import 'package:healthcare_homelab/presentation/pages/Invoice_pdf/page/PdfPage.dart';
import 'package:healthcare_homelab/presentation/pages/Login_info.dart';
import 'package:healthcare_homelab/presentation/pages/adminPanel/AdminHom.dart';
import 'package:healthcare_homelab/presentation/pages/adminPanel/StatusRequestList.dart';
import 'package:healthcare_homelab/presentation/pages/adminPanel/TestData.dart';
import 'package:healthcare_homelab/presentation/pages/adminPanel/TestItemList.dart';
import 'package:healthcare_homelab/presentation/pages/adminPanel/TestRequestItem.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import 'presentation/pages/splash_pages/SplashScreen.dart';
import 'presentation/widgets/majorWidgets/MyScaffold.dart';
import 'responsives/dimensions.dart';

import 'package:device_preview/device_preview.dart';

// void main() => runApp(const MyApp());

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AwesomeNotifications().initialize(
  'resource://drawable/new_plus',
  [
    NotificationChannel(
      channelKey: 'basic_channel',
      channelName: 'Basic Notifications',
      defaultColor: Color.fromARGB(255, 2, 39, 35),
      importance: NotificationImportance.High,
      channelShowBadge: true, channelDescription: '',
    ),
  ],
);

 
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    getNotification();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        home: SafeArea(
            maintainBottomViewPadding: true,
            child: Scaffold(
                resizeToAvoidBottomInset: true,
                body: MyScaffold(
                    container: SplashScreen(),
                    color1: secondaryColor,
                    color2: secondaryColor))),
      );
    
  }
}

String messageTitle = "Empty";
String notificationAlert = "alert";

FirebaseMessaging messaging = FirebaseMessaging.instance;

Future<void> getNotification() async {
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data.values}');

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String build_Number = packageInfo.buildNumber;
    print(build_Number);

    if (int.parse(message.data["update_version"]) > int.parse(build_Number)) {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      sharedPreferences.setInt(
          "update_version", int.parse(message.data["update_version"]));
      sharedPreferences.setString(
          "update_details", message.data["update_details"]);
    }

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  });
}
