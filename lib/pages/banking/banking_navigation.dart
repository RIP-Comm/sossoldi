import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/banking_ui_provider.dart';
import '../../ui/snack_bars/snack_bar.dart';

final bankingNavigatorKey = GlobalKey<NavigatorState>();
final bankingNavigationObserver = BankingNavigationObserver();

class BankingNavigationObserver extends NavigatorObserver {
  final List<Route<dynamic>> _routes = [];

  bool contains(String name) =>
      _routes.any((route) => route.isActive && route.settings.name == name);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _routes.add(route);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _routes.remove(route);

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _routes.remove(route);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final index = oldRoute == null ? -1 : _routes.indexOf(oldRoute);
    if (index >= 0) _routes.removeAt(index);
    if (newRoute != null) {
      _routes.insert(index < 0 ? _routes.length : index, newRoute);
    }
  }
}

/// Coordinates both warm callbacks and persisted imports recovered after a cold start.
class BankingNavigation extends ConsumerWidget {
  final Widget child;
  const BankingNavigation({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(bankingUiBootstrapProvider);
    ref.listen(bankRecoveryIssueProvider, (previous, next) {
      if (next != null && next != previous) {
        showRootSnackBar(message: next);
      }
    });
    ref.listen(bankCallbackResultProvider, (previous, next) {
      if (next.error != null) {
        showRootSnackBar(message: bankingErrorMessage(next.error!));
      }
      if (next.connectionId != null &&
          next.connectionId != previous?.connectionId) {
        ref.read(bankCallbackResultProvider.notifier).reset();
        unawaited(
          ref
              .read(connectBankFlowProvider.notifier)
              .resumeImport(connectionId: next.connectionId)
              .catchError((Object error) {
                showRootSnackBar(message: bankingErrorMessage(error));
              }),
        );
      }
    });
    ref.listen(connectBankFlowProvider, (previous, next) {
      if (next.connectionId == null) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final navigator = bankingNavigatorKey.currentState;
        if (navigator == null ||
            bankingNavigationObserver.contains('/import-accounts')) {
          return;
        }
        if (!bankingNavigationObserver.contains('/connect-bank')) {
          navigator.pushNamed('/connect-bank');
        }
        navigator.pushNamed('/import-accounts');
      });
    });
    return child;
  }
}
