import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../responsives/dimensions.dart';
import '../../state_programming/getController.dart';

class TemplateScreen extends StatefulWidget {
  static const String id = "sign_up_page";
  var phoneNumber;

  TemplateScreen({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  _TemplateScreenState createState() => _TemplateScreenState();
}

class _TemplateScreenState extends State<TemplateScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.centerRight,
                  colors: [
                Color.fromARGB(255, 82, 40, 40),
                Color.fromARGB(255, 117, 26, 26),
                Color.fromARGB(255, 31, 3, 3),
              ])),
          child: Column(
            children: [
              Expanded(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: DM.p20, vertical: DM.p20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // #signup_text
                        Text(
                          "Log In",
                          textAlign: TextAlign.left,
                          style:
                              TextStyle(color: Colors.white, fontSize: DM.p32),
                        ),
                        SizedBox(
                          height: DM.p5,
                        ),

                        // #welcome
                        Text(
                          "ChatBot with AU_AB",
                          textAlign: TextAlign.left,
                          style:
                              TextStyle(color: Colors.white, fontSize: DM.p18),
                        ),
                      ],
                    ),
                  )),
              Expanded(
                flex: 5,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: Color.fromARGB(255, 255, 219, 219),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(DM.p50),
                          topRight: Radius.circular(DM.p50))),
                  child: Column(
                    children: [
                      SizedBox(
                        height: DM.p140,
                      ),

                      // #text_field
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: DM.p30),
                        height: MediaQuery.of(context).size.height * 0.2,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Color.fromARGB(255, 255, 255, 255),
                            borderRadius: BorderRadius.circular(DM.p10),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.shade300,
                                  blurRadius: DM.p20,
                                  spreadRadius: DM.p10,
                                  offset: Offset(0, DM.p10))
                            ]),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextField(
                              decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: DM.p10),
                                  border: InputBorder.none,
                                  hintText: "Email",
                                  hintStyle: TextStyle(color: Colors.grey)),
                            ),
                            Divider(
                              thickness: 0.5,
                              height: DM.p10,
                            ),
                            TextField(
                              decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: DM.p10),
                                  border: InputBorder.none,
                                  hintText: "Password",
                                  hintStyle: TextStyle(color: Colors.grey)),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: DM.p35,
                      ),

                      // #signup_button
                      MaterialButton(
                        onPressed: () => {},
                        height: DM.p45,
                        minWidth: DM.p240,
                        shape: const StadiumBorder(),
                        color: Color.fromARGB(255, 71, 4, 4),
                        child: Text(
                          "Log In",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: DM.p14,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Divider(
                        thickness: 0.5,
                        height: DM.p10,
                      ),
                      MaterialButton(
                        onPressed: () => {},
                        height: DM.p45,
                        minWidth: DM.p240,
                        shape: const StadiumBorder(),
                        color: Color.fromARGB(255, 111, 129, 118),
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: DM.p14,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        height: DM.p60,
                      ),

                      // #text
                      Text(
                        "Login with SNS",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: DM.p14,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: DM.p30,
                      ),

                      // #buttons(facebook & github)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          MaterialButton(
                            onPressed: () {},
                            color: Colors.blue,
                            shape: const StadiumBorder(),
                            height: DM.p45,
                            minWidth: MediaQuery.of(context).size.width * 0.28,
                            child: const Text(
                              "Facebook",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          MaterialButton(
                            onPressed: () {},
                            color: Colors.red,
                            shape: const StadiumBorder(),
                            height: DM.p45,
                            minWidth: MediaQuery.of(context).size.width * 0.28,
                            child: const Text(
                              "Google",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
