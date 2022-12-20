import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../responsives/dimensions.dart';

class FrostedContainer extends StatelessWidget {
  final Widget container;
  final Color color1, color2;
  FrostedContainer({
    Key? key,
    required this.container,
    required this.color1,
    required this.color2,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(DM.p1),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
            decoration: BoxDecoration(
                color: Colors.grey.shade200.withOpacity(0.9),
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color1, color2])),
            child: container),
      ),
    );
  }
}
