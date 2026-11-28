import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../ui/snack_bars/snack_bar.dart';

/// Picks the RSA private key of the user's Enable Banking application from local storage. Mirrors `CSVFilePicker`, including the storage permission dance needed on Android 12 and older.
class PemFilePicker {
  // Request storage permission based on Android version
  static Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      int sdkInt = androidInfo.version.sdkInt;

      if (sdkInt <= 32) {
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    }
    return true;
  }

  // Pick the PEM file holding the application private key
  static Future<File?> pickPemFile(BuildContext context) async {
    bool permissionGranted = await _requestStoragePermission();
    if (!permissionGranted) {
      if (context.mounted) {
        showSnackBar(context, message: 'Storage permission is required');
      }
      return null;
    }

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pem', 'key', 'txt'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        return File(result.files.first.path!);
      }
    } catch (e) {
      if (context.mounted) {
        showSnackBar(
          context,
          message: 'Could not open the file picker. Please try again.',
        );
      }
    }
    return null;
  }
}
