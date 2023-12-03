import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sossoldi/providers/theme_provider.dart';
import 'package:sossoldi/utils/app_theme.dart';
import 'routes.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  initializeDateFormatting('it_IT', null)
      .then((_) => runApp(const ProviderScope(child: Launcher())));
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
      themeMode: appThemeState.themeMode,
      onGenerateRoute: makeRoute,
      initialRoute: '/',
    );
  }
}
