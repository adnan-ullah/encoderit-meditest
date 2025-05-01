import 'dart:ui';

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:easy_splash_screen/easy_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:healthcare_homelab/constants/colors.dart';
import 'package:healthcare_homelab/presentation/pages/HomeScreen.dart';
import 'package:healthcare_homelab/presentation/pages/LoginScreen.dart';

import '../../../responsives/dimensions.dart';
import '../../widgets/otherWidgets/MyScaffold.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print(MediaQuery.of(context).size.width); print(MediaQuery.of(context).size.height);
    return MyScaffold(
        color1: Colors.green,
        color2: Colors.green,
        container: EasySplashScreen(
          loaderColor: appTheme,
          //backgroundImage: Image.asset('lib/assets/images/plus.png',,).image,
          logo: Image(image: AssetImage("lib/assets/images/new_plus.png")),

          title: Text(
            "Health Care Homelab",
            style: TextStyle(
              fontSize: DM.p22,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: secondaryColor,
          showLoader: true,

          loadingText: Text(
            "Loading...",
            style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: DM.p18,
                color: Color.fromARGB(255, 26, 1, 1)),
          ),
          navigator: LoginScreen(),
          durationInSeconds: 5,
        ));
  }
}



// AnimatedSplashScreen(
//             nextScreen: HomeScreen(),
//             splashTransition: SplashTransition.scaleTransition,
//             duration: 4000,
//             splashIconSize: DM.p200,
//             curve: Curves.easeInOutCirc,
//             splash: Expanded(
//               child: Container(
//                 color: Color.fromARGB(255, 228, 94, 5),
//                 padding: EdgeInsets.all(DM.p40),
//                 child: Column(
//                   children: [
//                     Text(
//                       "Health Care!",
//                       style: TextStyle(
//                           fontWeight: FontWeight.w400,
//                           fontSize: DM.p40,
//                           color: Color.fromARGB(255, 255, 255, 255)),
//                     ),
//                     Text(
//                       "Homelab!",
//                       style: TextStyle(
//                           fontWeight: FontWeight.w400,
//                           fontSize: DM.p20,
//                           color: Color.fromARGB(255, 255, 255, 255)),
//                     ),
//                   ],
//                 ),
//               ),
//             )))