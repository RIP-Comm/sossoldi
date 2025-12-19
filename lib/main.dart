import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_phoenix/flutter_phoenix.dart';

import 'providers/settings_provider.dart';
import 'providers/theme_provider.dart';
import 'routes/routes.dart';
import 'services/database/repositories/recurring_transactions_repository.dart';
import 'services/database/sossoldi_database.dart';
import 'services/notifications/notifications_service.dart';
import 'ui/theme/app_theme.dart';

late SharedPreferences _sharedPreferences;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().requestNotificationPermissions();
  NotificationService().initializeNotifications();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.local);

  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  _sharedPreferences = await SharedPreferences.getInstance();

  // KV migration from the 'is_first_login' key to 'onboarding_completed'
  // to correctly handle the completion of the onboarding process
  // (To consider to remove in later future)
  final bool? isFirstLoginCachedValue = _sharedPreferences.getBool(
    'is_first_login',
  );
  final bool isOnBoardingCompletedKeyNotSaved =
      _sharedPreferences.getBool('onboarding_completed') == null;
  if (isFirstLoginCachedValue != null && isOnBoardingCompletedKeyNotSaved) {
    await _sharedPreferences.setBool(
      'onboarding_completed',
      !isFirstLoginCachedValue,
    );
  }

  // perform recurring transactions checks
  DateTime? lastCheckGetPref =
      _sharedPreferences.getString('last_recurring_transactions_check') != null
      ? DateTime.parse(
          _sharedPreferences.getString('last_recurring_transactions_check')!,
        )
      : null;
  DateTime? lastRecurringTransactionsCheck = lastCheckGetPref;

  if (lastRecurringTransactionsCheck == null ||
      DateTime.now().difference(lastRecurringTransactionsCheck).inDays >= 1) {
    RecurringTransactionRepository(
      database: SossoldiDatabase.instance,
    ).checkRecurringTransactions();
    // update last recurring transactions runtime
    await _sharedPreferences.setString(
      'last_recurring_transactions_check',
      DateTime.now().toIso8601String(),
    );
  }

  final LocalAuthentication auth = LocalAuthentication();
  if (await auth.isDeviceSupported()) {
    // check for authentication if requested by user
    bool? requiresAuthentication = _sharedPreferences.getBool(
      "user_requires_authentication",
    );

    if (requiresAuthentication != null && requiresAuthentication == true) {
      // use sticky auth to resume auth request when app is going background
      bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to use Sossoldi',
        persistAcrossBackgrounding: true,
      );
      if (!didAuthenticate) return; // stops app from loading
    }
  }

  initializeDateFormatting('it_IT', null).then(
    (_) => runApp(
      Phoenix(
        child: ProviderScope(child: Launcher(version: packageInfo.version)),
      ),
    ),
  );
}

class Launcher extends ConsumerStatefulWidget {
  final String version;

  const Launcher({super.key, required this.version});

  @override
  ConsumerState<Launcher> createState() => _LauncherState();
}

class _LauncherState extends ConsumerState<Launcher> {
  @override
  void initState() {
    super.initState();
    // Set the version after the provider is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(versionProvider.notifier).setVersion(widget.version);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isOnboardingCompleted =
        _sharedPreferences.getBool('onboarding_completed') ?? false;

    final appThemeState = ref.watch(appThemeStateProvider);
    return MaterialApp(
      title: 'Sossoldi',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: appThemeState.isDarkModeEnabled
          ? ThemeMode.dark
          : ThemeMode.light,
      onGenerateRoute: makeRoute,
      initialRoute: !isOnboardingCompleted ? '/onboarding' : '/',
    );
  }
}
