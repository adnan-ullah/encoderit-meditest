import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:healthcare_homelab/constants/colors.dart';
import 'package:healthcare_homelab/presentation/pages/Create_Request.dart';

import 'presentation/pages/splash_pages/SplashScreen.dart';
import 'presentation/widgets/majorWidgets/MyScaffold.dart';

void main() => runApp(const MyApp());

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(MyApp());
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        home: SafeArea(
          child: Scaffold(
             resizeToAvoidBottomInset: true,
            body: MyScaffold(
              
                container: CreateRequest(),
                color1: creamColor,
                color2: creamColor),
          ),
        ));
  }
}
