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
        color1: creamColor,
        color2: creamColor,
        container: AnimatedSplashScreen(
            nextScreen: HomeScreen(),
            splashTransition: SplashTransition.scaleTransition,
            duration: 3000,
            splashIconSize: 100,
            curve: Curves.easeInOutCirc,
            splash: Expanded(
              child: Column(
                children: [
                  Text(
                    "MediTest!",
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 40,
                        color: Color.fromARGB(255, 26, 1, 1)),
                  ),
                ],
              ),
            )));
  }
}
