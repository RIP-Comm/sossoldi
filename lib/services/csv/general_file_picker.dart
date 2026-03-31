import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../../ui/snack_bars/snack_bar.dart';
import '../../ui/device.dart';

class GeneralFilePicker {
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
  static Future<File?> pickFile(BuildContext context, List<String> extensions) async {
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
        allowedExtensions: extensions,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile pickedFile = result.files.first;
        // 1. Check via the FilePicker property (cleanest)
        // 2. Fallback: Check the actual file path using the 'path' package
        String? extension = pickedFile.extension ?? p.extension(pickedFile.path!).replaceFirst('.', '');

        if (extensions.contains(extension.toLowerCase())) {
          return File(pickedFile.path!);
        } else {
          if (context.mounted) {
            showSnackBar(context, message: 'Invalid file type. Expected: ${extensions.join(", ")}');
          }
          return null;
        }

      }
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, message: 'Error picking file: ${e.toString()}');
      }
    }
    return null;
  }

  // Share exported CSV file
  static Future<void> saveFile(List<int> data, BuildContext context) async {

    try {

      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String proposedName  = 'sossoldi_export_$timestamp.csv';
      // Prompt the user to select a directory
      String? filePath = await FilePicker.platform.saveFile(
          dialogTitle: 'Please select where to save your file:',
          fileName: proposedName
      );
      if (filePath == null) {
        // User canceled the picker
        return;
      }

      // Write the CSV content directly to the file
      final file = await File(filePath).writeAsBytes(data);

      // Show success message
      if (context.mounted) {
        showSnackBar(context, message: 'File saved to: ${file.path}');
      }
    } catch (e) {
      if (context.mounted) {
        String errorMessage =
            'Cannot save the file here, please create or select a folder in Downloads or Documents. Error: ${e.toString()}';

        showSnackBar(context, message: errorMessage);
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
