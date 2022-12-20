import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthcare_homelab/presentation/pages/Create_Request.dart';

import '../../constants/colors.dart';
import '../../responsives/dimensions.dart';
import '../../state_programming/getController.dart';

class HomeScreen extends StatefulWidget {
  static const String id = "sign_up_page";
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
                Color.fromARGB(255, 167, 76, 15),
                Color.fromARGB(255, 255, 157, 29),
                Color.fromARGB(255, 151, 89, 7),
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
                          "Homepage",
                          textAlign: TextAlign.left,
                          style:
                              TextStyle(color: Colors.white, fontSize: DM.p32),
                        ),
                        SizedBox(
                          height: DM.p5,
                        ),

                        // #welcome
                      ],
                    ),
                  )),
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Color.fromARGB(255, 255, 219, 219),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(DM.p50),
                        topRight: Radius.circular(DM.p50))),
                child: Column(
                  children: [
                    SizedBox(
                      height: DM.p10,
                    ),

                    // #text_field
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: DM.p30),
                      height: MediaQuery.of(context).size.height * 0.5,
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
                      child: ListView.builder(
                        itemCount: 20,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: Icon(
                              Icons.add,
                              color: orangeColor,
                            ),
                            title: Text(
                              style: TextStyle(color: orangeColor),
                              'Meditest ',
                              textScaleFactor: 1,
                            ),
                            trailing: Icon(
                              Icons.done,
                              color: orangeColor,
                            ),
                            subtitle: Text('This is subtitle'),
                            selected: true,
                            onTap: () {},
                          );
                          ;
                        },
                      ),
                    ),
                    SizedBox(
                      height: DM.p35,
                    ),

                    // #signup_button

                    Divider(
                      thickness: 0.5,
                      height: DM.p10,
                    ),
                    MaterialButton(
                      onPressed: () => {Get.to(CreateRequest())},
                      height: DM.p45,
                      minWidth: DM.p240,
                      shape: const StadiumBorder(),
                      color: orangeColor,
                      child: Text(
                        "Create Request",
                        style: TextStyle(
                            color: font_bgOrange,
                            fontSize: DM.p15,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: DM.p60,
                    ),

                    // #text

                    SizedBox(
                      height: DM.p30,
                    ),

                    // #buttons(facebook & github)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
