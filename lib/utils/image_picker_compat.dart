import 'package:image_picker/image_picker.dart';

/// Backwards-compatibility shim for older `ImagePicker().getImage(...)` calls,
/// implemented on top of the newer `pickImage` API.
extension ImagePickerCompat on ImagePicker {
  Future<PickedFile?> getImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    final XFile? xFile = await pickImage(
      source: source,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
    );
    if (xFile == null) return null;
    return PickedFile(xFile.path);
  }
}

