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
            duration: 6000,
            splashIconSize: 200,
            curve: Curves.easeInOutCirc,
            splash: Expanded(
              child: Container(
                color: Color.fromARGB(255, 228, 94, 5),
                padding: EdgeInsets.all(40),
                child: Column(
                  children: [
                    Text(
                      "Health Care!",
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 40,
                          color: Color.fromARGB(255, 255, 255, 255)),
                    ),
                    Text(
                      "Homelab!",
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 20,
                          color: Color.fromARGB(255, 255, 255, 255)),
                    ),
                  ],
                ),
              ),
            )));
  }
}
