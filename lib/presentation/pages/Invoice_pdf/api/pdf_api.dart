import 'dart:io';

import 'package:flutter/services.dart';
import 'package:healthcare_homelab/constants/app_info.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

class PdfApi {
  static Future<File> saveDocument({
    required String name,
    required Document pdf,
  }) async {
    final bytes = await pdf.save();

//  final dir = await getApplicationDocumentsDirectory();
   // print(dir.absolute);
    var dir2;
    await  Directory('/storage/emulated/0/Download/$app_name')
        .create(recursive: true)
        .then((value) {
      dir2 = value.path;
    });

    // final file = File('${dir.path}/$name');
    var file = File('$dir2/$name');

    await file.writeAsBytes(bytes);

    return file;
  }

  static Future openFile(File file) async {
    final url = file.path;

    await OpenFile.open(url);
  }
}
