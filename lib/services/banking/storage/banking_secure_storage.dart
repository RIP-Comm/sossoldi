import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Shared options let the Android plugin migrate legacy entries into one backend before reading or deleting them.
const bankingSecureStorage = FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
  iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
);
