import 'dart:io' as io;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/drive/v3.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sossoldi/database/sossoldi_database.dart';

final scopes = [drive.DriveApi.driveFileScope];

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: scopes);

  Future<GoogleSignInAccount?> signInWithGoogle(bool silently) async {
    try {
      final account = await (silently? _googleSignIn.signInSilently() : _googleSignIn.signIn()).onError((error, stackTrace) {
        print('Sign in failed: $error');
        return null;
      });
      if (account == null) return null;

      print("Signed in as ${account.displayName}");
      if (kIsWeb) {
        final bool isAuthorized = await _googleSignIn.requestScopes(scopes);
        if (!isAuthorized) {
          return null;
        }
      }

      final authHeaders = await account.authHeaders;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('accessToken', authHeaders['Authorization'] ?? '');

      return account;
    } catch (error) {
      print('Sign in failed: $error');
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut().onError((error, stackTrace) {
      print('Sign out failed: $error');
      return null;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('accessToken');
  }
}

class AuthenticatedClient extends http.BaseClient {
  final http.Client _client;
  final Map<String, String> _headers;

  AuthenticatedClient(this._client, this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}

class DriveService {
  late drive.DriveApi _driveApi;
  late final AuthService _authService;

  DriveService(this._authService);

  set driveApi(drive.DriveApi driveApi) {
    _driveApi = driveApi;
  }

  void _initializeDriveApi(Map<String, String> authHeaders) {
    final authenticateClient = AuthenticatedClient(
      http.Client(),
      Map<String, String>.from(authHeaders),
    );

    _driveApi = drive.DriveApi(authenticateClient);
  }

  Future<bool> initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? accessToken = prefs.getString('accessToken');
    GoogleSignInAccount? account;
    bool silently = accessToken != null;
    account = await _authService.signInWithGoogle(silently);
    if (account == null) {
      return false;
    }

    _initializeDriveApi(await account.authHeaders);
    return true;
  }

  Future<void> uploadDatabase() async {
  final dbPath = await SossoldiDatabase.getPath();
  final dbFile = drive.File();
  dbFile.name = SossoldiDatabase.dbName;

  final media = drive.Media(
    Stream.fromIterable([await io.File(dbPath).readAsBytes()]),
    await io.File(dbPath).length(),
  );

  // Check if the file already exists
  final files = await _driveApi.files.list(
    q: "name='${SossoldiDatabase.dbName}'",
    spaces: 'drive',
  );

  if (files.files != null && files.files!.isNotEmpty) {
    // If the file exists, update it
    print('Updating existing database file');
    final fileId = files.files!.first.id;
    if (fileId != null) {
      await _driveApi.files.update(
        dbFile,
        fileId,
        uploadMedia: media,
      );
    }
  } else {
    // If the file does not exist, create a new file
    print('Creating new database file');
    await _driveApi.files.create(
      dbFile,
      uploadMedia: media,
    );
  }
  print('Database uploaded');
}

  Future<void> downloadDatabase() async {
    final files = await _driveApi.files.list(
      q: "name='${SossoldiDatabase.dbName}'",
      spaces: 'drive',
    );

    if (files.files != null && files.files!.isNotEmpty) {
      final fileId = files.files!.first.id;
      if (fileId != null) {
        final dbPath = await SossoldiDatabase.getPath();
        final fileStream = await _driveApi.files.get(
          fileId,
          downloadOptions: drive.DownloadOptions.fullMedia,
        ) as Media;

        await SossoldiDatabase.instance.close();
        if (kIsWeb) {
          // TODO: Implement web download
        } else {
          await fileStream.stream.pipe(io.File(dbPath).openWrite());
        }
        await SossoldiDatabase.instance.reset();
        print('Database downloaded');
      }
    } else {
      print('Database file not found');
    }
  }
}
