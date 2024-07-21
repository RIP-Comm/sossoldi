import 'dart:io' as io if (dart.library.html) 'dart:html';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sossoldi/lifecycle.dart';
import 'package:sossoldi/providers/google_drive_provider.dart';
import 'package:workmanager/workmanager.dart';
import 'package:sossoldi/utils/worker_manager.dart';

import 'pages/notifications/notifications_service.dart';
import 'providers/theme_provider.dart';
import 'routes.dart';
import 'utils/app_theme.dart';

bool? _isFirstLogin = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if(!kIsWeb && io.Platform.isAndroid){
    requestNotificationPermissions();
    initializeNotifications();
    Workmanager().initialize(callbackDispatcher);
  }

  SharedPreferences preferences = await SharedPreferences.getInstance();
  bool? getPref =  preferences.getBool('is_first_login');
  getPref == null ? await preferences.setBool('is_first_login', false) : null;
  _isFirstLogin = getPref;

  initializeDateFormatting('it_IT', null).then((_) {
    runApp(
      const ProviderScope(
        child: AppLifecycleManager(
          child: Launcher(),
        ),
      ),
    );
  });
}

class Launcher extends ConsumerWidget {
  const Launcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appThemeState = ref.watch(appThemeStateNotifier);
    ref.read(googleDriveNotifier).initialize(ref);

    return MaterialApp(
      title: 'Sossoldi',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode:
          appThemeState.isDarkModeEnabled ? ThemeMode.dark : ThemeMode.light,
      onGenerateRoute: makeRoute,
      initialRoute: _isFirstLogin == null || _isFirstLogin! ? '/onboarding' : '/',
    );
  }
}