import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/pages/settings/banking/enable_banking_setup_page.dart';
import 'package:sossoldi/pages/banking/import_accounts_page.dart';
import 'package:sossoldi/providers/banking_ui_provider.dart';
import 'package:sossoldi/services/banking/banking_account.dart';
import 'package:sossoldi/services/banking/banking_reference.dart';
import 'package:sossoldi/services/banking/enable_banking/enable_banking_credentials_store.dart';
import 'package:sossoldi/ui/theme/app_theme.dart';

const rawStorage = FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
  iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
);

class AuditSettings extends EnableBankingSettings {
  final EnableBankingCredentialsStore store;
  Completer<void>? gate;
  int saves = 0;
  AuditSettings(this.store);
  @override
  Future<EnableBankingConfig?> build() => store.readConfig();
  @override
  Future<void> save({
    required String appId,
    required String privateKeyPem,
    required EnableBankingConfig config,
  }) async {
    saves++;
    await gate?.future;
    await store.saveCredentials(
      appId: appId,
      privateKeyPem: privateKeyPem,
      config: config,
    );
    state = AsyncData(config);
  }

  @override
  Future<void> clear() async {
    await store.clear();
    state = const AsyncData(null);
  }
}

class DelayedDraftStore extends EnableBankingCredentialsStore {
  final gate = Completer<void>();
  final oldWritesDone = Completer<void>();
  @override
  Future<void> saveSetupDraft(EnableBankingSetupDraft draft) async {
    if (draft.appId == 'old-1') await gate.future;
    await super.saveSetupDraft(draft);
    if (draft.appId == 'old-2' && !oldWritesDone.isCompleted) {
      oldWritesDone.complete();
    }
  }
}

class FailingDraftStore extends EnableBankingCredentialsStore {
  bool denied = false;
  @override
  Future<void> saveSetupDraft(EnableBankingSetupDraft draft) async {
    if (denied) throw StateError('Synthetic storage failure');
    await super.saveSetupDraft(draft);
  }
}

class AuditGenerator extends EnableBankingKeyGenerator {
  final EnableBankingKeyMaterial material;
  int calls = 0;
  AuditGenerator(this.material);
  @override
  Future<EnableBankingKeyMaterial> generate({
    int keySize = kEnableBankingKeySize,
  }) async {
    calls++;
    return material;
  }
}

class MutableImport extends ConnectBankFlow {
  @override
  ConnectBankFlowState build() =>
      ConnectBankFlowState(importable: [account('first')]);
  static BankingAccount account(String name) => BankingAccount(
    reference: BankingAccountReference(providerId: 'test', remoteId: name),
    name: name,
    currency: 'EUR',
  );
  void change() =>
      state = ConnectBankFlowState(importable: [account('second')]);
}

Future<void> auditTap(WidgetTester t, String text) async {
  final f = find.text(text);
  await t.ensureVisible(f.first);
  await t.pumpAndSettle();
  await t.tap(f.first);
  await t.pumpAndSettle();
}

Future<ProviderContainer> auditPage(
  WidgetTester t,
  EnableBankingCredentialsStore store, {
  String identity = 'page',
  bool settle = true,
  AuditSettings? settings,
  AuditGenerator? generator,
}) async {
  final c = ProviderContainer(
    retry: (_, _) => null,
    overrides: [
      enableBankingCredentialsStoreProvider.overrideWithValue(store),
      enableBankingSettingsProvider.overrideWith(
        () => settings ?? AuditSettings(store),
      ),
      if (generator != null)
        enableBankingKeyGeneratorProvider.overrideWithValue(generator),
    ],
  );
  await t.pumpWidget(
    UncontrolledProviderScope(
      key: ValueKey(identity),
      container: c,
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const EnableBankingSetupPage(),
        routes: {
          '/connect-bank': (_) => const Scaffold(body: Text('Bank selection')),
        },
      ),
    ),
  );
  if (settle) {
    await t.pumpAndSettle();
  } else {
    await t.pump();
  }
  return c;
}

Map<String, Future<void> Function(WidgetTester)> uiAuditCases(
  EnableBankingKeyMaterial material,
) => {
  'UI01 malformed verified credential bundle offers a usable recovery path':
      (t) async {
        const store = EnableBankingCredentialsStore();
        await rawStorage.write(key: 'eb_credentials_v1', value: 'corrupt');
        final c = await auditPage(t, store);
        addTearDown(c.dispose);
        expect(
          find.text('Could not load your saved setup. Try again.'),
          findsOneWidget,
        );
        await auditTap(t, 'Restart unfinished setup');
        await auditTap(t, 'Restart');
        expect(
          find.text('Could not load your saved setup. Try again.'),
          findsOneWidget,
        );
        expect(find.text('Clear credentials'), findsOneWidget);
        await auditTap(t, 'Clear credentials');
        await auditTap(t, 'Clear');
        expect(await store.readCredentials(), isNull);
        expect(find.text('First-time setup'), findsOneWidget);
      },
  'UI02 old page writes never overwrite newer page progress': (t) async {
    final store = DelayedDraftStore();
    await store.saveSetupDraft(
      EnableBankingSetupDraft(
        step: 3,
        existingCredentials: true,
        appId: 'original',
        privateKeyPem: material.privateKeyPem,
      ),
    );
    final first = await auditPage(t, store);
    await t.enterText(find.byType(TextField).first, 'old-1');
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField).first, 'old-2');
    await t.pumpAndSettle();
    final second = await auditPage(
      t,
      store,
      identity: 'new-page',
      settle: false,
    );
    first.dispose();
    addTearDown(second.dispose);
    store.gate.complete();
    await t.pumpAndSettle();
    expect(
      t.widget<TextField>(find.byType(TextField).first).controller!.text,
      'old-2',
    );
    await t.enterText(find.byType(TextField).first, 'new-user-progress');
    await t.pumpAndSettle();
    for (
      var i = 0;
      i < 100 && (await store.readSetupDraft())?.appId != 'new-user-progress';
      i++
    ) {
      await t.pump(const Duration(milliseconds: 10));
    }
    expect((await store.readSetupDraft())!.appId, 'new-user-progress');
  },
  'UI03 Clear credentials cannot be undone by a closed page write': (t) async {
    final store = DelayedDraftStore();
    await store.saveCredentials(
      appId: 'verified',
      privateKeyPem: material.privateKeyPem,
      config: const EnableBankingConfig(appId: 'verified'),
    );
    await store.saveSetupDraft(
      EnableBankingSetupDraft(
        step: 3,
        existingCredentials: true,
        appId: 'original',
        privateKeyPem: material.privateKeyPem,
      ),
    );
    final first = await auditPage(t, store);
    await auditTap(t, 'Resume replacement');
    await t.enterText(find.byType(TextField).first, 'old-1');
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField).first, 'old-2');
    await t.pumpAndSettle();
    final second = await auditPage(
      t,
      store,
      identity: 'new-page',
      settle: false,
    );
    first.dispose();
    addTearDown(second.dispose);
    store.gate.complete();
    await t.pumpAndSettle();
    await auditTap(t, 'Clear credentials');
    await t.tap(find.text('Clear'));
    await t.pump();
    for (var i = 0; i < 100 && (await store.readCredentials()) != null; i++) {
      await t.pump(const Duration(milliseconds: 10));
    }
    await t.pumpAndSettle();
    expect(await store.readCredentials(), isNull);
    expect(await store.readSetupDraft(), isNull);
    expect(
      await store.readDraftPrivateKey() == null,
      isTrue,
      reason: 'Sensitive draft must remain deleted after Clear credentials',
    );
  },
  'UI04 import page refreshes drafts when pending connection changes':
      (t) async {
        final flow = MutableImport();
        final c = ProviderContainer(
          overrides: [
            connectBankFlowProvider.overrideWith(() => flow),
            ebAccountBalanceProvider('first').overrideWith((ref) async => 0),
            ebAccountBalanceProvider('second').overrideWith((ref) async => 0),
          ],
        );
        addTearDown(c.dispose);
        await t.pumpWidget(
          UncontrolledProviderScope(
            container: c,
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const ImportAccountsPage(),
            ),
          ),
        );
        await t.pumpAndSettle();
        expect(
          t.widget<TextField>(find.byType(TextField).first).controller!.text,
          'first',
        );
        flow.change();
        await t.pumpAndSettle();
        expect(
          t.widget<TextField>(find.byType(TextField).first).controller!.text,
          'second',
        );
      },
  'UI05 successful verification after leaving page must not leave an unfinished replacement':
      (t) async {
        const store = EnableBankingCredentialsStore();
        await store.saveSetupDraft(
          EnableBankingSetupDraft(
            step: 3,
            existingCredentials: true,
            appId: 'verified',
            privateKeyPem: material.privateKeyPem,
          ),
        );
        final settings = AuditSettings(store)..gate = Completer<void>();
        final c = await auditPage(t, store, settings: settings);
        addTearDown(c.dispose);
        await t.ensureVisible(find.text('Verify and continue'));
        await t.pumpAndSettle();
        await t.tap(find.text('Verify and continue'));
        await t.pump();
        await t.pumpWidget(
          const MaterialApp(home: Scaffold(body: Text('Other page'))),
        );
        await t.pump();
        settings.gate!.complete();
        for (
          var i = 0;
          i < 100 && (await store.readCredentials()) == null;
          i++
        ) {
          await t.pump(const Duration(milliseconds: 10));
        }
        expect(await store.readCredentials(), isNotNull);
        final next = await auditPage(t, store, identity: 'returned');
        addTearDown(next.dispose);
        expect(find.text('Bank sync is configured'), findsOneWidget);
        expect(await store.readSetupDraft(), isNull);
      },
  'UI06 invalid key never replaces verified credentials': (t) async {
    const store = EnableBankingCredentialsStore();
    await store.saveSetupDraft(
      const EnableBankingSetupDraft(step: 3, existingCredentials: true),
    );
    final settings = AuditSettings(store);
    final c = await auditPage(t, store, settings: settings);
    addTearDown(c.dispose);
    await t.enterText(find.byType(TextField).first, 'app');
    await t.enterText(find.byType(TextField).last, 'not-a-key');
    await t.testTextInput.receiveAction(TextInputAction.done);
    await t.pumpAndSettle();
    await auditTap(t, 'Verify and continue');
    expect(settings.saves, 0);
    expect(await store.readCredentials(), isNull);
    expect(
      find.textContaining('This private key could not be read'),
      findsOneWidget,
    );
  },
  'UI07 regeneration storage failure preserves original key and certificate':
      (t) async {
        final store = FailingDraftStore();
        await store.saveSetupDraft(
          const EnableBankingSetupDraft(
            step: 1,
            privateKeyPem: 'old-key',
            certificatePem: 'old-public-cert',
          ),
        );
        final generator = AuditGenerator(material);
        final c = await auditPage(t, store, generator: generator);
        addTearDown(c.dispose);
        store.denied = true;
        await auditTap(t, 'Generate a replacement key');
        await auditTap(t, 'Generate');
        expect((await store.readSetupDraft())!.privateKeyPem, 'old-key');
        expect(
          (await store.readSetupDraft())!.certificatePem,
          'old-public-cert',
        );
        expect(
          find.textContaining('Could not save your progress securely'),
          findsOneWidget,
        );
      },
  'UI08 empty field error is brought into view at very large text': (t) async {
    const store = EnableBankingCredentialsStore();
    await store.saveSetupDraft(
      EnableBankingSetupDraft(
        step: 3,
        existingCredentials: true,
        privateKeyPem: material.privateKeyPem,
      ),
    );
    final c = ProviderContainer(
      overrides: [
        enableBankingSettingsProvider.overrideWith(() => AuditSettings(store)),
      ],
    );
    addTearDown(c.dispose);
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(3.2)),
            child: child!,
          ),
          home: const EnableBankingSetupPage(),
        ),
      ),
    );
    await t.pumpAndSettle();
    await auditTap(t, 'Verify and continue');
    expect(
      find.text('Enter your Enable Banking application ID').hitTestable(),
      findsOneWidget,
    );
  },
  'UI09 cancelled regeneration never creates a replacement': (t) async {
    const store = EnableBankingCredentialsStore();
    await store.saveSetupDraft(
      const EnableBankingSetupDraft(
        step: 1,
        privateKeyPem: 'old-key',
        certificatePem: 'old-cert',
      ),
    );
    final generator = AuditGenerator(material);
    final c = await auditPage(t, store, generator: generator);
    addTearDown(c.dispose);
    await auditTap(t, 'Generate a replacement key');
    await auditTap(t, 'Cancel');
    expect(generator.calls, 0);
    expect((await store.readSetupDraft())!.privateKeyPem, 'old-key');
  },
  'UI10 clear during an in-flight write also invalidates later queued saves':
      (t) async {
        final store = DelayedDraftStore();
        await store.saveSetupDraft(
          EnableBankingSetupDraft(
            step: 3,
            existingCredentials: true,
            appId: 'original',
            privateKeyPem: material.privateKeyPem,
          ),
        );
        final c = await auditPage(t, store);
        addTearDown(c.dispose);
        await t.enterText(find.byType(TextField).first, 'old-1');
        await t.pumpAndSettle();
        await t.enterText(find.byType(TextField).first, 'old-2');
        await t.pumpAndSettle();
        final deletion = store.clear();
        store.gate.complete();
        await deletion;
        await t.pumpAndSettle();
        expect(await store.readSetupDraft(), isNull);
        expect(await store.readCredentials(), isNull);
        await t.enterText(
          find.byType(TextField).first,
          'stale-page-after-clear',
        );
        await t.pumpAndSettle();
        expect(await store.readSetupDraft(), isNull);
      },
};
