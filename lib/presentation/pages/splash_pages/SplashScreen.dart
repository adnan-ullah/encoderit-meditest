import 'dart:ui';

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:healthcare_homelab/constants/colors.dart';
import 'package:healthcare_homelab/presentation/pages/HomeScreen.dart';

import '../../../responsives/dimensions.dart';
import '../../widgets/majorWidgets/MyScaffold.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
        color1: Colors.amber,
        color2: Colors.amber,
        container: AnimatedSplashScreen(
            nextScreen: HomeScreen(),
            splashTransition: SplashTransition.scaleTransition,
            duration: 4000,
            splashIconSize: DM.p200,
            curve: Curves.easeInOutCirc,
            splash: Expanded(
              child: Container(
                color: Color.fromARGB(255, 228, 94, 5),
                padding: EdgeInsets.all(DM.p40),
                child: Column(
                  children: [
                    Text(
                      "Health Care!",
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: DM.p40,
                          color: Color.fromARGB(255, 255, 255, 255)),
                    ),
                    Text(
                      "Homelab!",
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: DM.p20,
                          color: Color.fromARGB(255, 255, 255, 255)),
                    ),
                  ],
                ),
              ),
            )));
  }
}
