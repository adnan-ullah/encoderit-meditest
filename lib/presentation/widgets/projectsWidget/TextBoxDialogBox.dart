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
      padding: EdgeInsets.all(DM.p8),
      child: Stack(
        children: [
          Container(
              color: creamColor,
              height: DM.screenHeight * 0.5,
              width: DM.screenWidth * 0.9,
              padding: EdgeInsets.all(DM.p25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.keyTitle,
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: DM.p25,
                        color: Color.fromARGB(255, 26, 1, 1)),
                  ),
                  Card(
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.all(DM.p8),
                        child: TextField(
                          controller: contentController,
                           keyboardType: TextInputType.multiline,
                          maxLines: null, //or null
                          decoration: InputDecoration.collapsed(
                              hintText: "Write here..."),

                          onChanged: (value) {
                            if (widget.keyTitle == "Address") {
                              widget.addressText.text = value;
                            } else if (widget.keyTitle == "Referrer Info") {
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
                          color: whiteColor,
                          fontSize: DM.p15,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              )),
          Positioned(
              right: DM.p10,
              top: DM.p10,
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
