// ignore_for_file: unused_result

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sossoldi/pages/google_drive_settings_page/google_drive_service.dart';
import 'package:sossoldi/providers/accounts_provider.dart';
import 'package:sossoldi/providers/budgets_provider.dart';
import 'package:sossoldi/providers/categories_provider.dart';
import 'package:sossoldi/providers/dashboard_provider.dart';
import 'package:sossoldi/providers/statistics_provider.dart';
import 'package:sossoldi/providers/transactions_provider.dart';

final googleDriveNotifier = ChangeNotifierProvider(
  (ref) => GoogleDriveState(),
);

class GoogleDriveState extends ChangeNotifier {
  bool isGoogleDriveConnected = false;
  late AuthService _authService;
  late DriveService driveService;

  GoogleDriveState() {
    _authService = AuthService();
    driveService = DriveService(_authService);
  }

  Future<void> initialize(WidgetRef ref) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('accessToken')) {
      await connectDrive(ref);
    }
  }
  
  Future<void> connectDrive(WidgetRef ref) async {
    bool connect = await driveService.initialize();
    if (!connect) {
      print('Failed to connect to Google Drive');
      return;
    }
    await syncFromDrive(ref);
    isGoogleDriveConnected = true;
    notifyListeners();
  }

  Future<void> disconnectDrive() async {
    await _authService.signOut();
    isGoogleDriveConnected = false;
    notifyListeners();
  }

  Future<void> syncToDrive() async {
    return driveService.uploadDatabase();
  }

  Future<void> syncFromDrive(WidgetRef? ref) async {
    await driveService.downloadDatabase().then((v) {
      if (ref == null) {
        return;
      }
      
      ref.refresh(accountsProvider);
      ref.refresh(categoriesProvider);
      ref.refresh(transactionsProvider);
      ref.refresh(budgetsProvider);
      ref.refresh(dashboardProvider);
      ref.refresh(lastTransactionsProvider);
      ref.refresh(statisticsProvider);
    });
  }
}