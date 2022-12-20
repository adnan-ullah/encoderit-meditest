import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthcare_homelab/constants/colors.dart';
import 'package:healthcare_homelab/state_programming/Create_Request_Controller.dart';

import '../../../responsives/dimensions.dart';

class TextDialogueBox extends StatefulWidget {
  dynamic keyTitle;
  var addressText = TextEditingController();

  TextDialogueBox(
      {super.key, required this.keyTitle, required this.addressText});

  @override
  State<TextDialogueBox> createState() => _TextDialogueBoxState();
}

class _TextDialogueBoxState extends State<TextDialogueBox> {
  @override
  Widget build(BuildContext context) {
    var contentController =
        TextEditingController(text: widget.addressText.text);

    setState(() {
      if (contentController.text != '')
        contentController.selection = TextSelection.fromPosition(
            TextPosition(offset: widget.addressText.text.length));
    });

    CreateRequest_controller createRequest_controller =
        Get.put(CreateRequest_controller());
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          Container(
              color: creamColor,
              height: DM.screenHeight * 0.5,
              width: DM.screenWidth * 0.9,
              padding: EdgeInsets.all(25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Address",
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 25,
                        color: Color.fromARGB(255, 26, 1, 1)),
                  ),
                  Card(
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: TextField(
                          controller: contentController,

                          maxLines: 8, //or null
                          decoration: InputDecoration.collapsed(
                              hintText: "Write your address here..."),

                          onChanged: (value) {
                            if (widget.keyTitle == "Address") {
                              widget.addressText.text = value;
                            } else if (widget.keyTitle == "Referred Address") {
                              widget.addressText.text = value;
                            }
                          },
                        ),
                      )),
                  MaterialButton(
                    onPressed: () {
                      widget.addressText.text = contentController.text;
                      Get.back();
                    },
                    height: DM.p45,
                    minWidth: DM.p130,
                    shape: const StadiumBorder(),
                    color: orangeColor,
                    child: Text(
                      "Submit",
                      style: TextStyle(
                          color: font_bgOrange,
                          fontSize: DM.p15,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
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
