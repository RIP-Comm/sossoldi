import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final googleDriveNotifier = ChangeNotifierProvider(
  (ref) => GoogleDriveState(),
);

class GoogleDriveState extends ChangeNotifier {
  var isGoogleDriveConnected = false;
  var isGoogleDriveSyncing = true;

  void connectDrive() {
    isGoogleDriveConnected = true;
    // TODO: instantiate Google Drive connection
    print('Connected to Google Drive');
    notifyListeners();
  }

  void disconnectDrive() {
    isGoogleDriveConnected = false;
    // TODO: disconnect Google Drive
    print('Disconnected from Google Drive');
    notifyListeners();
  }

  void syncDrive() {
    isGoogleDriveSyncing = true;
    print('Syncing Google Drive');
    notifyListeners();
  }

  void stopSyncDrive() {
    isGoogleDriveSyncing = false;
    print('Stopped syncing Google Drive');
    notifyListeners();
  }

  void syncNow() {
    print("Syncing now...");
  }
}