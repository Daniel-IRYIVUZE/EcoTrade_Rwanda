import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

class PermissionUtils {
  static Future<bool> requestLocation(BuildContext context) async {
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    return perm != LocationPermission.denied && perm != LocationPermission.deniedForever;
  }

  static Future<bool> requestCamera() async {
    final picker = ImagePicker();
    try {
      final img = await picker.pickImage(source: ImageSource.camera);
      return img != null;
    } catch (_) {
      return false;
    }
  }
}
