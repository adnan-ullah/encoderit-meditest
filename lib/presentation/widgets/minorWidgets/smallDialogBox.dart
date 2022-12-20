import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../responsives/dimensions.dart';

class SmallDialogueBox extends StatelessWidget {
  const SmallDialogueBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          Container(
              color: Colors.white,
              height: DM.screenHeight * 0.5,
              width: DM.screenWidth * 0.9,
              padding: EdgeInsets.all(25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Share",
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 25,
                        color: Color.fromARGB(255, 26, 1, 1)),
                  ),
                  Text(
                    "I am Adnan Ullah, welcome to my env and support my activies",
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color.fromARGB(255, 134, 134, 134)),
                  ),
                  CupertinoButton(
                      color: Colors.amber,
                      child: Text("Follow me"),
                      onPressed: () {}),
                  CupertinoButton(child: Text("Contact me"), onPressed: () {})
                ],
              )),
          Positioned(
              right: 10,
              top: 10,
              child: IconButton(
                icon: Icon(CupertinoIcons.xmark),
                onPressed: () {
                  Get.back();
                },
              ))
        ],
      ),
    );
  }
}
