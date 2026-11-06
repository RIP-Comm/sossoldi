import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sossoldi/providers/banking_ui_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../support/bank_sync_harness.dart';

class _Settings extends EnableBankingSettings {
  @override
  Future<EnableBankingConfig?> build() async =>
      const EnableBankingConfig(appId: 'synthetic-app');
}

class _Recovery extends ConnectBankFlow {
  bool offline = true;
  int calls = 0;
  @override
  ConnectBankFlowState build() => const ConnectBankFlowState();
  @override
  Future<void> resumeImport({int? connectionId}) async {
    calls++;
    if (offline) throw const SocketException('Synthetic offline startup');
  }
}

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'offline startup exposes an error and app resume retries recovery',
    () async {
      sqfliteFfiInit();
      final h = BankSyncHarness(databaseFactoryFfi);
      await h.open();
      addTearDown(h.close);
      final flow = _Recovery();
      final container = ProviderContainer(
        overrides: [
          enableBankingSettingsProvider.overrideWith(_Settings.new),
          bankingCallbackBootstrapProvider.overrideWith((ref) async {}),
          connectBankFlowProvider.overrideWith(() => flow),
          bankSyncServiceProvider.overrideWithValue(h.service),
        ],
      );
      addTearDown(container.dispose);
      container.listen(
        bankingUiBootstrapProvider,
        (_, _) {},
        fireImmediately: true,
      );
      await (() async {
        await container.read(bankingUiBootstrapProvider.future);
        for (
          var i = 0;
          i < 100 && container.read(bankRecoveryIssueProvider) == null;
          i++
        ) {
          await Future<void>.delayed(const Duration(milliseconds: 5));
        }
      })();
      final attemptsBeforeResume = flow.calls;
      expect(attemptsBeforeResume, greaterThanOrEqualTo(1));
      expect(container.read(bankRecoveryIssueProvider), isNotNull);
      flow.offline = false;
      binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await (() async {
        for (var i = 0; i < 100 && (await h.transactions()).isEmpty; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 5));
        }
      })();
      expect(flow.calls, greaterThan(attemptsBeforeResume));
      expect(await h.transactions(), hasLength(1));
      expect(container.read(bankRecoveryIssueProvider), isNull);
    },
  );
}
