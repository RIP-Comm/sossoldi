import 'dart:io' as io;

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:sossoldi/database/sossoldi_database.dart';
import 'package:sossoldi/pages/google_drive_settings_page/google_drive_service.dart';

import 'google_drive_service_test.mocks.dart';

@GenerateMocks([drive.DriveApi, drive.FilesResource])
void main() {
  group('Google Drive Service', () {
    late MockDriveApi mockDriveApi;
    late MockFilesResource mockFilesResource;
    late AuthService authService;
    late DriveService driveService;

    setUp(() {
      databaseFactory = databaseFactoryFfi;
      // Initialize database with mock data
      SossoldiDatabase.instance.fillDemoData(countOfGeneratedTransaction: 100);

      mockDriveApi = MockDriveApi();
      mockFilesResource = MockFilesResource();
      authService = AuthService();
      driveService = DriveService(authService);
      driveService.driveApi = mockDriveApi;
      when(mockDriveApi.files).thenReturn(mockFilesResource);
    });

    test('Download database file', () async {
      // Arrange
      final dbPath = await SossoldiDatabase.getPath();
      final fileBytes = await io.File(dbPath).readAsBytes();
      final driveFile = drive.File(id: 'fileId');
      final media = drive.Media(Stream.fromIterable([fileBytes]), fileBytes.length);

      when(mockFilesResource.list(
        q: "name='${SossoldiDatabase.dbName}'",
        spaces: 'drive',
      )).thenAnswer((_) async => drive.FileList(files: [driveFile]));

      when(mockFilesResource.get(
        'fileId',
        downloadOptions: anyNamed('downloadOptions'),
      )).thenAnswer((_) async => media);

      // Act
      await driveService.downloadDatabase();

      // Assert
      // Verify that the file was downloaded and written to the correct path
      final writtenBytes = await io.File(dbPath).readAsBytes();
      expect(writtenBytes, fileBytes);
      verify(mockFilesResource.get('fileId', downloadOptions: anyNamed('downloadOptions'))).called(1);
    });
  });
}