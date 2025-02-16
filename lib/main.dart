import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';

import 'model/recurring_transaction.dart';
import 'providers/theme_provider.dart';
import 'routes.dart';
import 'utils/app_theme.dart';
import 'utils/notifications_service.dart';

bool? _isFirstLogin = true;

// Function to initialize the database properly
Future<void> initializeDatabase() async {
  databaseFactory = databaseFactoryFfi; // Set FFI database factory

  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getApplicationDocumentsDirectory();
  final dbPath = '${dir.path}/sossoldi.db';

  var db = await databaseFactory.openDatabase(dbPath);
  await db.close(); // Ensure database is closed to prevent locks
}

void main() async {
  await initializeDatabase(); // Initialize database properly

  //WidgetsFlutterBinding.ensureInitialized();
  NotificationService().requestNotificationPermissions();
  NotificationService().initializeNotifications();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.local);

  SharedPreferences preferences = await SharedPreferences.getInstance();

  bool? getPref = preferences.getBool('is_first_login');
  getPref == null ? await preferences.setBool('is_first_login', false) : null;
  _isFirstLogin = getPref;

  // perform recurring transactions checks
  DateTime? lastCheckGetPref = preferences.getString('last_recurring_transactions_check') != null ? DateTime.parse(preferences.getString('last_recurring_transactions_check')!) : null;
  DateTime? lastRecurringTransactionsCheck = lastCheckGetPref;

  if(lastRecurringTransactionsCheck == null || DateTime.now().difference(lastRecurringTransactionsCheck).inDays >= 1){
    RecurringTransactionMethods().checkRecurringTransactions();
    // update last recurring transactions runtime
    await preferences.setString('last_recurring_transactions_check', DateTime.now().toIso8601String());
  }

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
      themeMode: appThemeState.isDarkModeEnabled ? ThemeMode.dark : ThemeMode.light,
      onGenerateRoute: makeRoute,
      initialRoute: _isFirstLogin == null || _isFirstLogin! ? '/onboarding' : '/',
    );
  }
}
