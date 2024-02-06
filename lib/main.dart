import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:workmanager/workmanager.dart';
import 'package:sossoldi/utils/worker_manager.dart';

import 'pages/notifications/notifications_service.dart';
import 'providers/theme_provider.dart';
import 'routes.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  requestNotificationPermissions();
  initializeNotifications();
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  initializeDateFormatting('it_IT', null).then((_) => runApp(const ProviderScope(child: Launcher())));
}

class Launcher extends ConsumerWidget {
  const Launcher({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appThemeState = ref.watch(appThemeStateNotifier);
    return MaterialApp(
      title: 'Sossoldi',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode:
          appThemeState.isDarkModeEnabled ? ThemeMode.dark : ThemeMode.light,
      onGenerateRoute: makeRoute,
      initialRoute: '/',
    );
  }
}
