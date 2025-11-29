import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../../ui/snack_bars/snack_bar.dart';
import '../../ui/device.dart';

class CSVFilePicker {
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

  // Pick CSV file for import
  static Future<File?> pickCSVFile(BuildContext context) async {
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
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        return File(result.files.first.path!);
      }
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, message: 'Error picking file: ${e.toString()}');
      }
    }
    return null;
  }

  // Share exported CSV file
  static Future<void> saveCSVFile(String csv, BuildContext context) async {
    try {
      // Prompt the user to select a directory
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == null) {
        // User canceled the picker
        return;
      }

      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String filePath = join(
        selectedDirectory,
        'sossoldi_export_$timestamp.csv',
      );

      // Write the CSV content directly to the file
      final file = await File(filePath).writeAsString(csv);

      // Show success message
      if (context.mounted) {
        showSnackBar(context, message: 'File saved to: ${file.path}');
      }
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, message: 'Error saving file: ${e.toString()}');
      }
    }
  }

  // Show loading dialog
  static void showLoading(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Sizes.borderRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: Sizes.lg,
              horizontal: Sizes.xl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: Sizes.lg),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Hide loading dialog
  static void hideLoading(BuildContext context) {
    Navigator.of(context).pop();
  }

  // Show success message
  static Future<void> showSuccess(BuildContext context, String message) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: Text(message),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Sizes.borderRadius),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
