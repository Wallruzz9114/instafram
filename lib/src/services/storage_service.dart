import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:instafram/src/utils/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  static Future<String> uploadProfileImage(String url, File imageFile) async {
    String imageId = Uuid().v4();
    final File image = await compressImage(imageId, imageFile);

    if (url.isNotEmpty) {
      final RegExp regularExpression = RegExp(r'profileImage_(.*).jpg');
      imageId = regularExpression.firstMatch(url)[1];
    }

    // Upload to firebase storage
    final StorageUploadTask uploadTask = storageReference
        .child('images/users/profileImage_$imageId.jpg')
        .putFile(image);

    final StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    final String downloadURL =
        await storageTaskSnapshot.ref.getDownloadURL() as String;

    return downloadURL;
  }

  static Future<File> compressImage(String imageId, File image) async {
    final Directory temporaryDirectory = await getTemporaryDirectory();
    final String path = temporaryDirectory.path;
    final File compressedImageFile =
        await FlutterImageCompress.compressAndGetFile(
      image.absolute.path,
      '$path/img_$imageId.jpg',
      quality: 70,
    );

    return compressedImageFile;
  }

  static Future<String> uploadPostMedia(File imageFile) async {
    final String imageId = Uuid().v4();
    final File image = await compressImage(imageId, imageFile);

    // Upload to firebase storage
    final StorageUploadTask uploadTask =
        storageReference.child('images/posts/post_$imageId.jpg').putFile(image);

    final StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    final String downloadURL =
        await storageTaskSnapshot.ref.getDownloadURL() as String;

    return downloadURL;
  }
}
