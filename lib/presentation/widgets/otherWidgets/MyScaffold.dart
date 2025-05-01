import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../responsives/dimensions.dart';

class MyScaffold extends StatelessWidget {
  const MyScaffold(
      {Key? key,
      required this.container,
      required this.color1,
      required this.color2})
      : super(key: key);
  final Widget container;
  final Color color1, color2;
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(DM.p1),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color1, color2])),
            child: container),
      ),
    );
  }
}
