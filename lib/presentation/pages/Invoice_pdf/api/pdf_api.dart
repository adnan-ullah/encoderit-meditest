import 'dart:io';

import 'package:flutter/services.dart';
import 'package:healthcare_homelab/constants/app_info.dart';
import 'package:intl/intl.dart';
//import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:permission_handler/permission_handler.dart';

class PdfApi {
  static Future<File> saveDocument({
    required String name,
    required Document pdf,
  }) async {
    final bytes = await pdf.save();

//  final dir = await getApplicationDocumentsDirectory();
    // print(dir.absolute);
    var dir2;

    var date = DateFormat(
      'MMMyyy',
    ).format(DateTime.now()).toString();

    await Directory('storage/emulated/0/DCIM/$app_name/$date')
        .create(recursive: true)
        .then((value) {
      dir2 = value.path;
    });

    final file = File('$dir2/$name');

    await file.writeAsBytes(bytes);

    var file2 = file;

    return file;
  }

  static Future openFile(File file) async {
    final url = file.path;

    if(url.contains('Lab_Copy') ==false){
    //await OpenFile.open(url);
    }
    

  }
}
