import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../core/constants/app_constants.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      return await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
    } catch (_) {
      return null;
    }
  }

  Future<String> uploadProfileImage(String employeeId, XFile image) async {
    final ref = _storage
        .ref()
        .child(AppConstants.profileImagesPath)
        .child('$employeeId.jpg');

    UploadTask task;
    if (image.path.startsWith('blob:') || image.path.isEmpty) {
      // Web: read bytes
      final bytes = await image.readAsBytes();
      task = ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    } else {
      task = ref.putFile(File(image.path));
    }

    final snapshot = await task;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> deleteProfileImage(String employeeId) async {
    try {
      await _storage
          .ref()
          .child(AppConstants.profileImagesPath)
          .child('$employeeId.jpg')
          .delete();
    } catch (_) {
      // Image may not exist
    }
  }
}
