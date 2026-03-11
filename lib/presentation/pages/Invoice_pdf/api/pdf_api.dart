import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

class PdfApi {
  static const MethodChannel _channel =
      MethodChannel('com.enocderit.meditest/pdf_saver');

  /// Save a PDF.
  /// - Android: write into system Downloads via MediaStore (native code).
  /// - Other platforms: write to a temporary file.
  static Future<File> saveDocument({
    required String name,
    required Document pdf,
    String? subDir,
  }) async {
    final bytes = await pdf.save();

    if (Platform.isAndroid) {
      await _channel.invokeMethod<String>(
        'savePdfToDownloads',
        {
          'name': name,
          'bytes': Uint8List.fromList(bytes),
          'subDir': subDir,
        },
      );

      // Also write a temp file so we can open it with open_file.
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/$name');
      await tempFile.writeAsBytes(bytes, flush: true);
      return tempFile;
    }

    // Non-Android: simple temp file.
    final dir = await Directory.systemTemp.createTemp('pdf_exports_');
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  static Future openFile(File file) async {
    await OpenFile.open(file.path);
  }
}
