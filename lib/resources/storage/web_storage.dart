import 'dart:typed_data';

import 'package:firebase/firebase.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';

class StorageProvider {
  static Future<String> findImageUrl(BuildContext context, String image) async {
    try {
      final url = await storage().ref(image).getDownloadURL();
      return url.toString();
    } catch (e) {
      return null;
    }
  }

  static Future<bool> uploadImage(
      BuildContext context, Uint8List file, String ref) async {
    try {
      final StorageReference storageReference = storage().ref('').child(ref);

      bool result;
      await storageReference
          .put(file)
          .future
          .whenComplete(() => result = true)
          .catchError((dynamic error) async =>
              print('Web_Storage - StorageUploadTask - uploadImage $error'));
      return result;
    } catch (e) {
      return false;
    }
  }

  static Future<dynamic> showImagePicker() async {
    final Uint8List image =
        await ImagePickerWeb.getImage(outputType: ImageType.bytes);
    return image;
  }
}
