import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../ui/snack_bars/snack_bar.dart';

/// Exports the public certificate with the native save-file dialog, including iOS Files and Android document storage.
class EnableBankingCertificateFilePicker {
  static Future<String?> saveCertificateFile(
    String certificatePem,
    BuildContext context,
  ) async {
    try {
      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Save public certificate',
        fileName: 'enablebanking-certificate.pem',
        bytes: Uint8List.fromList(utf8.encode(certificatePem)),
      );
      if (path != null && context.mounted) {
        showSnackBar(context, message: 'Public certificate saved');
      }
      return path;
    } catch (e) {
      if (context.mounted) {
        showSnackBar(
          context,
          message:
              'Could not save the certificate. Choose a writable folder '
              'in Downloads or Documents and try again.',
        );
      }
      return null;
    }
  }
}
