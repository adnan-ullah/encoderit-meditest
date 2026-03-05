import 'dart:io';

import 'package:flutter/services.dart';
import 'package:healthcare_homelab/constants/app_info.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
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

    // Use app-specific external storage so no MANAGE_EXTERNAL_STORAGE is needed.
    final baseDir =
        await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();

    final date = DateFormat('MMMyyy').format(DateTime.now()).toString();
    final targetDir = Directory('${baseDir.path}/$app_name/$date');
    await targetDir.create(recursive: true);

    final file = File('${targetDir.path}/$name');
    await file.writeAsBytes(bytes);

    return file;
  }

  static Future openFile(File file) async {
    final url = file.path;

    if(url.contains('Lab_Copy') ==false){
    await OpenFile.open(url);
    }
    

  }
}
