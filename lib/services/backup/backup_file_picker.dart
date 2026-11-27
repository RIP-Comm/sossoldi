import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../../ui/snack_bars/snack_bar.dart';
import '../../ui/device.dart';

class BackupFilePicker {
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

  /// Lets the user pick a file. With [extensions] the picker only shows
  /// those types; without, any file can be chosen (needed for `.db`, which
  /// mobile pickers do not recognise as a type).
  static Future<File?> pickFile(
    BuildContext context, {
    List<String>? extensions,
  }) async {
    bool permissionGranted = await _requestStoragePermission();
    if (!permissionGranted) {
      if (context.mounted) {
        showSnackBar(context, message: 'Storage permission is required');
      }
      return null;
    }

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: extensions == null ? FileType.any : FileType.custom,
        allowedExtensions: extensions,
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

  /// Opens the system "save as" dialog to save [bytes] as
  /// `sossoldi_export_<timestamp>.<extension>`.
  static Future<void> saveFile(
    List<int> bytes,
    String extension,
    BuildContext context,
  ) async {
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String fileName = 'sossoldi_export_$timestamp.$extension';
    final data = Uint8List.fromList(bytes);
    try {
      // On Android and iOS the plugin writes the bytes itself (through the
      // system document picker, which works in any folder); on desktop it
      // only returns the chosen path.
      final String? path = await FilePicker.platform.saveFile(
        dialogTitle: 'Save export',
        fileName: fileName,
        bytes: data,
      );
      if (path == null) return; // User canceled the picker

      if (!Platform.isAndroid && !Platform.isIOS) {
        await File(path).writeAsBytes(data, flush: true);
      }

      if (context.mounted) {
        showSnackBar(context, message: 'File saved: $fileName');
      }
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, message: 'Cannot save the file: $e');
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
