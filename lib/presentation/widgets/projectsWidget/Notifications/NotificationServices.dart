import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:healthcare_homelab/constants/colors.dart';
import 'package:uuid/uuid.dart';

Future<void> createPlantFoodNotification() async {
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 1,
       backgroundColor: orangeColor,
       
      channelKey: 'basic_channel',
      title:
          'Request Info!!!',
      body: 'You have a new request.',
     color: blackFontColor,
     
      notificationLayout: NotificationLayout.BigPicture,
    ),
  );
}